# skills

Agent skills for Claude Code and other agents that read `SKILL.md`.

## Install

Install with the [`skills`](https://skills.sh) CLI:

```bash
npx skills add ddevdan/skills                      # pick skills interactively
npx skills add ddevdan/skills --skill ship-pr      # one skill
npx skills add ddevdan/skills --skill dispatch dispatch-worker
npx skills add ddevdan/skills -g                   # global, not this project
```

`emoji-code-review` and `ship-pr` use skills from another repo. See [Dependencies](#dependencies).

## Skills

| Skill | What it does |
|---|---|
| [`dispatch`](skills/dispatch) | Turns a ticket queue (Jira, GitHub issues, a PRD) into parallel agent work on isolated worktrees. |
| [`dispatch-worker`](skills/dispatch-worker) | The worker side of `dispatch`. |
| [`ship-pr`](skills/ship-pr) | Takes local work to an open PR that follows the repo's own conventions. |
| [`emoji-code-review`](skills/emoji-code-review) | Code review comments that open with a severity emoji. |
| [`simplified-technical-english`](skills/simplified-technical-english) | Rewrites technical documents into ASD-STE100 Simplified Technical English. |
| [`visual-explainer`](skills/visual-explainer) | Turns text, a concept, or a process into a low-text diagram you read at a glance. |

## Credits

### visual-explainer

The skill's rules come from research on visual explanation. Each paper below was checked in full text, or as an abstract where only that was open.

- Tversky, B. (2011). [Visualizing thought](https://doi.org/10.1111/j.1756-8765.2010.01113.x). *Topics in Cognitive Science*, 3, 499–535. The marks and their meanings (boxes for things, arrows for one-way relations, containers for groups), one meaning per arrow, cycles drawn as rings, and words for what a picture cannot show.
- Franconeri, S., Padilla, L., Shah, P., Zacks, J. M., & Hullman, J. (2021). [The science of visual data communication: what works](https://doi.org/10.1177/15291006211051956). *Psychological Science in the Public Interest*, 22(3), 110–161. Direct labels in place of legends, one highlighted comparison, and the takeaway as the title.
- Hawkins, R. D., Sano, M., Goodman, N. D., & Fan, J. E. (2023). [Visual resemblance and interaction history jointly constrain pictorial meaning](https://doi.org/10.1038/s41467-023-37737-w). *Nature Communications*, 14, 2199. A fixed visual vocabulary that reads faster with repeated use.
- Kim, G., Kim, J., & Kim, Y.-S. (2023). ["Explain what a treemap is"](https://doi.org/10.1145/3544548.3581139). *CHI '23*. Perceived clarity is not comprehension, so the hand-over asks the reader to restate the diagram.
- Hou, G., & Pan, Y. (2025). [What's behind the graphic?](https://doi.org/10.1080/10447318.2025.2466063) *International Journal of Human–Computer Interaction*, 41. Prasetyo, Y. T., et al. (2026). [Matching performance of icon design formats for health communication](https://doi.org/10.1080/1463922x.2026.2614605). *Theoretical Issues in Ergonomics Science*, 27. Literal icons, always beside a label.
- Perra, M., & Brinkman, T. (2021). [Seeing science: using graphics to communicate research](https://doi.org/10.1002/ecs2.3786). *Ecosphere*, 12(10). Fernández Fontecha, A., et al. (2018). [A multimodal approach to visual thinking: the scientific sketchnote](https://doi.org/10.1177/1470357218759808). *Visual Communication*, 18. Abstract nouns rewritten as actors doing visible actions, and a beginning-to-end order for processes.

The word budgets and the six-node limit are working defaults, not research findings. The first design draft came from a [Consensus](https://consensus.app) research summary and a Google Gemini conversation, and was then rewritten against the papers above.

## Dependencies

Two skills call skills from [mattpocock/skills](https://github.com/mattpocock/skills). Install those alongside.

| Skill | Needs | Required |
|---|---|---|
| `emoji-code-review` | [`code-review`](https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review): finds the problems that this skill rewrites as emoji comments. | Yes |
| `ship-pr` | [`pr`](https://github.com/mattpocock/skills/tree/main/skills/engineering/pr): writes the PR body. | No. Without it, `ship-pr` writes a short Summary and Testing body. |

```bash
npx skills add mattpocock/skills --skill code-review pr
```
