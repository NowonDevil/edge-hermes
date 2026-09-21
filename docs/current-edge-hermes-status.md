# 현재 엣지헤르메스 상태

- 기록 시각: 2026-09-21T09:28:32+09:00
- 장비 모델: SM-G935K
- Android: 8.0.0 / SDK 26
- proot/Linux: Linux localhost 6.17.0-PRoot-Distro #1 SMP PREEMPT_DYNAMIC Fri, 10 Oct 2025 00:00:00 +0000 aarch64 GNU/Linux
- Python: Python 3.13.5
- Hermes: Hermes Agent v0.21.3 계열
Install directory: /root/hermes-agent
Python: 3.13.5
OpenAI SDK: 2.24.0
Run 'hermes version' for update status.

## 확인된 구성

- `/sdcard` 마운트 확인됨
- Termux wake-lock 명령 확인됨
- Termux:Boot 스크립트 폴더 존재
- 부팅 스크립트 존재 및 실행권한 확인됨
- `start-hermes-gateway.sh` 실행권한 확인됨
- Termux, Termux:Boot, Tailscale 설치 및 실행 상태는 사용자 확인 완료
- Termux, Termux:Boot, Tailscale, Magisk 배터리 최적화 제외는 사용자 확인 완료

## 현재 부팅 스크립트

```text
/data/data/com.termux/files/home/.termux/boot/04-hermes.sh
```

역할: 부팅 후 60초 대기, wake-lock 획득, Termux 홈 런처 실행, `/sdcard/hermes-boot-schedule.log` 기록.

## 주의사항

- Android `settings`/`cmd` Binder 호출은 Magisk root에서도 실패할 수 있음.
- Hermes gateway lifecycle 명령은 실행 중인 gateway 내부에서 직접 호출하면 guard에 막힐 수 있음.
- 토큰, OAuth 파일, SSH 키는 저장소에 포함하지 않음.


## 2026-09-21 재부팅 복구 검증

- 강제 재부팅 후 약 12분 상태에서 gateway 실행 확인.
- `hermes gateway status`: PID `12376`, running.
- watchdog 프로세스: `/data/data/com.termux/files/home/.termux/boot/04-hermes.sh`.
- tmux 세션: `hermes-gateway`.
- Discord 연결:
  - `2026-09-21 09:17:49 Connected as 엣지헤르메스#3379`
  - `2026-09-21 09:18:00 Gateway running with 1 platform(s)`
- boot watchdog 로그:
  - `Mon Sep 21 09:16:55 KST 2026 boot watchdog requested`
  - `Mon Sep 21 09:17:56 KST 2026 ok: tmux session hermes-gateway exists`
- Autostart/Termux:Boot 조합으로 부팅 후 자동복구 성공으로 판단.
