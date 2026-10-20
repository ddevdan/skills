#!/usr/bin/env bash
# Usage: stop-procs.sh <dir>
# Stops every process of this user whose command line or working directory is
# inside <dir>, plus their descendants. Never stops its own caller chain, so a
# worker may run it from inside its own worktree. Prints what it stopped.
# Exit 1 if something survives.
raw=${1%/}; real=$(cd "$raw" 2>/dev/null && pwd -P || echo "$raw"); real=${real%/}
# this script and every ancestor (the calling shell, the agent) stay alive
skip=$(p=$$; while [ "$p" -gt 1 ] 2>/dev/null; do echo "$p"; p=$(ps -o ppid= -p "$p" | tr -d ' '); done)
keep_out() { grep -vxF "$skip"; }
list() {
  { pgrep -f -- "$raw/"; pgrep -f -- "$real/"
    lsof -a -d cwd -u "$(id -u)" -Fpn 2>/dev/null | awk -v a="$raw" -v b="$real" '
      /^p/{p=substr($0,2)}
      /^n/{n=substr($0,2); if (n==a || n==b || index(n, a"/")==1 || index(n, b"/")==1) print p}'
  } | sort -u | keep_out
}
# add every descendant: a child like `sleep` or `node` started by a matched
# process may not name the directory in its command line or cwd
with_children() {
  ps -A -o pid=,ppid= | awk -v seeds="$(echo $1)" '
    BEGIN{n=split(seeds,s," "); for(i=1;i<=n;i++) keep[s[i]]=1}
    {pp[$1]=$2}
    END{do{c=0; for(p in pp) if(!(p in keep) && (pp[p] in keep)){keep[p]=1;c=1}}while(c); for(k in keep) print k}'
}
pids=$(list); [ -n "$pids" ] && pids=$(with_children "$pids" | keep_out)
[ -z "$pids" ] && { echo "stop-procs: nothing running in $raw"; exit 0; }
ps -o pid=,command= -p "$(echo $pids | tr ' ' ,)" | cut -c1-160 | sed 's/^/stop-procs: stopping /'
kill $pids 2>/dev/null; sleep 3
left=$(for p in $pids; do kill -0 $p 2>/dev/null && echo $p; done); [ -n "$left" ] && kill -9 $left 2>/dev/null && sleep 1
left=$(for p in $pids; do kill -0 $p 2>/dev/null && echo $p; done); [ -n "$left" ] && { echo "stop-procs: still alive: $left"; exit 1; }
exit 0
