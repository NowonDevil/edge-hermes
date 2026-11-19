# 현재 엣지헤르메스 상태

## 엣지 상태와 일상 명령 (노션 2026-11-19 기준)

갤럭시 S7 → Termux → proot Debian에서 `discordlite` 프로필로 디스코드 봇 `엣지#3379`를 운영한다. 운영 기준은 **v0.22.2 고정, 업데이트 보류**다. 노션에 따르면 Termux:Boot 감시는 5분마다 꺼진 게이트웨이를 다시 띄운다. 이는 운영 설정 기록이지 현재 연결을 보증하는 표시는 아니다.

### Termux (`~ $`): 접속·상태 확인·게이트웨이 제어

노트북에서는 `ssh phone-hermes`로 접속한다. 어느 셸인지 헷갈리면 `pwd`와 `whoami`로 확인한다.

- `~/hermes-debian-status` — 설치 버전 확인. `tmux ls` — `hermes-gateway` 세션 존재 확인. 세션이 보여도 Discord 연결까지 확인된 것은 아니다.
- `tail -5 /sdcard/hermes-boot-schedule.log` — 감시의 최근 실행 기록 확인.
- `tmux attach -t hermes-gateway` — 실행 화면 보기. 작업을 살려 둔 채 나올 때는 `Ctrl+B`를 누르고 놓은 뒤 `D`.
- `~/hermes-debian` — Debian 진입. `exit`로 Termux에 복귀.
- 세션이 없고 게이트웨이가 꺼진 것을 확인했으면 `~/start-hermes-gateway.sh`로 시작한다. 사람이 **별도 Termux 셸**에서 대상·유휴 상태를 확인한 경우에만 `~/start-hermes-gateway.sh --force`로 재시작한다. 게이트웨이 자신의 도구에서 실행하지 않는다.
- 일시 정지가 필요할 때만 외부 셸에서 `tmux kill-session -t hermes-gateway`. 감시가 다음 점검에서 다시 켤 수 있어 영구 중지 명령이 아니다.

### Debian (`root@localhost`): 연결은 됐는데 답이 없을 때

먼저 `cd /root/.hermes/profiles/discordlite/logs/`로 이동한다.

1. `grep -aE "Connected as|discord connected|Stopping gateway" gateway.log | tail -5` — 최근 연결 뒤 곧바로 종료된 것은 아닌지 시각과 순서를 본다.
2. Discord에서 엣지에 `ping`을 한 번 보내고 `grep -aE "inbound message|Sending response" gateway.log | tail -5`로 해당 시각의 수신·응답을 확인한다. 최종 전달은 Discord에서 실제 답으로 확인한다.
3. 수신만 되고 답이 없으면 `tail -50 errors.log`로 허용 사용자 설정·모델 이름·크레딧 오류를 구분한다. 응답이 느리면 `grep "API call #1" agent.log | tail -5`에서 `latency`, `in`, `out`을 확인한다.
4. 연결 후 반복 종료되면 `tail -2 gateway-exit-diag.log`로 **런처가 사용한** Python을 확인한다. 노션 복구 기록은 정상 3.14.x, 장애 때 3.13이었다. 별도 셸의 `python --version`만으로 같은 장애라고 판단하지 않는다. 11월 7일(v0.23.0)과 19일(v0.23.2)에 proot 의존성 설치 실패가 기록됐다. 재시도하지 말고 메인 헤르메스에 복구를 요청한다.

## 과거 환경 스냅샷 (2026-09-21)

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
