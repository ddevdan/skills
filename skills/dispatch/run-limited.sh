#!/usr/bin/env bash
# Usage: run-limited.sh <seconds> <command> [args...]
# Runs the command with stdin closed, in its own process group. When the time
# limit ends, it stops the whole group (bunx -> node -> workers), not only the
# first process. Exit code 124 means the limit was hit.
secs=$1; shift
flag=$(mktemp); rm -f "$flag"
set -m
set +b
"$@" </dev/null & pid=$!
( sleep "$secs"; touch "$flag"; kill -TERM -- -"$pid" 2>/dev/null; sleep 5; kill -KILL -- -"$pid" 2>/dev/null ) & dog=$!
wait "$pid" 2>/dev/null; rc=$?
kill -- -"$dog" 2>/dev/null; wait "$dog" 2>/dev/null
if [ -e "$flag" ]; then rm -f "$flag"; echo "run-limited: stopped after ${secs}s: $*" >&2; exit 124; fi
exit $rc
