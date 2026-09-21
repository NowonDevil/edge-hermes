# Hermes auto-start fallback: when Termux is opened after Android boot,
# start sshd and the Hermes gateway if they are not already running.
if [ -z "${HERMES_TERMUX_AUTOSTART_RAN:-}" ]; then
  export HERMES_TERMUX_AUTOSTART_RAN=1
  (
    LOG="/sdcard/hermes-termux-open-autostart.log"
    echo "===== $(date) Termux shell autostart check =====" >> "$LOG" 2>&1
    termux-wake-lock >> "$LOG" 2>&1 || true
    pgrep -x sshd >/dev/null 2>&1 || sshd >> "$LOG" 2>&1 || true
    "$HOME/start-hermes-gateway.sh" >> "$LOG" 2>&1 || true
  ) >/dev/null 2>&1 &
fi
