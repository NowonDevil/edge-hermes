#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SESSION="hermes-gateway"
PREFIX="/data/data/com.termux/files/usr"
export PATH="$PREFIX/bin:$PATH"
export TMPDIR="${TMPDIR:-$PREFIX/tmp}"
export TMUX_TMPDIR="${TMUX_TMPDIR:-$PREFIX/var/run}"
DEBIAN_ENV='export HOME=/root; export HERMES_HOME=/root/.hermes; export PATH=/root/hermes-agent/venv/bin:/root/.local/bin:$PATH; cd /root/hermes-agent'
HERMES_CMD='/root/hermes-agent/venv/bin/python -m hermes_cli.main --profile discordlite'
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

has_tmux_session() {
  tmux has-session -t "$SESSION" 2>/dev/null && return 0
  for sock in "$TMUX_TMPDIR"/tmux-*/default /tmp/tmux-*/default; do
    [ -S "$sock" ] || continue
    tmux -S "$sock" has-session -t "$SESSION" 2>/dev/null && return 0
  done
  return 1
}

has_gateway_process() {
  pgrep -f "hermes_cli.main --profile discordlite gateway run" >/dev/null 2>&1 || \
  pgrep -f "hermes --profile discordlite gateway run" >/dev/null 2>&1
}

echo "START $(date) force=$FORCE session=$SESSION TMUX_TMPDIR=$TMUX_TMPDIR"

if [ "$FORCE" != "1" ]; then
  if has_tmux_session; then
    echo "OK: tmux session $SESSION already exists; not restarting. Use --force to restart."
    exit 0
  fi
  if has_gateway_process; then
    echo "OK: gateway process already exists but tmux session not visible; not launching duplicate. Use --force to restart."
    exit 0
  fi
else
  echo "FORCE: stopping existing tmux session/processes before restart"
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  for sock in "$TMUX_TMPDIR"/tmux-*/default /tmp/tmux-*/default; do
    [ -S "$sock" ] || continue
    tmux -S "$sock" kill-session -t "$SESSION" 2>/dev/null || true
  done
  pkill -f '[h]ermes_cli.main --profile discordlite gateway run' 2>/dev/null || true
  pkill -f '[h]ermes --profile discordlite gateway run' 2>/dev/null || true
  sleep 2
fi

tmux new-session -d -s "$SESSION" "proot-distro login debian -- bash -lc \"$DEBIAN_ENV; exec $HERMES_CMD gateway run\""
sleep 25

echo TMUX
if ! tmux ls 2>/dev/null; then
  for sock in "$TMUX_TMPDIR"/tmux-*/default /tmp/tmux-*/default; do
    [ -S "$sock" ] || continue
    tmux -S "$sock" ls 2>/dev/null || true
  done
fi

echo LOG
proot-distro login debian -- bash -lc "$DEBIAN_ENV; if [ -f /root/.hermes/profiles/discordlite/logs/gateway.log ]; then python3 - <<'INNER'
from pathlib import Path
import re
p=Path('/root/.hermes/profiles/discordlite/logs/gateway.log')
lines=p.read_text(errors='replace').splitlines()[-120:]
pat=re.compile(r'Starting Hermes Gateway|Active profile|Connected as|discord connected|Gateway running|token already in use|ERROR|failed', re.I)
for line in [l for l in lines if pat.search(l)][-30:]: print(line)
INNER
else echo 'gateway.log not found'; fi"
