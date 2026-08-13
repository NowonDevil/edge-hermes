# 루팅 및 ADB 최소 앱 구성

> 대상: 본인 소유 Android 스마트폰을 Hermes 전용 서버로 전환하는 절차. 기기별 부트로더/리커버리/펌웨어 절차가 다르므로 실제 루팅 파일은 반드시 해당 모델 전용 자료를 사용한다.

## 준비물

- USB 케이블
- PC의 ADB/Fastboot 도구
- 기기별 순정 펌웨어 백업
- Magisk 앱/APK
- 데이터 백업: 사진, 문서, 인증앱, 연락처

## 루팅 개요

1. 개발자 옵션 활성화
2. OEM 잠금해제 허용
3. USB 디버깅 활성화
4. 부트로더 언락 또는 모델별 다운로드 모드 진입
5. Magisk로 패치한 boot/AP 파일 플래시
6. 부팅 후 Magisk 앱에서 root 상태 확인

주의: 루팅은 데이터 초기화, Knox/보안 플래그 변경, 금융앱 제한, 보증 제한이 발생할 수 있다.

## ADB 연결 확인

```bash
adb devices
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell su -c id
```

## 최소 앱 구성 원칙

필수 앱만 남긴다.

- Android 시스템 핵심 구성요소
- 설정 앱
- WebView/브라우저 최소 1개
- Google Play Services 또는 필요한 푸시/계정 구성요소
- Magisk
- Termux
- Termux:Boot
- Tailscale

제거/비활성 후보는 통신사 앱, 제조사 쇼핑/멤버십 앱, 게임/뉴스/미디어 앱, 미사용 클라우드/동기화 앱 등이다.

## 안전한 ADB debloat 방식

완전 삭제보다 사용자 0에서 비활성화한다.

```bash
adb shell pm list packages > packages-before.txt
adb shell pm list packages -3 > packages-third-party.txt
adb shell pm disable-user --user 0 <package.name>
adb shell pm enable <package.name>
adb shell pm uninstall --user 0 <package.name>
adb shell cmd package install-existing <package.name>
```

## 비활성화 금지 후보

- `com.android.systemui`
- `com.android.settings`
- `com.android.providers.*`
- `com.google.android.gms`
- `com.google.android.gsf`
- 현재 WebView provider
- 유일한 키보드/런처
- VPN/Tailscale 관련 패키지
- Termux/Termux:Boot/Magisk

## 변경 이력

비활성화 전후 패키지 목록, 날짜, 복구 명령, 재부팅 후 이상 여부를 기록한다.
