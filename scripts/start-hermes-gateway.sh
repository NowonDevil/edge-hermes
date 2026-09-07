#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SESSION=hermes-gateway
DEBIAN_ENV='export HOME=/root; export HERMES_HOME=/root/.hermes; export PATH=/root/hermes-agent/venv/bin:/root/.local/bin:$PATH; cd /root/hermes-agent'
HERMES_CMD='/root/hermes-agent/venv/bin/python -m hermes_cli.main --profile discordlite'

tmux kill-session -t "$SESSION" 2>/dev/null || true
pkill -f "hermes_cli.main --profile discordlite gateway run" 2>/dev/null || true
pkill -f "hermes --profile discordlite gateway run" 2>/dev/null || true
sleep 2

tmux new-session -d -s "$SESSION" "proot-distro login debian -- bash -lc \"$DEBIAN_ENV; exec $HERMES_CMD gateway run\""
sleep 25

echo TMUX
tmux ls 2>/dev/null || true
echo LOG
proot-distro login debian -- bash -lc "$DEBIAN_ENV; if [ -f /root/.hermes/profiles/discordlite/logs/gateway.log ]; then tail -100 /root/.hermes/profiles/discordlite/logs/gateway.log | grep -E 'Starting Hermes Gateway|Active profile|Connected as|discord connected|Gateway running|token already in use|ERROR|failed' | tail -30; else echo 'gateway.log not found'; fi"
