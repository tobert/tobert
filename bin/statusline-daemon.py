#!/usr/bin/env python3
"""
Statusline Daemon - polls system stats, serves summaries over Unix socket.

Collects CPU usage at 100ms intervals, maintains 1 minute of history,
and serves pre-computed summaries to statusline scripts on connect.

Usage:
    ./statusline-daemon.py

Socket:
    /run/user/$UID/statusline.sock

On connect, immediately sends JSON and closes:
    {
        "cpu_heatmap": [12, 45, 23, ...],  # 16 values, 0-100
        "cpu_current": 23,                  # latest CPU %
        "rainbow_offset": 3,                # 0-7, shifts every ~2s
        "uptime_ms": 123456                 # daemon uptime
    }
"""

import asyncio
import json
import os
import time
from collections import deque
from pathlib import Path

# =============================================================================
# Configuration
# =============================================================================

POLL_INTERVAL = 0.1  # 100ms
HISTORY_SIZE = 600   # 1 minute at 100ms
HEATMAP_CELLS = 16   # cells to return in heatmap
SOCKET_PATH = Path(f"/run/user/{os.getuid()}/statusline.sock")

# =============================================================================
# CPU Stats
# =============================================================================

def read_proc_stat() -> tuple[int, int]:
    """Read /proc/stat and return (total_time, idle_time)."""
    with open("/proc/stat") as f:
        line = f.readline()  # First line is aggregate CPU

    # cpu user nice system idle iowait irq softirq steal guest guest_nice
    parts = line.split()
    times = [int(x) for x in parts[1:]]

    idle = times[3] + times[4]  # idle + iowait
    total = sum(times)

    return total, idle


def calc_cpu_percent(prev: tuple[int, int], curr: tuple[int, int]) -> int:
    """Calculate CPU usage percent between two samples."""
    total_delta = curr[0] - prev[0]
    idle_delta = curr[1] - prev[1]

    if total_delta <= 0:
        return 0

    usage = ((total_delta - idle_delta) * 100) // total_delta
    return max(0, min(100, usage))


# =============================================================================
# Stats Collector
# =============================================================================

class StatsCollector:
    def __init__(self):
        self.cpu_history: deque[int] = deque(maxlen=HISTORY_SIZE)
        self.prev_stat: tuple[int, int] | None = None
        self.start_time = time.time()

    def poll(self):
        """Take a single CPU sample."""
        curr = read_proc_stat()

        if self.prev_stat is not None:
            pct = calc_cpu_percent(self.prev_stat, curr)
            self.cpu_history.append(pct)

        self.prev_stat = curr

    def get_heatmap(self, cells: int = HEATMAP_CELLS) -> list[int]:
        """Get downsampled CPU history for heatmap display."""
        if not self.cpu_history:
            return [0] * cells

        history = list(self.cpu_history)

        if len(history) <= cells:
            # Pad with zeros on the left (oldest)
            return [0] * (cells - len(history)) + history

        # Downsample: divide into `cells` buckets, average each
        bucket_size = len(history) / cells
        result = []

        for i in range(cells):
            start = int(i * bucket_size)
            end = int((i + 1) * bucket_size)
            bucket = history[start:end]
            avg = sum(bucket) // len(bucket) if bucket else 0
            result.append(avg)

        return result

    def get_summary(self) -> dict:
        """Get current stats summary as dict."""
        heatmap = self.get_heatmap()

        return {
            "cpu_heatmap": heatmap,
            "cpu_current": heatmap[-1] if heatmap else 0,
            "rainbow_offset": int(time.time() / 2) % 8,
            "uptime_ms": int((time.time() - self.start_time) * 1000),
        }


# =============================================================================
# Server
# =============================================================================

async def handle_client(
    reader: asyncio.StreamReader,
    writer: asyncio.StreamWriter,
    stats: StatsCollector,
):
    """Handle a client connection - send JSON summary and close."""
    try:
        data = json.dumps(stats.get_summary())
        writer.write(data.encode() + b"\n")
        await writer.drain()
    except Exception:
        pass
    finally:
        writer.close()
        try:
            await writer.wait_closed()
        except Exception:
            pass


async def poll_loop(stats: StatsCollector):
    """Continuously poll CPU stats."""
    while True:
        stats.poll()
        await asyncio.sleep(POLL_INTERVAL)


async def main():
    stats = StatsCollector()

    # Clean up stale socket
    if SOCKET_PATH.exists():
        SOCKET_PATH.unlink()

    # Ensure parent directory exists
    SOCKET_PATH.parent.mkdir(parents=True, exist_ok=True)

    # Start polling task
    poll_task = asyncio.create_task(poll_loop(stats))

    # Start Unix socket server
    server = await asyncio.start_unix_server(
        lambda r, w: handle_client(r, w, stats),
        path=str(SOCKET_PATH),
    )

    print(f"Listening on {SOCKET_PATH}")

    try:
        async with server:
            await server.serve_forever()
    finally:
        poll_task.cancel()
        if SOCKET_PATH.exists():
            SOCKET_PATH.unlink()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nShutdown")
