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

## 2026-10-19 doctor 이슈 조치 및 proot statx 한계 확인

- Hermes 버전: v0.22.2+1885.g20acba0 (2026.9.24) stable, local 20acba037694 - up to date.
- hermes doctor 3건 중 1건 해소: custom_providers 리스트의 Gemini(generativelanguage.googleapis.com) 엔드포인트를
  providers.gemini-custom 맵으로 마이그레이션(api/name/api_key/default_model/models 보존), 레거시 리스트 항목 삭제.
  나머지 2건(OpenRouter/XAI 등 선택적 API 키 미설정)은 운영상 무해 - 핵심 모델(gpt-5.5, gemini)은 정상.
- hermes pm repair 정상 완료(하드링크 에러 없음). 이후 hermes update가 venv 소유권 안전장치에서 거부됨
  (site-packages 내 dist-info 파일 하나가 uid 10190으로 보인다는 에러).
- 근본 원인: 단순 소유권 문제가 아니라 proot ptrace 기반 fake-root가 statx 시스템콜(Python os.lstat 경로)을
  번역하지 못하는 한계. 같은 세션에서 coreutils stat은 uid=0으로 보이지만 Python os.lstat은 실제 안드로이드
  uid(10190)를 그대로 봄 - chown(단일 파일/재귀 모두)으로 해결 불가.
- proot-distro 업그레이드는 배포판 관리 래퍼일 뿐이라 무관, proot 본체 업그레이드도 확정적 해결책 아님(미검증).
- 결정: hermes update는 이번엔 보류. CLI 자체는 pm repair로 이미 정상. 상세 절차/근거는
  skill devops/termux-hermes-operations 참조.
