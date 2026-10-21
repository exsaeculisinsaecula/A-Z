# A-Z

> 사진·영상·메모를 A부터 Z까지 한 곳에.

| 항목 | 내용 |
|---|---|
| 문서 번호 | AZ-OVW |
| 문서 이름 | A-Z 프로젝트 개요 |
| 버전 · 상태 | 1.0 · 초안 (검토 대기) |
| 작성일 · 수정일 | 2026-10-21 · 2026-10-21 |
| 작성 · 승인 | Claude Code (AI) · 프로젝트 소유자 (미승인) |
| 적용 표준 | ISO/IEC/IEEE 15289:2019 (문서 관리) |
| 대상 지역 | 대한민국 (ISO 3166-1 `KR` · `KOR` · `410`), 로캘 `ko-KR` |

**[처음으로](README.md)** · [요구사항](docs/requirements.md) · [설계](docs/design.md) · [작업 순서](docs/tasks.md) · [진행 상황](docs/progress.md) · [작업 지침](AGENTS.md)

---

## 1. 한눈에 보기

아무 드라이브(C: · D: · 외장 디스크 · SD 카드)나 원하는 위치에 **보관함 폴더**를 하나 만들고 사진·영상·메모를 모읍니다.

- **피드 뷰**: 트위터처럼 시간순 카드로 빠르게 훑고, 쓰고, 고칩니다.
- **궤도 뷰**: 카테고리별 구체와 링이 떠 있는 3D 공간에서 전체를 둘러봅니다.
- **보관함**: 평범한 마크다운과 첨부 파일. 폴더째 복사하면 백업·이식이 끝납니다.

```
A-Z
 ├─ 시작 ............ 아무 드라이브·위치에 보관함 폴더 만들기
 ├─ 보는 법 ......... 피드 뷰 · 궤도 뷰 · 내비게이터
 ├─ 담는 곳 ......... 보관함 폴더 = 마크다운(.md) + 첨부
 ├─ 쓰는 곳 ......... Windows PC · Android · XR 헤드셋
 ├─ 만드는 법 ....... Flutter 1개 코드 → Windows + APK
 └─ 익히는 법 ....... 첫 실행 튜토리얼 · 예시 보관함
```

## 2. 문서 체계 (ISO/IEC/IEEE 15289)

| 문서 번호 | 파일 | 종류 | 적용 표준 |
|---|---|---|---|
| AZ-OVW | `README.md` | 개요 | ISO/IEC/IEEE 15289 |
| AZ-PRC | `AGENTS.md` | 작업 절차서 | ISO/IEC/IEEE 15289, 12207 |
| AZ-SRS | `docs/requirements.md` | 소프트웨어 요구사항 명세 | ISO/IEC/IEEE 29148, ISO/IEC 25010 |
| AZ-AD | `docs/design.md` | 아키텍처 기술 + 시험 계획 | ISO/IEC/IEEE 42010, 29119-3 |
| AZ-SDP | `docs/tasks.md` | 소프트웨어 개발 계획 | ISO/IEC/IEEE 12207 |
| AZ-PSR | `docs/progress.md` | 진행 상태 보고 | ISO/IEC/IEEE 15289 |

읽는 순서:

```
README.md .......... 무엇을 만드는지 (지금 이 파일)
  → AGENTS.md ...... 지킬 규칙
  → docs/progress.md  지금 상태 · 다음 작업
  → docs/tasks.md .... 작업 카드
  → docs/requirements.md · docs/design.md ... 카드가 가리키는 절만
```

## 3. 폴더 구조

```
A-Z/
 ├─ README.md ................. AZ-OVW  개요
 ├─ AGENTS.md ................. AZ-PRC  작업 절차서
 ├─ CLAUDE.md  GEMINI.md ...... AI 도구 입구 → AGENTS.md
 ├─ .github/
 │   └─ copilot-instructions.md  → AGENTS.md
 ├─ .editorconfig  .gitattributes  UTF-8 · LF 통일
 ├─ _config.yml ............... GitHub Pages 문서 사이트
 │
 ├─ docs/ ..................... AZ-SRS · AZ-AD · AZ-SDP · AZ-PSR
 ├─ lib/ ...................... 앱 코드 (Flutter, 패키지 a_z)
 │   └─ ui/ ................... 화면 위젯
 ├─ test/ .................... 단위·위젯 시험
 ├─ integration_test/ ......... 시스템·수용 시험
 ├─ assets/
 │   ├─ fonts/ ................ Pretendard (SIL OFL)
 │   └─ sample_vault/ ......... 예시 보관함
 ├─ tools/ ................... 개발용 도구 (앱에 안 들어감)
 ├─ android/ ................. Android 플랫폼
 └─ windows/ ................. Windows 플랫폼
```

### 보관함 폴더 (사용자 자료)

```
<아무 드라이브·위치>/
 └─ A-Z 보관함/                이 폴더째 복사 = 백업 · 이식
     ├─ A-Z 시작하기.md        튜토리얼 (고정)
     ├─ <카테고리>/            폴더 = 카테고리
     │   ├─ 2026-10-01 0930 제목.md   포스트
     │   └─ 첨부/                    사진 · 영상
     ├─ 미분류/
     └─ .az/                   앱 캐시 (지워도 다시 만듦)
```

경로 규칙 (AZ-SRS): 구분자는 어느 OS에서든 `/`, 이름은 유니코드 NFC, 시각은 ISO 8601.

## 4. 빠른 시작

### 요구 환경

| 필요한 것 | 용도 |
|---|---|
| Flutter SDK (stable) | 앱 전체 |
| Visual Studio 2022 「C++ 데스크톱 개발」 | Windows 빌드 |
| Android SDK + JDK 17 | APK 빌드 |
| adb | 기기 설치 |

### 실행

```powershell
flutter pub get
flutter run -d windows
```

### 시험

```powershell
flutter analyze                           # 경고 0
flutter test                              # 단위 · 위젯
flutter test integration_test -d windows  # 시스템 · 수용
```

### 빌드 · 배포

```powershell
flutter build windows --release             # A-Z-windows.zip
flutter build apk --release --split-per-abi  # app-arm64-v8a-release.apk
```

- release APK에 INTERNET 권한 없음 = 완전 로컬
- XR 헤드셋: `adb install -r app-arm64-v8a-release.apk`

## 5. 적용 표준

| 표준 | 적용 |
|---|---|
| ISO/IEC/IEEE 29148 | 요구사항 명세 (AZ-SRS) |
| ISO/IEC 25010 | 품질 요구 (AZ-SRS 3.3) |
| ISO/IEC/IEEE 42010 | 아키텍처 기술 (AZ-AD) |
| ISO/IEC/IEEE 29119-3 | 시험 계획 (AZ-AD 11) |
| ISO/IEC/IEEE 12207 | 개발 프로세스 (AZ-SDP) |
| ISO/IEC/IEEE 15289 | 문서 관리 (모든 문서) |
| ISO/IEC 40500 (WCAG 2.0) AA | 접근성 |
| ISO 8601 | 날짜 · 시각 |
| ISO 80000-1 / IEC 80000-13 | 수량 · 단위 |
| ISO 3166-1 `KR` / ISO 639 `ko` | 대상 지역 · 언어 |

## 6. 라이선스

- 저장소 라이선스: 미정 (progress.md Q-05). 정하기 전까지 모든 권리 보유.
- 예시 자료: 직접 생성. 글꼴: Pretendard (SIL OFL 1.1).

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 1.0 | 2026-10-21 | ISO 한국 표준으로 처음부터 재작성 | Claude Code |
