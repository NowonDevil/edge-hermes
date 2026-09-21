#!/data/data/com.termux/files/usr/bin/bash
# Hermes gateway Termux:Boot watchdog. Runs at Android boot, then keeps
# the Termux tmux gateway alive without restarting an already-running one.
PREFIX="/data/data/com.termux/files/usr"
HOME="/data/data/com.termux/files/home"
export PREFIX HOME TERMUX__PREFIX="$PREFIX" TERMUX__HOME="$HOME"
export PATH="$PREFIX/bin:$PATH"
export TMPDIR="$PREFIX/tmp"
export TMUX_TMPDIR="$PREFIX/var/run"
LOG="/sdcard/hermes-boot-schedule.log"
RUNNER="$HOME/start-hermes-gateway.sh"
SESSION="hermes-gateway"
LOCKDIR="$PREFIX/var/run/hermes-gateway-watchdog.lock"

has_tmux_session() {
  tmux has-session -t "$SESSION" 2>/dev/null && return 0
  for sock in "$TMUX_TMPDIR"/tmux-*/default; do
    [ -S "$sock" ] || continue
    tmux -S "$sock" has-session -t "$SESSION" 2>/dev/null && return 0
  done
  return 1
}

(
  echo "===== $(date) boot watchdog requested ====="
  termux-wake-lock 2>/dev/null || true

  if ! mkdir "$LOCKDIR" 2>/dev/null; then
    LOCKPID=""
    [ -r "$LOCKDIR/pid" ] && LOCKPID="$(cat "$LOCKDIR/pid" 2>/dev/null || true)"
    if [ -n "$LOCKPID" ] && kill -0 "$LOCKPID" 2>/dev/null; then
      echo "$(date) watchdog already running pid=$LOCKPID; exiting duplicate"
      termux-wake-unlock 2>/dev/null || true
      exit 0
    fi
    echo "$(date) stale watchdog lock found; removing: $LOCKDIR pid=${LOCKPID:-none}"
    rmdir "$LOCKDIR" 2>/dev/null || rm -rf "$LOCKDIR" 2>/dev/null || true
    if ! mkdir "$LOCKDIR" 2>/dev/null; then
      echo "$(date) failed to acquire watchdog lock after stale cleanup; exiting"
      termux-wake-unlock 2>/dev/null || true
      exit 1
    fi
  fi
  echo "$$" > "$LOCKDIR/pid" 2>/dev/null || true

  trap 'rm -f "$LOCKDIR/pid" 2>/dev/null || true; rmdir "$LOCKDIR" 2>/dev/null || true; termux-wake-unlock 2>/dev/null || true' EXIT
  sleep 60
  while true; do
    if has_tmux_session; then
      echo "$(date) ok: tmux session $SESSION exists"
    elif pgrep -f "[h]ermes_cli.main --profile discordlite gateway run" >/dev/null 2>&1 || pgrep -f "[h]ermes --profile discordlite gateway run" >/dev/null 2>&1; then
      echo "$(date) warning: gateway process exists but tmux session not visible; not launching duplicate"
    else
      echo "$(date) missing: starting Hermes gateway launcher"
      if [ -x "$RUNNER" ]; then
        "$RUNNER"
        RC=$?
      else
        echo "$(date) launcher missing or not executable: $RUNNER"
        RC=127
      fi
      echo "$(date) launcher finished rc=$RC"
    fi
    sleep 300
  done
) >> "$LOG" 2>&1 &
