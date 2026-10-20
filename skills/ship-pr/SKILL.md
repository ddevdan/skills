---
name: ship-pr
description: Take local work through to an open PR — create a branch, commit, push, and open a PR whose branch name, commit messages, title, and body follow the repo's own conventions (PR template, CONTRIBUTING, commit history). Use when the user says "ship this", "open a PR", "create a PR", "branch and commit", "make a PR for these changes", or wants staged/working changes or an unpushed branch turned into a reviewable pull request.
---

# Ship PR

Turn local work into an open PR: learn the repo's conventions → branch → commit → push → PR with a succinct, template-aligned body.

Nothing here is repo-specific. Every naming, format, and base-branch choice comes from [Discover conventions](#discover-conventions).

## Workflow

Run these as a TodoWrite checklist. **Stop for explicit user go-ahead before step 6 (push) and step 7 (PR).**

1. **Inspect.** `git status` + `git diff` (staged and unstaged) + `git log --oneline @{u}..HEAD 2>/dev/null` (unpushed commits). Understand what changed and why. If there is nothing to commit and nothing unpushed, say so and stop.
2. **Discover conventions.** Follow [Discover conventions](#discover-conventions). Summarize what you found in 3–5 lines (branch form, commit form, base branch, template path, ticket tracker).
3. **Check for an existing PR on the current branch.** `gh pr list --head "$(git rev-parse --abbrev-ref HEAD)" --state open --json number,title,url`. If one exists, this is an **update**: stay on this branch, skip step 4, commit + push to it, and **skip `gh pr create`** in step 7. Tell the user you'll update PR #N.
4. **Create branch.** *(New PR only — skip if already on a feature branch that holds this work.)* Propose a branch name in the repo's form, **ask the user to confirm**, then `git checkout -b <branch>`. Never commit straight to the base branch.
5. **Commit, scoped by change.** If the branch already holds the commits (e.g. made by another skill) and nothing of this change is left in the tree, skip to step 6; reword unpushed subjects that break the repo's commit form. Otherwise group the changes and commit per [Scoping commits](#scoping-commits). Do not stage unrelated work. **Never add a `Co-Authored-By` trailer.**
6. **Push** — *after go-ahead*: `git push -u origin <branch>` (plain `git push` when the branch already tracks a remote).
7. **Open or update the PR** — *after go-ahead*:
   - **No existing PR:** `gh pr create --base <base> --title <title> --body-file <file>`, with title and body from [PR title and body](#pr-title-and-body).
   - **Existing PR:** the push already updated it. Run `gh pr edit <number>` only if this change materially alters the PR's scope; otherwise leave title/body as-is.
8. **Report.** Print the PR URL and the base it targets.

## Discover conventions

Read what the repo documents first, then confirm against what it actually does. Documented rules win over observed habits; observed habits fill the gaps.

**Documented sources** — read whichever exist:

- PR template: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md` (several templates → pick the one matching the change, or ask), `docs/pull_request_template.md`, `pull_request_template.md` at the root. Match case-insensitively.
- Contributor guides: `CONTRIBUTING.md` (root, `.github/`, `docs/`), `AGENTS.md`, `CLAUDE.md` — look for branch, commit, and PR sections.
- Commit rules: `commitlint.config.*` / `.commitlintrc*`, a `commitlint` key in `package.json`, `.gitmessage` (or `git config commit.template`), `.cz.toml` / commitizen config, `lefthook.yml` / `.husky/commit-msg` hooks.

**Observed sources:**

- Commit form: `git log --oneline -20 <base>` — Conventional Commits (`feat(scope): ...`), ticket tag (`[ABC-123] ...` or `ABC-123: ...`), or plain imperative.
- Branch form: `git branch -r --sort=-committerdate | head -15` — e.g. `ABC-123-kebab-summary`, `feat/kebab-summary`, `user/topic`.
- Recent PRs: `gh pr list --state merged -L 5 --json title,body,baseRefName,headRefName` — title form, how tickets are linked (`Closes #12`, a Jira URL, a Linear key), and which base PRs usually target.
- Default branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, or `git symbolic-ref refs/remotes/origin/HEAD`.

**Base branch.** The branch this one was cut from. Usually the default branch (or the integration branch recent PRs target, e.g. `dev`). When the branch is stacked on another unmerged feature branch, use that parent as the base so the PR shows only this branch's commits. State the base you chose before step 7.

**Ticket.** If the conventions use a ticket key, infer it from the conversation, branch name, or recent commits. If none exists, use the descriptive form and flag the missing ticket to the user.

## Scoping commits

One commit = one logical change. Don't dump the whole working tree into a single commit.

1. Read the full diff and **group hunks by concern** — feature vs. refactor vs. test vs. config vs. fix vs. docs. A reviewer should be able to read any one commit in isolation.
2. Stage each group on its own. Prefer file-level staging (`git add <paths>`); use `git add -p` to split a file that mixes concerns. (`git add -i` is not available here.)
3. Commit each group with a subject in the repo's commit form, scoped to that change.
4. Order commits so the branch builds/tests green at each step where practical (deps before consumers).
5. After staging each group, run `git status` to confirm only the intended paths are staged before committing.

If the change is genuinely atomic (single concern), one commit is correct — don't split for its own sake.

## PR title and body

**Title:** the repo's PR title form from recent PRs; usually the same as the (main) commit subject, including any ticket tag.

**Body:** invoke the `pr` skill to write the content (Summary visual, Evidence, Merge Danger), then fit it to the repo:

- **No repo template:** use the `pr` skill's body as-is, plus the ticket link the way recent PRs link it.
- **Repo template exists:** the template's section **headers** and order win. Put the `pr` content into the matching sections — Summary into the summary/changes section, Evidence into the testing section, Merge Danger into a risk section or as a final section if none exists. Keep the template's ticket-link line and required checklists (tick only what is actually true). **Drop optional sections that don't apply** (e.g. screenshots for a backend change). Keep every section tight.
- **User supplies a body:** use it, but still keep the template's ticket-link line. Tell the user before creating the PR if you dropped any template section.

If the `pr` skill is not available, write a short Summary + Testing body in the template's shape.

Write the body to a temp file and pass `--body-file` to avoid shell-quoting issues.

## Guardrails

- **Stop before push and before `gh pr create`** — both are outward-facing. Get explicit go-ahead; one go-ahead covers both only if the user says so.
- Don't commit secrets, `.env`, or unrelated working-tree changes — show the file list and confirm if anything looks off.
- **An open PR already exists for the current branch ⇒ update it, never open a second.**
