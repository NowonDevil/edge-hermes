#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SESSION=hermes-gateway
DEBIAN_ENV='export HOME=/root; export HERMES_HOME=/root/.hermes; export PATH=/root/hermes-agent/venv/bin:/root/.local/bin:$PATH; cd /root/hermes-agent'
HERMES_CMD='/root/hermes-agent/venv/bin/python -m hermes_cli.main --profile discordlite'
START_SCRIPT='/data/data/com.termux/files/home/start-hermes-gateway.sh'

echo '[1/5] Stop Edge Hermes gateway if running'
tmux kill-session -t "$SESSION" 2>/dev/null || true
pkill -f "hermes_cli.main --profile discordlite gateway run" 2>/dev/null || true
pkill -f "hermes --profile discordlite gateway run" 2>/dev/null || true
sleep 2

echo '[2/5] Check paths inside Debian/proot'
proot-distro login debian -- bash -lc "$DEBIAN_ENV; echo HERMES_HOME=\$HERMES_HOME; echo python=\$(command -v python); /root/hermes-agent/venv/bin/python -c 'import sys; print(sys.executable)'"

echo '[3/5] Update Hermes'
proot-distro login debian -- bash -lc "$DEBIAN_ENV; $HERMES_CMD update"

echo '[4/5] Doctor'
proot-distro login debian -- bash -lc "$DEBIAN_ENV; $HERMES_CMD doctor"

echo '[5/5] Restart gateway'
"$START_SCRIPT"

echo 'Done. Check with: hermes gateway status inside Debian/proot, or tmux ls in Termux.'
