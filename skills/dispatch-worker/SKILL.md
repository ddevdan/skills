---
name: dispatch-worker
description: Implement one ticket handed out by /dispatch, inside its worktree, and report back to the orchestrator.
disable-model-invocation: true
---

# Dispatch worker

You implement **one ticket** for the `/dispatch` orchestrator. The orchestrator owns the queue, the review, and the merge; you own the code inside your worktree. Other workers are implementing other tickets in parallel, each in its own worktree.

Your argument is one path:

- a **card** (`.herd/briefs/<id>.md`) → a first run: go to **Implement**.
- a **review** (`.herd/reviews/<id>-<round>.md`) → a fix round: go to **Fix**.

The card is the single source of your ticket's facts: id, ticket text location, worktree, branch, parent, test command, host checks, process guard, report path, orchestrator pane. Keep it open; every `<card: ...>` below means that field.

## Implement

1. Read the ticket text at `<card: ticket>`, and `<card: spec>` when there is one. The ticket text is your scope; the spec is the context it must fit.
2. End your turn. The orchestrator sends `implement` as your next prompt through herdr. Never try to load `implement` with a tool: it is user-only, and the call fails. If a call to it fails anyway, that is a Blocker: never implement without it. When it arrives, implement the ticket with it, with the **Rules** below taking precedence where they differ. Skip its `/code-review` step: reviewing is the orchestrator's job.
3. Before **Finish**, inspect your diff against the ticket. Check changed module interfaces, removed abstractions, and existing stored data or callers that the change must still support. This is a self-check, not `/code-review`.
4. Go to **Finish**.

## Fix

1. Reload your card (`.herd/briefs/<id>.md`, in the same `.herd/` folder as the review) unless it is already in your context, then read every finding in the review.
2. Fix each one under the same **Rules**. A finding you disagree with: leave the code, and explain why under "Deviations" in the report.
3. Go to **Finish**.

## Rules

1. **Tests run only through `<card: test command>`**, from your worktree. It runs the suite in Docker against your worktree, with databases of your own on the user's dev Postgres, alongside every other worker's. To run a subset, change only the test arguments at the end. A resource-contention failure means retry. Leave every container, volume, and other database to the orchestrator: the project's usual test shortcuts and plain `docker compose` commands touch the user's stack.
2. **Stay inside the ticket.** An unrelated problem goes in the report under "Found, not fixed"; the code stays as it is.
3. **Your worktree is your whole world.** Read and commit only inside `<card: worktree>` on `<card: branch>`. Other workers' worktrees and `dispatch/*` branches are unfinished and unreviewed — needing something from them is a Blocker. Pushing and pull requests belong to the orchestrator.
4. **No new dependencies or migrations** unless the ticket asks for them. If the ticket cannot be done without one, that is a Blocker.
5. **Blocked on a question → Blocker.** Write the question at the top of the report under "Blocker" and go straight to **Finish**, instead of guessing.
6. **Leave nothing running.** Run every check that is not in `<card: test command>` — `<card: host checks>`, a dev server for a visual check, anything that does not end by itself in a few seconds — through `<card: process guard>/run-limited.sh <seconds> <command>`, from your worktree. Never use `&`, `nohup`, or your harness's background mode. Exit code `124` means the limit stopped a hung command: write it in the report as a hang. If your harness says a command timed out or was moved to the background, stop it before your next step.

## Finish

Every run ends here — a first run, a fix round, or a Blocker.

1. Unless you are blocked, run the full suite once with `<card: test command>`.
2. Run `<card: process guard>/stop-procs.sh <card: worktree>`. It stops every process still running from your worktree, but not you. It must exit 0.
3. Commit your work to `<card: branch>`.
4. Write `<card: report>`, replacing any earlier version:
   - Blocker (if any)
   - What changed, file by file
   - Every test command you ran, with its result
   - The final full-suite summary line
   - Deviations from the ticket or review, and why
   - Found, not fixed
5. Message the orchestrator — `done`, or `blocked` when the report has a Blocker:

   ```bash
   herdr agent prompt <card: orchestrator pane> "dispatch <card: id>: done — <card: report>"
   ```

   No `--wait`. On `agent_blocked` the orchestrator is waiting on the user: run `herdr agent wait <card: orchestrator pane> --until idle --until working`, then send it again.
6. Reply in the terminal with only the report path.

Done when the orchestrator accepted your message and your last reply is the report path.
