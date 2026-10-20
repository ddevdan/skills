---
name: dispatch
description: Dispatch tickets to parallel pi workers (/dispatch-worker) in herdr, review each delivery with /code-review, and squash-merge approved work into the parent branch.
disable-model-invocation: true
---

# Dispatch

You are the orchestrator. The pi agents implement; you own the **queue**, the **review**, and the **merge**. You do not write ticket code yourself, and you never open a PR — the user does that.

An agent's report is **hearsay** until your own review corroborates it.

**Run autonomously.** Once Setup is done, run the loop to **Finish** without checking in. Never ask permission for a step this skill names: creating worktrees and panes, dispatching, running tests, reviewing, sending back, merging, cleaning up, updating the ticket source. Do it, record it in the queue, and continue. Stop for the user only when:

- the parent branch is `main` or `master` (Setup 1),
- an agent is `blocked` at an approval or question UI,
- a report has a Blocker,
- a Setup step tells you to stop.

While one ticket waits on the user, keep running every other ticket.

Requires `HERDR_ENV=1`. Load `/herdr` for CLI details when a command below misbehaves.

## Setup

1. **Integration branch** — require a new branch name from the user. If they did not name one, ask before creating the queue or any worktree. Record the checked-out branch as `<base>`, then create and switch the main checkout to the new integration branch:

   ```bash
   git checkout -b <integration-branch> <base>
   ```

   This new branch is `<parent>` for every ticket worktree and every later squash merge. Never use the branch that was checked out when dispatch started as `<parent>`. If `<base>` is `main` or `master`, ask for confirmation before creating the integration branch. If the requested integration branch already exists, ask the user for a different name rather than reusing it. The main checkout stays on the integration branch for the whole run; it is where you merge.
2. **Queue** — turn the tickets, from whatever source the user points at (Jira keys, GitHub issues, a PRD, a ticket list), into `.herd/queue.md`. Add `.herd/` to `.git/info/exclude`. One row per ticket:

   | id | title | depends on | status | agent | pane | worktree |
   |----|-------|------------|--------|-------|------|----------|

   Below the table, each ticket's full text under a `## <id>` heading — the ticket's card points at it. For each ticket, list source-derived acceptance criteria and compatibility requirements for existing data or callers; write `none identified` when the source names none. Status is one of `queued`, `running`, `review`, `fixing`, `merged`, `blocked`.

   Done when every ticket has a row, its full text, and its dependencies read from the source (Jira "blocks" links, "depends on" lines, obvious ordering in a PRD). Tickets that will edit the same files also depend on each other: chain them in `depends on` even when the source is silent.

3. **Test command** — the project's tests run in Docker, and a plain `docker compose run` from a worktree breaks two ways: it mounts whichever checkout it runs from, and every ticket would test against the same database. Each ticket gets its own app container, mounting its own worktree, on the **user's dev stack Postgres**, with its own database named after the worktree. Find how the suite runs today (compose file, Makefile, README) and how the settings read the database name, then build one command that every ticket uses:

   ```bash
   docker compose -p <repo>-<id> -f <compose file> -f <abs path to .herd/compose.test.yaml> \
     run --rm --no-deps -e <db name env var>=<db> <service> <suite, e.g. pytest -n auto>
   ```

   - Run from the worktree, so the compose file's relative bind mounts (`.:/app`) point at the ticket's code, not the main checkout.
   - `<db>` is the worktree name with `-` turned into `_`. pytest-django then creates `test_<db>_gw0`, `test_<db>_gw1`, … so tickets never share a database.
   - `--no-deps` stops each ticket from starting its own Postgres. `.herd/compose.test.yaml` instead points the project's default network at the dev stack's (top level: `networks: {default: {name: <dev project>_default, external: true}}`) and resets `<service>`'s `container_name:` (`container_name: !reset null`), so the database host resolves to your dev Postgres.
   - The mount must not let the container write its dependencies into the worktree: in `.herd/compose.test.yaml`, mask the container's virtualenv and `node_modules` paths with anonymous volumes (e.g. `- /app/backend/.venv`). Add `--build` only on a ticket's first run and after a dependency change.
   - If the settings don't read the database name from an env var, or the tests use other services from the stack (Redis, Celery), stop and tell the user — those need their own per-ticket split.

   Write the command at the top of `.herd/queue.md` with `<id>` and `<db>` left as slots. The dev stack must stay up for the whole run. Done when the command passes on the parent from a throwaway worktree, with `<db>` = `setup`, while the user's own stack is up. Then remove that worktree the same way Merge cleans up a ticket (`stop-procs.sh`, `git worktree remove --force`), so no later run finds it in place.

4. **Process guard** — copy [run-limited.sh](run-limited.sh) and [stop-procs.sh](stop-procs.sh) from this skill's folder into `.herd/bin/` and make them executable. If the project also has checks that run on the host, outside Docker (type checks such as `svelte-check` or `tsc`, frontend unit tests, Playwright), write each one at the top of `.herd/queue.md` under the test command, already wrapped: `.herd/bin/run-limited.sh <seconds> <check>`. Give each one a limit of about 3× its normal run time. Done when each host check passes once from the throwaway worktree through its wrapper.

The queue is the single source of truth. Update it on every state change — it is what survives a compaction.

## Long-running commands

A run lasts hours, and a process that you start and lose keeps its CPU and memory until somebody kills it — after the run, after the session. macOS has no `timeout` command: `timeout 280 <cmd>` only fails with `command not found`.

- Run every command that does not end by itself in a few seconds — test runners, type checkers, builds, Playwright, dev or preview servers — through `.herd/bin/run-limited.sh <seconds> <command>`. It closes stdin (Vitest hangs while stdin is open) and, at the limit, stops the whole process group, children included. Exit code `124` means the limit stopped it: report that as a hang, not as a test result.
- Never start a process with `&`, `nohup`, `( … &)`, or your harness's background mode. If you need a server for a visual check, start it through `run-limited.sh` too.
- Run checks inside the ticket's worktree, not in the main checkout.
- If your harness reports that a command timed out or "was moved to the background", stop that command in the same turn — by its task ID, or `pkill -f '<a distinctive part of the command>'` — and confirm with `pgrep -fl` that nothing is left. Never run `stop-procs.sh` on the main checkout: the user's own servers run there.

## The loop

A ticket is **ready** when it is `queued` and every ticket it depends on is `merged`. Dispatch every ready ticket at once — there is no concurrency cap. Re-check readiness after every merge.

### 1. Dispatch

For each ready ticket, with `<id>` lowercased to fit herdr's name rule (`[a-z][a-z0-9_-]{0,31}`):

```bash
WT="$(git rev-parse --show-toplevel)/../$(basename "$(git rev-parse --show-toplevel)").worktrees/<id>"
git worktree add -b dispatch/<id> "$WT" <parent>
herdr pane split <target> --direction <dir> --ratio <r> --cwd "$WT" --no-focus   # read .result.pane.pane_id
herdr agent start <id> --kind pi --pane <pane_id> -- --model openai-codex/gpt-5.6-luna:high
```

**Every** agent you start lives in your tab — implementers, and any reviewer agents `/code-review` needs. A reviewer agent calls back like a worker: its prompt ends with `herdr agent prompt <your $HERDR_PANE_ID> 'dispatch <id>-review: done — <findings path>'`. Never `herdr tab create` except for the overflow case below. You keep the left side; agents stack in a column on the right. `--ratio` is the share the split pane **keeps**.

- **First agent** (no live agent pane): `<target>` = `--current`, `--direction right --ratio 0.65`.
- **Every next agent**: `<target>` = the tallest live agent pane (`herdr pane layout --pane "$HERDR_PANE_ID"`), `--direction down --ratio 0.5`.
- If the tallest agent pane is under 10 rows, the column is full: put the agent in its own tab instead (`herdr tab create --cwd "$WT" --label <id> --no-focus`, pane from `.result.root_pane.pane_id`).

Worktrees live beside the repo, not inside it, so the main checkout's tools never collect their files. A new worktree has no untracked files, so copy the ones the stack needs into `$WT` (`.env` and the like — whatever the setup test run needed).

Write the ticket's card to `.herd/briefs/<id>.md` from [BRIEF.md](BRIEF.md). Done when every field is filled and no `<...>` slot is left. The worker's rules live in the `dispatch-worker` skill, not the card. Start the worker — no `--wait`; the prompt returns once herdr has submitted it:

```bash
herdr agent prompt <id> "/skill:dispatch-worker <abs path to .herd/briefs/<id>.md>"
```

Set the row to `running`.

All communication with workers goes through herdr. When a worker finishes, it messages you with `herdr agent prompt`, and the message arrives in your input as a **callback**: `dispatch <id>: done — <report path>` or `dispatch <id>: blocked — <report path>`. The callback is your only completion signal — no background waits, log files, or polling.

### 2. Review

A callback is an order to act **in that same turn**: run Review for that ticket through to Send back or Merge, then dispatch whatever became ready. Acknowledging it ("received, I'll review it") and ending the turn leaves the run stalled — nothing else will wake you.

End a turn only when every ticket is `running` or `fixing` (waiting on its callback), `merged`, or waiting on the user. On each callback, also run `herdr agent list`: a worker in `blocked` is stuck at an approval or question UI and cannot call back — read it with `herdr agent read` and ask the user.

Read `.herd/reports/<id>.md` and set the row to `review`.

If the report raises a blocker question, set `blocked` and put the question to the user. Otherwise review, in the worktree:

1. Read the full diff against the parent: `git -C "$WT" diff <parent>...HEAD`.
2. Rerun the tests yourself: the test command, from the worktree, with the ticket's `<id>` and `<db>`.
3. Check the diff against every acceptance criterion in the ticket text.
4. Run `/code-review` with `<parent>` as the fixed point and the worktree as the changes under review.

Done when all four have run and every finding is written to `.herd/reviews/<id>-<round>.md`. Zero findings → go to **Merge**.

### 3. Send back

Findings go back to the **same** agent — it keeps its context. Set the row to `fixing` and prompt it — no `--wait`:

```bash
herdr agent prompt <id> "/skill:dispatch-worker <abs path to .herd/reviews/<id>-<round>.md>"
```

Its callback sends you back to **Review**. Repeat until the review comes back clean.

### 4. Merge

In the main checkout, on the parent:

```bash
git merge --squash dispatch/<id>
git commit -m "<ID>: <title>"     # GitHub issue: add -m "Closes #<n>"
```

For a GitHub issue, the `Closes #<n>` line closes the issue automatically when the user's PR merges.

**Conflict** → `git reset --merge`, write one finding to `.herd/reviews/<id>-<round>.md` — "merge `<parent>` into your branch and resolve the conflicts in `<files>`" — and **Send back**. Then **Review** again from the top.

On a clean commit, clean up:

```bash
docker compose -p <repo>-<id> down -v --rmi local --remove-orphans   # from $WT: the ticket's image and volumes
# drop every leftover test_<db>* database on the dev Postgres (psql via docker compose exec)
herdr pane close <pane_id>     # and every reviewer pane for this ticket; herdr tab close for an overflow tab
.herd/bin/stop-procs.sh "$WT"    # servers, test runners, type checkers still running from the worktree
git worktree remove --force "$WT"   # --force: the copied .env files are untracked
git branch -D dispatch/<id>     # -D: a squash merge leaves the branch looking unmerged
```

`stop-procs.sh` must exit 0 before you remove the worktree; if it exits 1, `kill -9` the PIDs it names. Set the row to `merged`, then update the ticket at its source: comment with the squash commit SHA and the parent branch, and move it to the source's review state (Jira: the "In Review" transition from `getTransitionsForJiraIssue`; a GitHub issue: comment only, left open — the `Closes #<n>` line closes it when the PR merges). The user closes Jira tickets when their PR lands. A PRD or ticket list has no source to update — skip it.

Then dispatch every ticket that just became ready.

## Finish

The run is over when every row is `merged` or `blocked`. Before you report, sweep: run `.herd/bin/stop-procs.sh` on every worktree path in the queue that still exists (blocked tickets keep their worktree, but nothing may keep running in it), and run `pgrep -fl` for each host check command from Setup 4. Stop anything the run started.

Report to the user: the merged commits on the parent (`git log --oneline`), each ticket whose source update failed, each blocked ticket with its open question, anything the agents flagged outside their ticket, and every worktree still in place with the reason. For GitHub issues, also give one `Closes #<n>` line per merged issue, ready to paste into the PR description. The PR is theirs to open.
