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

## Termux:Boot / Autostart 설정

부트 스크립트 위치:

```text
/data/data/com.termux/files/home/.termux/boot/04-hermes.sh
```

저장소 원본:

```text
scripts/04-hermes.sh
scripts/start-hermes-gateway.sh
scripts/termux-bashrc-hermes-autostart.sh
```

현재 방식:

1. Android 부팅 후 Autostart 앱 또는 Termux:Boot가 Termux를 백그라운드로 깨운다.
2. `04-hermes.sh`가 `termux-wake-lock`을 먼저 잡는다.
3. watchdog lock 디렉터리에 pidfile을 기록한다.
4. lock은 있는데 pid가 없거나 죽어 있으면 stale lock으로 보고 정리한다.
5. 60초 대기 후 `hermes-gateway` tmux 세션/gateway 프로세스를 확인한다.
6. 없으면 `$HOME/start-hermes-gateway.sh`로 Debian/proot의 Discord gateway를 실행한다.
7. 이후 5분마다 tmux/gateway 상태를 확인한다.

검증 로그:

```text
/sdcard/hermes-boot-schedule.log
/sdcard/hermes-termux-open-autostart.log
```

재부팅 성공 기준:

```text
boot watchdog requested
missing: starting Hermes gateway launcher
Connected as 엣지헤르메스#3379
Gateway running with 1 platform(s)
ok: tmux session hermes-gateway exists
```

실측 예시:

```text
Mon Sep 21 09:16:55 KST 2026 boot watchdog requested
Mon Sep 21 09:17:56 KST 2026 ok: tmux session hermes-gateway exists
2026-09-21 09:17:49 Connected as 엣지헤르메스#3379
2026-09-21 09:18:00 Gateway running with 1 platform(s)
```

수동 검증:

```bash
chmod 755 /data/data/com.termux/files/home/.termux/boot/04-hermes.sh
bash -n /data/data/com.termux/files/home/.termux/boot/04-hermes.sh
bash -n /data/data/com.termux/files/home/start-hermes-gateway.sh
tail -80 /sdcard/hermes-boot-schedule.log
```

Termux 앱을 수동으로 열었을 때도 자동 복구되도록 `.bashrc`에 `scripts/termux-bashrc-hermes-autostart.sh` 내용을 추가한다. 이 fallback은 Termux 앱 자체를 깨우지는 못하지만, 사용자가 Termux를 열면 `sshd`와 Hermes gateway를 자동 확인/시작한다.

주의: `.termux/boot` 아래 executable 백업 파일은 Termux:Boot가 함께 실행할 수 있다. 이전 백업은 `disabled-backups/`로 옮기고 실행 권한을 제거한다.

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
