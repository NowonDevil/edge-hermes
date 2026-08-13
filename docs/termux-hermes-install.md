# Termux, Python, Hermes Agent 설치

## Termux 설치

F-Droid 또는 GitHub Release의 최신 Termux와 Termux:Boot를 설치한다.

```bash
termux-setup-storage
pkg update
pkg upgrade
pkg install git openssh proot-distro python nodejs-lts termux-api
```

## proot Debian 설치

```bash
pkg install proot-distro
proot-distro install debian
proot-distro login debian --bind /sdcard:/sdcard
```

Debian 안 기본 패키지:

```bash
apt update
apt install -y git curl ca-certificates python3 python3-venv python3-pip nodejs npm openssh-client
```

PEP 668 환경에서는 전역 pip보다 venv를 사용한다.

## Hermes Agent 설치

```bash
cd /root
git clone https://github.com/NousResearch/hermes-agent.git
cd hermes-agent
python3 -m venv venv
. venv/bin/activate
pip install -U pip
pip install -e .
/root/hermes-agent/venv/bin/hermes --version
```

## Discord gateway 실행 스크립트

Termux 홈에 런처를 둔다.

```text
/data/data/com.termux/files/home/start-hermes-gateway.sh
```

런처는 proot Debian으로 들어가 Hermes gateway를 실행하는 역할만 맡긴다. 토큰과 `.env` 내용은 저장소에 기록하지 않는다.

예시 구조:

```bash
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian --bind /sdcard:/sdcard -- bash -lc 'cd /root/hermes-agent && /root/hermes-agent/venv/bin/hermes gateway start'
chmod 755 /data/data/com.termux/files/home/start-hermes-gateway.sh
```

## 민감정보

Discord token, OAuth token, SSH key, API keys는 git에 넣지 않는다.
