# skills

Agent skills for Claude Code and other agents that read `SKILL.md`.

| Skill | What it does |
|---|---|
| [`dispatch`](skills/dispatch) | Turns a ticket queue (Jira, GitHub issues, a PRD) into parallel agent work on isolated worktrees. |
| [`dispatch-worker`](skills/dispatch-worker) | The worker side of `dispatch`. |
| [`ship-pr`](skills/ship-pr) | Takes local work to an open PR that follows the repo's own conventions. |
| [`emoji-code-review`](skills/emoji-code-review) | Code review comments that open with a severity emoji. |
| [`simplified-technical-english`](skills/simplified-technical-english) | Rewrites technical documents into ASD-STE100 Simplified Technical English. |

## Dependencies

Two skills call skills from [mattpocock/skills](https://github.com/mattpocock/skills). Install those alongside.

| Skill | Needs | Required |
|---|---|---|
| `emoji-code-review` | [`code-review`](https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review): finds the problems that this skill rewrites as emoji comments. | Yes |
| `ship-pr` | [`pr`](https://github.com/mattpocock/skills/tree/main/skills/engineering/pr): writes the PR body. | No. Without it, `ship-pr` writes a short Summary and Testing body. |

```bash
npx skills add mattpocock/skills --skill code-review pr
```
