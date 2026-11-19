# 엣지헤르메스

루팅된 Android 스마트폰을 24시간 Hermes Agent 서버로 운영하기 위한 설치·복구·운영 문서입니다. Termux + proot Debian + Tailscale + Termux:Boot 조합으로 Discord gateway/Hermes Agent를 자동 기동합니다.

## 현재 상태 요약

- 2026-11-19 운영 기준: 갤럭시 S7 · Termux + proot Debian · `discordlite` · **Hermes v0.22.2 고정(업데이트 보류)**.
- [Termux에서 상태 확인·시작하기 / Debian에서 Discord 응답 점검하기](docs/current-edge-hermes-status.md)
- 저장소 목적: 스마트폰 루팅부터 최소 앱 구성, Termux/Tailscale/Termux:Boot, 배터리 설정, Hermes Agent 설치와 자동 시작까지 재현 가능한 절차 보관

## 핵심 구조

```text
Android rooted phone
├─ Magisk/root 권한
├─ Termux
│  ├─ proot Debian
│  │  └─ Hermes Agent
│  ├─ ~/.termux/boot/04-hermes.sh
│  └─ start-hermes-gateway.sh
├─ Termux:Boot
└─ Tailscale VPN
```

## 문서 목록

- [루팅 및 ADB 최소 앱 구성](docs/android-rooting-minimal-setup.md)
- [Termux, Python, Hermes Agent 설치](docs/termux-hermes-install.md)
- [Tailscale, Termux:Boot, 배터리 설정](docs/boot-and-battery.md)
- [현재 엣지헤르메스 상태](docs/current-edge-hermes-status.md)

## 운영 원칙

1. 토큰, OAuth 파일, SSH 키, 쿠키, 계정 DB는 저장소에 넣지 않는다.
2. ADB debloat는 삭제보다 `pm disable-user --user 0`를 우선한다.
3. Termux:Boot는 Hermes 자동 시작 담당, Tailscale 자동 연결은 Android VPN/앱 설정 담당으로 분리한다.
4. Google Drive 결과물은 `헤르메스/엣지헤르메스/<작업별 하위폴더>/`에 정리한다.
5. 설정 변경 후에는 반드시 재부팅 테스트와 `/sdcard/hermes-boot-schedule.log` 확인을 한다.


## 운영 스크립트

Termux 홈에서 실행하는 스크립트는 저장소 `scripts/`에 원본을 보관한다. 실제 폰에서는 `/data/data/com.termux/files/home/` 아래에 두고 실행한다.

평소에는 Termux에서 `tmux ls`로 확인하고, 꺼져 있을 때만 `~/start-hermes-gateway.sh`로 시작한다. `hermes_update.sh`는 복구·유지보수용이며 업데이트 보류 중에는 실행하지 않는다.

## 빠른 검증

```bash
python3 --version
/root/hermes-agent/venv/bin/hermes --version
bash -n /data/data/com.termux/files/home/.termux/boot/04-hermes.sh
cat /sdcard/hermes-boot-schedule.log
```

## 변경 이력


- 2026-09-21: 주간 재부팅 후 게이트웨이 미기동 문제를 진단하고, Termux:Boot watchdog에 stale lock 정리와 pidfile 기반 중복 실행 방지를 추가했다. Autostart 앱/Termux:Boot 조합으로 재부팅 후 약 2분 내 Discord gateway 자동 연결을 확인했다.
- 2026-09-07: 엣지헤르메스 업데이트 중 gateway/venv/import 경로가 꼬이지 않도록 Termux 실행용 `hermes_update.sh`를 추가하고 `start-hermes-gateway.sh`에 `HOME`, `HERMES_HOME`, venv Python 실행 경로를 고정했다.
