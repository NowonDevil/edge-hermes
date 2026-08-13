# 엣지헤르메스

루팅된 Android 스마트폰을 24시간 Hermes Agent 서버로 운영하기 위한 설치·복구·운영 문서입니다. Termux + proot Debian + Tailscale + Termux:Boot 조합으로 Discord gateway/Hermes Agent를 자동 기동합니다.

## 현재 상태 요약

- 기록 시각: 2026-08-13T15:28:09+09:00
- 장비 모델: SM-G935K
- Android: 8.0.0 / SDK 26
- Linux/proot: Linux localhost 6.17.0-PRoot-Distro #1 SMP PREEMPT_DYNAMIC Fri, 10 Oct 2025 00:00:00 +0000 aarch64 GNU/Linux
- Python: Python 3.13.5
- Hermes: Hermes Agent v0.19.1 (2026.7.30)
Install directory: /root/hermes-agent
Python: 3.13.5
OpenAI SDK: 2.24.0
Run 'hermes version' for update status.
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

## 빠른 검증

```bash
python3 --version
/root/hermes-agent/venv/bin/hermes --version
bash -n /data/data/com.termux/files/home/.termux/boot/04-hermes.sh
cat /sdcard/hermes-boot-schedule.log
```
