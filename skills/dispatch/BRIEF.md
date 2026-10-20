# Card template

Copy into `.herd/briefs/<id>.md` and fill every `<...>` slot. The worker's rules live in `/skill:dispatch-worker`; the card carries only this ticket's facts.

---

# Card: <ID>

- **id**: `<id>`
- **title**: <title>
- **ticket**: `<abs path to .herd/queue.md>`, under `## <id>`
- **spec**: <the parent spec or PRD the ticket belongs to (path or URL), or "none">
- **worktree**: `<abs path to worktree>`
- **branch**: `dispatch/<id>`
- **parent**: `<parent>`
- **test command**: `<test command with <id> and <db> filled in>`
- **host checks**: <each host check from the queue, wrapped in `<abs path to .herd/bin>/run-limited.sh`, or "none">
- **process guard**: `<abs path to .herd/bin>`
- **report**: `<abs path to .herd/reports/<id>.md>`
- **orchestrator pane**: `<your $HERDR_PANE_ID>`
