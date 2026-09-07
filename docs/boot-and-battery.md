# Tailscale, Termux:Boot, 배터리 설정

## 필요한 앱

- Termux
- Termux:Boot
- Tailscale
- Magisk

## Tailscale 설정

1. Tailscale 앱 로그인
2. VPN 연결 ON
3. Android VPN 설정에서 가능하면 Tailscale을 항상 켜진 VPN으로 지정
4. “VPN 없이 연결 차단”은 필요할 때만 활성화

재부팅 후 다른 장비에서 확인:

```bash
tailscale ping <phone-name-or-tailscale-ip>
```

## Termux:Boot 설정

부트 스크립트 위치:

```text
/data/data/com.termux/files/home/.termux/boot/04-hermes.sh
```

현재 방식: 부팅 후 60초 대기, wake-lock 획득, `$HOME/start-hermes-gateway.sh` 실행, `/sdcard/hermes-boot-schedule.log` 기록.

예시:

```bash
#!/data/data/com.termux/files/usr/bin/bash
LOG="/sdcard/hermes-boot-schedule.log"
RUNNER="$HOME/start-hermes-gateway.sh"
(
  echo "===== $(date) boot autostart started ====="
  /data/data/com.termux/files/usr/bin/termux-wake-lock 2>/dev/null || true
  sleep 60
  echo "$(date) launching Hermes on boot"
  if [ -x "$RUNNER" ]; then
    "$RUNNER"
    RC=$?
  else
    echo "Launcher missing or not executable: $RUNNER"
    RC=127
  fi
  echo "$(date) launcher finished rc=$RC"
  /data/data/com.termux/files/usr/bin/termux-wake-unlock 2>/dev/null || true
  exit "$RC"
) >> "$LOG" 2>&1 &
```

검증:

```bash
chmod 755 /data/data/com.termux/files/home/.termux/boot/04-hermes.sh
bash -n /data/data/com.termux/files/home/.termux/boot/04-hermes.sh
cat /sdcard/hermes-boot-schedule.log
```

## 배터리 최적화 제외

아래 앱을 배터리 최적화에서 제외한다.

- Termux
- Termux:Boot
- Tailscale
- Magisk

가능하면 백그라운드 실행, 자동 시작, 데이터 절약 모드 제한도 해제한다.

## 안전 업데이트 절차

엣지헤르메스 업데이트는 **Termux에서** 실행한다. Hermes 본체는 Debian/proot 안에 있으므로 `hermes_update.sh`가 내부에서 `proot-distro login debian -- ...`로 진입해 처리한다.

실행 파일 위치:

```text
/data/data/com.termux/files/home/hermes_update.sh
/data/data/com.termux/files/home/start-hermes-gateway.sh
```

기본 사용:

```bash
~/hermes_update.sh
```

처리 순서:

1. `hermes-gateway` tmux 세션과 gateway 프로세스 종료
2. Debian/proot 내부에서 `HOME=/root`, `HERMES_HOME=/root/.hermes` 고정
3. `/root/hermes-agent/venv/bin/python -m hermes_cli.main --profile discordlite update` 실행
4. `doctor` 실행
5. `~/start-hermes-gateway.sh`로 gateway 재시작

수동 gateway 재시작만 필요하면 Termux에서 다음을 실행한다.

```bash
~/start-hermes-gateway.sh
```

주의: gateway 실행 중 직접 `hermes update`를 수행하면 venv 바이너리 패키지나 git 작업트리가 중간 상태로 남을 수 있으므로, 업데이트 전 gateway를 먼저 종료한다.
