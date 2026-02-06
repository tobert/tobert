# Commit Message Format Reference

## Subject Line Examples

Variations showing the style across different change types:

```
feat(builtins): add tokens builtin for BPE token counting
feat(builtins): add glob with OutputData::nodes(pattern, path)
feat(kernel): implement background execution with & operator
feat(ipc): implement OutputData deserialization in IPC client
feat(vfs): add VirtualOverlayBackend for embedder /v/* support
```

```
fix: tokens returns structured OutputData::table(INDEX/ID)
fix: add backend fallback to execute_command dispatch
fix: resolve all clippy errors and warnings
fix(parser): handle escaped quotes in double-quoted strings
fix(mcp): reconnect on transport timeout, preserve session
```

```
refactor: make --json a global kernel-level output flag
refactor: unify --json output via OutputData::to_json()
refactor: migrate complex builtins to OutputData
refactor(schema): reorganize kaish.capnp, remove vestigial code
refactor: extract ToolArgs parsing into tools/traits.rs
```

```
docs: restructure builtins docs, remove BUILTINS.md
docs: update builtin count to 66, remove from most places
docs: add structured data to Language Features table
test: add property tests for arithmetic expression overflow
test(parser): snapshot tests for heredoc and subshell nesting
chore: remove dead DisplayHint code after OutputData migration
perf(lexer): batch token allocation, reduce allocs per line
build: pin capnp-rpc to 0.20, fix schema codegen race
```

What makes these effective:
- Type prefix signals the *kind* of change at a glance
- Dense tokens: `OutputData::table(INDEX/ID)` encodes the column schema
- Naming actual types and functions lets a model look them up for context
- Each stands alone in `git log --oneline` without needing the diff

## Commits with Bodies

Use a body when the *why* matters or design decisions need context:

```
refactor: extract output format as kernel-level concern

Output format (--json/--toon) was per-tool, causing duplication.
Now extracted in kernel: extract_output_format() strips flags from
ToolArgs, apply_output_format() transforms ExecResult post-execution.
External commands (no schema) keep flags untouched.

See: tools/traits.rs, interpreter/result.rs, kernel.rs

Co-Authored-By: Claude <claude@anthropic.com>
```

```
feat(kernel): implement scatter/gather parallel execution

散 (scatter) fans commands across async tasks with bounded concurrency.
集 (gather) collects results into structured OutputData::table.
Job isolation via per-job VFS mount at /jobs/{id}/.

Introduces BoundedStream for backpressure. Jobs visible via `ps`
builtin. Cancel with SIGINT propagation through job handle.

Co-Authored-By: Claude <claude@anthropic.com>
```

```
fix(interpreter): variable expansion in pipeline mid-stages

Mid-stage commands in pipelines received stale variable bindings
from the parent scope. Root cause: clone of env happened before
first stage executed. Fix: share env via Arc<RwLock> across stages,
snapshot only for subshell boundaries.

Co-Authored-By: Claude <claude@anthropic.com>
```

The body names specific functions, explains design decisions, and
points to files worth reading. A model summarizing this commit later
has everything it needs without reading the diff.

## Granularity

One logical change per commit. Each commit on main is visible — no squashing.

Split when:
- Refactor + feature → refactor first, then feature on top
- Unrelated changes touched in the same session → separate commits

Keep together when:
- Bug fix + test that proves it → one commit
- Rename + all call sites → one commit
