#!/usr/bin/env python3
"""claude-oom-watchdog.py - Monitor Claude Code for runaway memory growth.

Polls /proc every 250ms looking for Claude Code processes with RSS
growing faster than 1GB/s. When detected:
  1. Snapshots /proc/{pid}/{status,maps,smaps_rollup,stat,io}
  2. Attaches strace to capture the hot path (3s default)
  3. Re-checks RSS after strace — if it stabilized or dropped, V8 GC
     likely caught up and the process is spared
  4. If RSS is still growing, sends SIGABRT for core dump (via systemd-coredump)

Known bug: Claude Code consumes all system memory when restored from
background (fg after control-z) after sitting idle for hours.

Usage:
  ./claude-oom-watchdog.py                  # monitor and act
  ./claude-oom-watchdog.py --dry-run        # monitor and report only
  sudo ./claude-oom-watchdog.py             # needed for strace (ptrace_scope=1)
"""

import argparse
import os
import signal
import subprocess
import time
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Sample:
    timestamp: float
    rss_bytes: int


@dataclass
class TrackedProcess:
    pid: int
    cmdline: str
    samples: list[Sample] = field(default_factory=list)
    triggered: bool = False


def format_bytes(b: int | float) -> str:
    for unit in ("B", "KiB", "MiB", "GiB"):
        if abs(b) < 1024:
            return f"{b:.1f} {unit}"
        b /= 1024
    return f"{b:.1f} TiB"


def log(msg: str) -> None:
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def is_claude_binary(pid: int) -> bool:
    """Check if /proc/pid/exe points to a Claude Code binary."""
    try:
        exe = os.readlink(f"/proc/{pid}/exe")
        # Claude installs to ~/.local/share/claude/versions/<ver>
        return "/claude/" in exe
    except (FileNotFoundError, PermissionError, OSError):
        return False


def find_claude_processes() -> list[tuple[int, str]]:
    """Scan /proc for Claude Code processes.

    Identifies by checking /proc/pid/exe for the claude binary path,
    then falls back to checking /proc/pid/comm for 'claude'.
    Excludes this watchdog script's own PID.
    """
    results = []
    my_pid = os.getpid()
    try:
        entries = os.listdir("/proc")
    except OSError:
        return results

    for entry in entries:
        if not entry.isdigit():
            continue
        pid = int(entry)
        if pid == my_pid:
            continue
        try:
            # Primary check: exe symlink points to claude binary
            if is_claude_binary(pid):
                raw = Path(f"/proc/{pid}/cmdline").read_bytes()
                cmdline = raw.decode("utf-8", errors="replace")
                results.append((pid, cmdline.replace("\x00", " ").strip()))
                continue

            # Fallback: comm is "claude" (catches renamed/repackaged binaries)
            comm = Path(f"/proc/{pid}/comm").read_text().strip()
            if comm == "claude":
                raw = Path(f"/proc/{pid}/cmdline").read_bytes()
                cmdline = raw.decode("utf-8", errors="replace")
                # Exclude scripts that mention claude (like this watchdog)
                if "python" not in cmdline.lower() and "watchdog" not in cmdline.lower():
                    results.append((pid, cmdline.replace("\x00", " ").strip()))
        except (FileNotFoundError, PermissionError, ProcessLookupError):
            continue
    return results


def get_rss_bytes(pid: int, page_size: int) -> int | None:
    """Read RSS from /proc/[pid]/statm. Returns bytes or None if gone."""
    try:
        data = Path(f"/proc/{pid}/statm").read_text()
        rss_pages = int(data.split()[1])
        return rss_pages * page_size
    except (FileNotFoundError, PermissionError, IndexError, ValueError):
        return None


def snapshot_proc(pid: int, output_dir: Path) -> list[Path]:
    """Dump useful /proc files before the process dies."""
    ts = time.strftime("%Y%m%d-%H%M%S")
    saved = []
    for name in ("status", "maps", "smaps_rollup", "stat", "io"):
        src = Path(f"/proc/{pid}/{name}")
        dst = output_dir / f"claude-{pid}-{ts}-{name}.txt"
        try:
            dst.write_text(src.read_text())
            saved.append(dst)
        except (FileNotFoundError, PermissionError) as e:
            log(f"  Could not read /proc/{pid}/{name}: {e}")
    return saved


def capture_strace(pid: int, duration: int, output_dir: Path) -> Path | None:
    """Attach strace for `duration` seconds, save output."""
    ts = time.strftime("%Y%m%d-%H%M%S")
    outfile = output_dir / f"claude-strace-{pid}-{ts}.txt"
    log(f"  Attaching strace to PID {pid} for {duration}s -> {outfile}")
    try:
        proc = subprocess.Popen(
            [
                "strace",
                "-p", str(pid),
                "-f",           # follow forks/threads
                "-tt",          # microsecond timestamps
                "-T",           # time spent in syscall
                "-yy",          # decode fd paths and socket addresses
                "-o", str(outfile),
            ],
            stderr=subprocess.PIPE,
        )
        time.sleep(duration)
        proc.send_signal(signal.SIGINT)
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()
        log(f"  strace saved to {outfile}")
        return outfile
    except FileNotFoundError:
        log("  strace not found in PATH -- install it: sudo pacman -S strace")
        return None
    except PermissionError:
        log("  strace permission denied -- run watchdog as root or set ptrace_scope=0")
        return None
    except Exception as e:
        log(f"  strace failed: {e}")
        return None


def send_abort(pid: int) -> None:
    """Send SIGABRT for core dump."""
    log(f"  Sending SIGABRT to PID {pid}")
    try:
        os.kill(pid, signal.SIGABRT)
        log(f"  Signal sent. Use 'coredumpctl list' to find the core.")
    except ProcessLookupError:
        log(f"  PID {pid} already exited")
    except PermissionError:
        log(f"  Permission denied -- you can only signal your own processes")


def check_environment() -> None:
    """Print diagnostic info about the system setup."""
    # ptrace scope
    try:
        scope = Path("/proc/sys/kernel/yama/ptrace_scope").read_text().strip()
        if scope != "0":
            log(f"ptrace_scope={scope} -- strace on non-child processes requires root")
            log("  To relax: sudo sysctl kernel.yama.ptrace_scope=0")
    except (FileNotFoundError, PermissionError):
        pass

    # core pattern
    try:
        pattern = Path("/proc/sys/kernel/core_pattern").read_text().strip()
        if "systemd-coredump" in pattern:
            log("Core dumps managed by systemd-coredump (use 'coredumpctl')")
        else:
            log(f"Core pattern: {pattern}")
    except (FileNotFoundError, PermissionError):
        pass

    # try to make watchdog OOM-resistant (requires root)
    try:
        Path("/proc/self/oom_score_adj").write_text("-900\n")
        log("Watchdog OOM score set to -900 (OOM-resistant)")
    except (PermissionError, OSError):
        log("Cannot lower OOM score (not root) -- watchdog may be killed during OOM")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Monitor Claude Code for runaway memory growth"
    )
    parser.add_argument(
        "--threshold", type=float, default=1.0,
        help="Growth rate threshold in GiB/s to trigger (default: 1.0)",
    )
    parser.add_argument(
        "--interval", type=float, default=0.25,
        help="Polling interval in seconds (default: 0.25)",
    )
    parser.add_argument(
        "--strace-duration", type=int, default=3,
        help="Seconds to capture strace before sending SIGABRT (default: 3)",
    )
    parser.add_argument(
        "--output-dir", type=str, default=".",
        help="Directory for strace and /proc snapshots (default: cwd)",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Detect and report but do not strace or signal",
    )
    parser.add_argument(
        "--log-rss", type=str, default=None,
        help="Path to write a CSV of pid,timestamp,rss_bytes for plotting",
    )
    args = parser.parse_args()

    threshold_bps = args.threshold * 1024**3  # GiB/s -> bytes/s
    page_size = os.sysconf("SC_PAGE_SIZE")
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    rss_log = None
    if args.log_rss:
        rss_log = open(args.log_rss, "w")
        rss_log.write("pid,timestamp,rss_bytes\n")

    print("=" * 60)
    print("Claude Code OOM Watchdog")
    print(f"  Threshold:  {args.threshold} GiB/s")
    print(f"  Interval:   {args.interval}s")
    print(f"  Output dir: {output_dir.resolve()}")
    print(f"  Dry run:    {args.dry_run}")
    print("=" * 60)
    check_environment()
    print()
    log("Monitoring... (Ctrl+C to stop)")
    print()

    tracked: dict[int, TrackedProcess] = {}
    # How many samples fit in a ~4 second window
    window_size = max(2, int(4.0 / args.interval))

    try:
        while True:
            now = time.monotonic()
            wall = time.time()
            claude_procs = find_claude_processes()
            current_pids = set()

            for pid, cmdline in claude_procs:
                current_pids.add(pid)
                rss = get_rss_bytes(pid, page_size)
                if rss is None:
                    continue

                if pid not in tracked:
                    tracked[pid] = TrackedProcess(pid=pid, cmdline=cmdline)
                    log(f"Tracking PID {pid}  RSS={format_bytes(rss)}")
                    # Truncate cmdline for display
                    short = cmdline[:120] + ("..." if len(cmdline) > 120 else "")
                    log(f"  {short}")

                tp = tracked[pid]
                tp.samples.append(Sample(timestamp=now, rss_bytes=rss))

                if rss_log:
                    rss_log.write(f"{pid},{wall:.3f},{rss}\n")
                    rss_log.flush()

                # Keep rolling window
                if len(tp.samples) > window_size:
                    tp.samples = tp.samples[-window_size:]

                # Need at least 4 samples (~1 second) to compute a stable rate
                if len(tp.samples) < 4 or tp.triggered:
                    continue

                # Compute growth rate over the last ~1 second (4 samples)
                recent = tp.samples[-4:]
                dt = recent[-1].timestamp - recent[0].timestamp
                if dt <= 0:
                    continue
                drss = recent[-1].rss_bytes - recent[0].rss_bytes
                rate = drss / dt  # bytes/sec

                if rate > threshold_bps:
                    rate_gibs = rate / 1024**3
                    tp.triggered = True

                    print()
                    print("!" * 60)
                    log(f"RUNAWAY DETECTED: PID {pid}")
                    log(f"  Growth rate: {rate_gibs:.2f} GiB/s")
                    log(f"  RSS: {format_bytes(recent[0].rss_bytes)} -> "
                        f"{format_bytes(recent[-1].rss_bytes)} in {dt:.2f}s")
                    log(f"  CMD: {cmdline[:200]}")
                    print("!" * 60)

                    if args.dry_run:
                        log("  (dry-run mode: not taking action)")
                        continue

                    # Step 1: snapshot /proc before it's gone
                    log("  Snapshotting /proc files...")
                    saved = snapshot_proc(pid, output_dir)
                    for p in saved:
                        log(f"    {p}")

                    # Step 2: strace to capture the hot path
                    pre_strace_rss = rss
                    capture_strace(pid, args.strace_duration, output_dir)

                    # Step 3: re-check RSS — if it stabilized during
                    # the strace window, the GC likely caught up
                    post_strace_rss = get_rss_bytes(pid, page_size)
                    if post_strace_rss is not None:
                        delta = post_strace_rss - pre_strace_rss
                        log(f"  RSS after strace: {format_bytes(post_strace_rss)} "
                            f"(delta: {format_bytes(delta)})")
                        if delta <= 0:
                            log("  RSS stabilized or dropped — GC caught up, not killing")
                            tp.triggered = False  # allow re-detection if it spikes again
                            print()
                            continue

                    # Step 4: still growing — SIGABRT for core dump
                    send_abort(pid)
                    print()

            # Clean up dead processes
            dead = set(tracked.keys()) - current_pids
            for pid in dead:
                log(f"PID {pid} exited, no longer tracking")
                del tracked[pid]

            time.sleep(args.interval)

    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        if rss_log:
            rss_log.close()


if __name__ == "__main__":
    main()
