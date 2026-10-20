# skills

Agent skills for Claude Code and other agents that read `SKILL.md`.

| Skill | What it does |
|---|---|
| [`dispatch`](skills/dispatch) | Turns a ticket queue (Jira, GitHub issues, a PRD) into parallel agent work on isolated worktrees. |
| [`dispatch-worker`](skills/dispatch-worker) | The worker side of `dispatch`. |
| [`ship-pr`](skills/ship-pr) | Takes local work to an open PR that follows the repo's own conventions. |
| [`emoji-code-review`](skills/emoji-code-review) | Code review comments that open with a severity emoji. Uses a `code-review` skill for the findings. |
| [`simplified-technical-english`](skills/simplified-technical-english) | Rewrites technical documents into ASD-STE100 Simplified Technical English. |
