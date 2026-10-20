---
name: emoji-code-review
description: 1.1 Code review where every comment opens with an emoji that carries the severity, in the style of the Code Review Emoji Guide. Runs the code-review skill for the findings, then rewrites them as emoji comments ready to paste into GitHub. Use when the user asks for an emoji review, an emoji code review, review comments with emoji, or to turn existing review findings into emoji comments. A plain review request that never mentions emoji belongs to code-review instead.
---

# Emoji Code Review

Two jobs, in order. The `code-review` skill finds the problems. This skill rewrites them as comments where an emoji carries the severity so the prose does not have to.

Do not hunt for findings yourself. Everything inline comes from the `code-review` run, plus one praise pass (step 4).

## Emoji legend

Source: [code-review-emoji-guide](https://github.com/erikthedeveloper/code-review-emoji-guide).

| Emoji | Means | Blocking |
|---|---|---|
| 🔧 | Needs changing before merge | **Yes** |
| ❓ | Real question, needs an answer | **Yes** |
| ♻️ | Concrete refactor suggestion, actionable | Author's call |
| 🤔 💭 | Thinking out loud, alternative idea | No |
| 🌱 | Seed for the future, bigger implications | No |
| 🏕 | Unrelated campground-cleaner opportunity | No |
| 📌 | Out-of-scope concern, stage as follow-up | No, file it |
| 📝 | Explanatory note, fun fact, context | No |
| ⛏ | Nitpick, often better left unsaid | No |
| 😃 👍 💯 | I like this and want you to know | No |

Two emoji block: 🔧 and ❓. When a comment is neither, the emoji says so and the prose stays plain instead of hedging toward the same effect.

## Voice

Plain words, said once. First person, from the reviewer's own point of view: "I think", "I'd expect", "Can you walk me through". Own the opinion instead of dressing it as fact.

- One idea per comment. A `code-review` finding carrying two ideas splits into two emoji.
- Praise (😃) is real feedback. Reach for it when something stood out, and leave it out otherwise.
- A 🔧 stands alone. Compliments go in their own comment.

Guardrails, each with what to write instead:

- Comma, period, or colon where an em dash or `--` wants to go.
- The direct verb: "use", "handle", "speed up". Not "leverage", "delve", "elevate", "seamless", "robust".
- The change stated flat: "Move the read inside the lock." Skip "just", "simply", "obviously", and the "it's not X, it's Y" framing.
- Stop on the last substantive sentence. No sign-off offering further questions.
- Bold a term, not a sentence.

Read [EXAMPLES.md](EXAMPLES.md) before writing the first comment.

## Workflow

### 1. Settle the fixed point

Take it from the user. When they give none, run `git fetch origin` and default to `git merge-base HEAD origin/dev`, or `origin/main` when there is no `dev`. A local `dev` is often stale. State the resolved range back to them before going on.

### 2. Run the code-review skill

If a `code-review` report for this same range is already in the conversation, or the user hands you one, use it and skip to step 3. Say that you reused it. Otherwise invoke the `code-review` skill with that fixed point. It pins the range, finds the spec, and runs its Standards and Spec sub-agents in parallel. Wait for its aggregated report.

Two things that stop it, each with what to do:

- **`docs/agents/issue-tracker.md` missing.** Tell the user, then run `code-review` anyway with the spec source named directly (a path they pass, or a spec file under `docs/`, `specs/`, `.scratch/`). If there is no spec, say so and take the Standards axis alone.
- **Empty diff or a ref that does not resolve.** Report it and stop. Do not fall back to reviewing the working tree.

Keep the raw report. Every inline comment traces to one finding in it.

### 3. Map each finding to an emoji

One finding, one comment. A finding with two ideas becomes two comments.

| Finding in the `code-review` report | Emoji |
|---|---|
| Standards: hard breach of a documented repo standard | 🔧 |
| Standards: baseline smell, with a fix worth naming | ♻️ |
| Standards: baseline smell, no fix you would commit to | 🤔 |
| Spec: requirement missing or only partly done | 🔧 |
| Spec: requirement implemented wrong | 🔧 |
| Spec: behaviour nobody asked for (scope creep) | ❓ |
| Either axis: you cannot tell whether it is deliberate | ❓ |
| Either axis: real but lands after this change ships | 🌱 |
| Pre-existing problem the diff touches | 🏕 |
| Anything outside the range | 📌 or dropped |
| Context the author will want, no action | 📝 |
| Naming or style no tool enforces | ⛏ |

A 🔧 or ❓ that claims runtime behaviour ("returns a 500", "leaks") needs evidence in the report: a repro, a test, or a cited line. Without it, say in the comment what you did not check. When only input a real user cannot produce triggers it, use 🤔 instead.

Rewrite the sub-agent's prose in the voice above. Do not paste it. Findings are written for a reader of the whole report; a comment is read next to one line.

A finding that anchors to no line, such as a requirement with no code, keeps its emoji and goes to the summary comment in step 6 instead of inline.

### 4. Add the praise pass

`code-review` reports problems only, so 😃 has no source in it. Read the diff once for what stood out and write those comments yourself. None is a fine answer.

### 5. Print to the terminal

Grouped by file, blocking comments first, opening with the blocking count. Each comment gets a `path:line` heading and a fenced block holding the comment body, so the author can copy one straight into GitHub with its backticks intact.

`code-review` keeps Standards and Spec apart on purpose, and file grouping mixes them. Keep the separation two ways:

- Tag each comment with the axis it came from, `[standards]` or `[spec]`, after the `path:line` heading.
- Report the counts per axis, and the worst finding within each. Do not name a single worst across both.

Also report the finding count taken from the report and the count of comments written, so a dropped finding is visible.

Close with a legend covering only the emoji this review used, one row each, in legend order. Copy the Means column above verbatim so the two never drift.

### 6. Ask whether to post

Only after an explicit yes:

- `gh pr view --json number,headRefOid` for the PR and commit.
- Inline each blocking and ♻️ comment via `gh api repos/{owner}/{repo}/pulls/{n}/comments` with `path`, `line`, `side`, `commit_id`.
- Collect ⛏ 🏕 📌 📝 😃, plus every finding that anchors to no line, into one `gh pr comment` summary so the diff stays readable. End that summary with the same legend.

Posting waits for confirmation every run. Resolving threads and approving stay with the human reviewer.

## Scope

The range comes from step 1 and `code-review` holds it. Pre-existing problems the diff touches go to 🏕. Unrelated ones go to 📌 or get dropped.
