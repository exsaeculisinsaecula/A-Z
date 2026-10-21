# A-Z

> 사진·영상·메모를 A부터 Z까지 한 곳에.

**처음으로** · [요구사항](docs/requirements.md) · [설계](docs/design.md) · [작업 순서](docs/tasks.md) · [진행 상황](docs/progress.md) · [작업 지침](AGENTS.md)

| 문서 번호 | 버전 · 상태 | 작성일 · 수정일 | 적용 표준 |
|---|---|---|---|
| AZ-OVW (개요) | 0.4 · 초안 (검토 대기) | 2026-10-21 · 2026-10-21 | ISO/IEC/IEEE 15289 (문서 관리) |

아무 드라이브(C:·D:·외장 디스크·SD 카드)나 원하는 위치에 **보관함 폴더**를 하나 만들고 사진·영상·메모를 모읍니다.
피드에서는 트위터처럼 시간순 카드로, **궤도 뷰**에서는 카테고리별 구체와 링이 떠 있는 3D 공간으로 둘러봅니다.
보관함은 평범한 마크다운 파일과 첨부 파일로 되어 있어서 **폴더째 복사하면 다른 드라이브·기기로 옮기기와 백업이 끝납니다.**

<!-- 스크린샷: T37에서 추가 -->

> **대상 지역**: 대한민국 — ISO 3166-1 `KR` · `KOR` · `410` · 로캘 `ko-KR`
>
> **지금 상태**: 계획 문서 단계입니다. 코드는 아직 없고, 다음 작업은 T1(개발 환경)입니다. → [진행 상황](docs/progress.md)

## 처음 왔다면 (사람·AI 도구 모두)

이 저장소는 여러 사람과 여러 AI 도구가 이어서 작업할 수 있게 만들었습니다. 대화 기록 없이 문서만 보고 이어갈 수 있습니다.

```
README.md ........ 무엇을 만드는지, 한눈에 보기 (지금 이 파일)
  -> AGENTS.md ... 지킬 규칙 (사람과 모든 AI 도구 공통)
  -> docs/progress.md ... 지금 상태, 다음 작업, 인수인계 메모
  -> docs/tasks.md ...... 다음 작업의 카드 (할 일 + 완료 조건)
  -> docs/requirements.md / docs/design.md ... 카드가 가리키는 부분만
```

| 문서 번호 | 문서 | 담긴 것 | 번호 체계 |
|---|---|---|---|
| AZ-SRS | [requirements.md](docs/requirements.md) | 소프트웨어 요구사항 명세: 무엇이 되어야 하나 | F-xx.y (기능), NF-xx (품질), IF·CN·DR, AC-1~16 (수용 기준) |
| AZ-AD | [design.md](docs/design.md) | 아키텍처 기술 + 시험 계획: 어떤 구조로 만들까 | 0~14절, TC-01~16 (시험 사례) |
| AZ-SDP | [tasks.md](docs/tasks.md) | 소프트웨어 개발 계획: 어떤 순서로 구현할까 | T1~T37, 마일스톤 M0~M4 |
| AZ-PSR | [progress.md](docs/progress.md) | 진행 상태 보고: 지금 어디까지 했나 | 상태판, D-xx (결정), Q-xx (질문) |
| AZ-PRC | [AGENTS.md](AGENTS.md) | 작업 절차서 | — |

AI 도구별 지침 파일은 모두 `AGENTS.md`를 가리킵니다: `CLAUDE.md`(Claude Code), `GEMINI.md`(Gemini CLI), `.github/copilot-instructions.md`(GitHub Copilot). Codex·Cursor 등은 `AGENTS.md`를 바로 읽습니다.

## 한눈에 보기

```
A-Z
 |
 +-- 시작
 |    +-- 아무 드라이브(C:, D:, 외장, SD 카드 ...) / 아무 위치를 고름
 |    `-- 그 안에 새 폴더 「A-Z 보관함」을 만듦 (예시 포함 또는 빈 보관함)
 |
 +-- 보는 법
 |    +-- 피드 뷰 ........ 트위터처럼 시간순 카드
 |    +-- 궤도 뷰 ........ 3D 공간에 카테고리별 구체와 링
 |    `-- 내비게이터 ..... 두 뷰가 함께 쓰는 오른쪽 상세 카드
 |
 +-- 담는 곳
 |    +-- 보관함 폴더 하나 = 마크다운(.md) + 첨부 파일
 |    +-- 폴더째 복사·이동하면 다른 드라이브·기기로 옮기기와 백업 끝
 |    `-- Obsidian으로 열어도, 메모장으로 고쳐도 됨
 |
 +-- 쓰는 곳
 |    +-- Windows PC
 |    +-- Android 폰·태블릿
 |    `-- XR 헤드셋 (APK 사이드로드, 2D 패널)
 |
 +-- 만드는 법
 |    +-- Flutter 코드 하나 -> Windows 앱 + Android APK
 |    +-- 객체지향 (파일 몇 개, 파일마다 맡은 일 하나)
 |    `-- 완전 로컬 (release APK에 인터넷 권한 없음, 테스트도 로컬)
 |
 `-- 익히는 법
      +-- 첫 실행 튜토리얼 7단계 (해 보면서 배우기)
      `-- 예시 보관함 (포스트 7개 + 사진 5장 + 영상 1개)
```

## 처음 5분

설명서를 읽지 않아도 됩니다. 앱을 켜면 이렇게 진행됩니다.

```
첫 실행
  |
  v
새 보관함 만들기 ............... 드라이브·위치 고르기, [x] 예시 포함
  |
  v
예시 보관함이 채워짐 ........... 포스트 7개, 사진 5장, 영상 1개
  |
  v
코치마크 7단계 ................. 언제든 [건너뛰기], [?] 버튼으로 다시 보기
  1. 환영 ........ 기록은 전부 방금 만든 폴더 속 파일   [보관함 폴더 열기]
  2. 카드 ........ 연필 버튼으로 문장 하나 고치기
  3. 작성칸 ...... 사진 끌어다 놓고 #태그 쓰기
  4. 범례 ........ 폴더 = 카테고리, 눌러서 숨기기
  5. 궤도 뷰 ..... 같은 기록을 3D로, 노드 누르기
  6. 내비게이터 .. 파일 열기 / 피드에서 보기
  7. 마무리 ...... 옮기기·백업 = 폴더째 복사
  |
  v
「A-Z 시작하기.md」의 체크리스트가 채워짐 -> 파일이 실제로 바뀌는 걸 직접 확인
```

## 사용 방법

| 하고 싶은 일 | 방법 |
|---|---|
| 보관함 만들기 | 시작 화면 **새로 만들기** → 드라이브나 폴더 선택 → 이름 정하기 → **만들기** |
| 다른 보관함 열기 | 시작 화면 **열기** → 보관함 폴더 선택 (다른 기기에서 복사해 온 폴더도 됨) |
| 메모 남기기 | 피드 맨 위 입력칸에 쓰고 **게시**. `#태그`는 자동으로 인식됩니다 |
| 사진·영상 붙이기 | 입력칸에 끌어다 놓거나 **사진·영상** 버튼 (포스트당 4개까지 그리드로 보임) |
| 폴더 통째로 가져오기 | 왼쪽 아래 **가져오기** → 폴더 선택. 원본은 그대로 두고 사본을 보관함에 넣습니다. 이미 있는 파일은 건너뜁니다 |
| 고치기 | 카드의 연필 버튼. 또는 보관함 폴더의 `.md` 파일을 메모장으로 고쳐도 앱에 반영됩니다 |
| 카테고리 | 보관함 안의 폴더가 곧 카테고리입니다. 왼쪽 범례를 눌러 숨기거나 켭니다 |
| 크게 보기·재생 | 썸네일 클릭 → 뷰어. `←` `→` 이동, `Esc` 닫기 |
| 3D로 둘러보기 | 아래 막대에서 **궤도**. 드래그 = 회전, 휠·핀치 = 앞뒤 이동, 탭 = 선택, 더블탭 = 전체 보기 |
| 지운 것 되살리기 | 지운 포스트는 `.az/trash/`(휴지통)로 갑니다 |

## 보관함 옮기기·백업

```
[PC]  D:\A-Z 보관함\            (아무 드라이브·위치)
      |
      |  폴더째 복사·이동 (탐색기, USB, 외장 디스크, adb push, Syncthing ... 아무 방법)
      v
[다른 드라이브 / Android 폰 / XR 헤드셋]  .../A-Z 보관함/
      |
      v
A-Z 앱 -> [열기] -> 포스트·카테고리·즐겨찾기 그대로
```

보관함에는 절대 경로가 저장되지 않으므로 어디로 옮겨도 링크가 깨지지 않습니다. `.az/` 폴더는 앱이 쓰는 캐시라서 지워도 다시 만들어집니다.

## 개발 환경

| 필요한 것 | 용도 |
|---|---|
| Flutter SDK (stable) | 앱 전체 |
| Visual Studio 2022 「C++를 사용한 데스크톱 개발」 | Windows 빌드 |
| Windows 개발자 모드 | Flutter 플러그인 심볼릭 링크 |
| Android Studio 또는 Android SDK + JDK 17 | APK 빌드 |
| adb | 기기·헤드셋에 설치 |

설치 후 `flutter doctor`에서 Windows와 Android 항목이 모두 통과해야 합니다. 앱은 실행 중 인터넷이 필요 없습니다.

## 실행

```powershell
flutter pub get
flutter run -d windows          # Windows에서 실행
flutter devices                 # 연결된 Android 기기 확인
flutter run -d <기기 id>         # Android 기기에서 실행
```

## 테스트

```powershell
flutter analyze                                 # 경고 0이어야 함
flutter test                                    # 단위·위젯 테스트
flutter test integration_test -d windows        # e2e (실제 앱을 띄워 시나리오 확인)
flutter test integration_test -d <기기 id>       # e2e (Android)
```

## 빌드와 사이드로드

```
flutter analyze  ->  flutter test  ->  flutter test integration_test -d windows
      |
      +-->  flutter build windows --release  ---------->  A-Z-windows.zip
      |
      `-->  flutter build apk --release --split-per-abi
                 |
                 v
            app-arm64-v8a-release.apk
              +-- 로컬 키스토어로 서명 (android/key.properties는 커밋 안 함)
              +-- 권한 목록에 INTERNET 없음 확인
              `-- adb install -r  ->  폰 / Meta Quest / Android XR 헤드셋
```

- 폰: APK 파일을 옮겨 설치하거나 `adb install -r app-arm64-v8a-release.apk`
- XR 헤드셋: 개발자 모드를 켜고 `adb install -r …`. 헤드셋에 저장소 권한 화면이 없으면
  `adb shell appops set app.az.archive MANAGE_EXTERNAL_STORAGE allow`
- Windows: `build\windows\x64\runner\Release\` 폴더를 zip으로 묶어 배포

## 폴더 구조

문서는 ISO/IEC/IEEE 15289의 문서 체계(AZ-xxx)를 따릅니다. 코드와 문서, 자료, 시험을 나눠 두었습니다.

```
mini project/                           저장소 루트
│
├─ 문서 ··········································· ISO/IEC/IEEE 15289 (문서 관리)
│  ├─ README.md .............. AZ-OVW   개요: 무엇을 만드는지, 설치·사용·빌드
│  ├─ AGENTS.md .............. AZ-PRC   작업 절차서 (사람 + 모든 AI 도구 공통)
│  `─ docs/
│     ├─ requirements.md ..... AZ-SRS   소프트웨어 요구사항 명세 (ISO 29148, 25010)
│     ├─ design.md ........... AZ-AD    아키텍처 기술 + 시험 계획 (ISO 42010, 29119-3)
│     ├─ tasks.md ............ AZ-SDP   소프트웨어 개발 계획 (ISO 12207)
│     `─ progress.md .......... AZ-PSR   진행 상태 보고 (ISO 15289)
│
├─ 지침 연결 ······································ 같은 규칙을 도구마다 가리킴
│  ├─ CLAUDE.md ............................... -> AGENTS.md (Claude Code)
│  ├─ GEMINI.md ............................... -> AGENTS.md (Gemini CLI)
│  `─ .github/copilot-instructions.md ......... -> AGENTS.md (GitHub Copilot)
│
├─ 코드 ·········································· Flutter (Dart 패키지 a_z)
│  ├─ pubspec.yaml .........  이름·버전·의존성·assets 등록
│  `─ lib/
│     ├─ main.dart .......... main()   객체 조립 (합성 루트)
│     ├─ app.dart ........... AzApp, HomeShell, AppState, AppScope, AzRegion
│     ├─ archive.dart ....... Post, MediaRef, MediaKind, Category, PostQuery,
│     │                       TagParser, KoText, Archive, Clock, AzException
│     ├─ vault.dart ......... Vault, PostCodec, AtomicWriter, VaultIndex,
│     │                       VaultSettings, VaultWatcher, Trash
│     ├─ storage.dart ....... StorageLocator (interface)
│     │                        ├─ WindowsStorageLocator  (본보기)
│     │                        └─ AndroidStorageLocator
│     │                       StorageVolume, LocationCheck, VaultCatalog
│     ├─ media.dart ......... MediaProbe (abstract)
│     │                        ├─ PhotoProbe  (본보기)
│     │                        └─ VideoProbe
│     │                       ProbeRegistry, MediaInfo, ThumbnailCache
│     ├─ importer.dart ...... FolderScanner, ContentHasher, ImportJob
│     ├─ tutorial.dart ...... TutorialStep, TutorialController, SampleVaultSeeder
│     ├─ theme.dart ......... AzColors, AzShapes, AzMotion, AzTheme  (디자인 토큰)
│     `─ ui/
│        ├─ start.dart ....... VaultStartScreen (새로 만들기 / 열기 / 최근 보관함)
│        ├─ components.dart .. Legend, SearchBox, StatusPill, NavigatorCard,
│        │                     ControlBar, Composer, MediaViewer, Toast, EmptyHint
│        ├─ feed.dart ........ FeedView, PostCard, MediaGrid
│        ├─ orbit.dart ....... OrbitView, OrbitLayout, Camera3D, OrbitPainter,
│        │                     LabelLayer, Tour
│        `─ coach_marks.dart . CoachMarkOverlay
│
├─ 자료 ···········································
│  ├─ assets/
│  │  ├─ fonts/ .............. Pretendard (SIL OFL 1.1)
│  │  `─ sample_vault/ ....... 예시 보관함 (포스트 7 + 사진 5 + 영상 1)
│  `─ tools/
│     `─ make_sample_media.py  예시 자료 생성 (개발용, 앱에 들어가지 않음)
│
├─ 시험 ··········································· ISO/IEC/IEEE 29119-3 (시험)
│  ├─ test/ .................. 단위·위젯 시험 (MemoryFileSystem, 가짜 의존성)
│  `─ integration_test/ ...... 시스템·수용 시험 (실제 앱, Windows + Android)
│
├─ 플랫폼 ········································· flutter create 생성물
│  ├─ android/ ............... Android APK (arm64)
│  `─ windows/ ............... Windows x64 앱
│
`─ 저장소 설정
   ├─ .editorconfig ......... UTF-8 · LF · 공백 통일
   ├─ .gitattributes ........ 줄바꿈 LF, 바이너리 표시
   `─ _config.yml ........... GitHub Pages 문서 사이트 (jekyll-theme-cayman)
```

### 보관함 폴더 (사용자 자료, 어느 드라이브에든)

경로 구분자는 어느 OS에서든 `/`, 이름은 유니코드 NFC, 시각은 ISO 8601(설계 4절, AZ-SRS DR-01~06).

```
<아무 드라이브·위치>/
 `─ A-Z 보관함/                    이 폴더째 복사·이동 = 백업·이식
     ├─ A-Z 시작하기.md            튜토리얼 포스트 (pinned)
     ├─ <카테고리>/                폴더 = 카테고리 = 궤도 뷰의 구체 하나
     │   ├─ 2026-10-01 0930 제목.md   포스트 = 마크다운 파일 하나
     │   `─ 첨부/                       사진·영상 사본
     ├─ 미분류/                    카테고리 없이 쓴 기록
     `─ .az/                       앱 전용 (지워도 다시 만들어짐)
         ├─ vault.json ........... 보관함 표시 (형식 이름, 버전, 만든 날짜)
         ├─ settings.json ........ 카테고리 색·순서, 튜토리얼 진행
         ├─ index.json ........... 색인 + 첨부 내용 해시 (캐시)
         ├─ thumbs/ .............. 썸네일 (캐시)
         ├─ import_state.json .... 가져오기 이어하기 정보
         `─ trash/ ............... 지운 포스트·첨부 (복원 가능)

(보관함 밖, 기기별 앱 설정 폴더)
 ├─ recent_vaults.json ........... 이 기기에서 연 보관함 목록
 `─ logs/a_z.log ................. 로그 (보관함에는 남기지 않음)
```

### 스타터 템플릿과의 대응

| 스타터 | A-Z |
|---|---|
| `app.py` (창과 버튼) | `lib/main.dart` (객체 조립) + `lib/app.dart` (화면 틀·버튼·뷰 전환) |
| `inventory.py` (대여·반납·저장) | `lib/archive.dart` (작성·수정·삭제·검색) + `lib/vault.dart` (보관함 읽기·쓰기) + `lib/storage.dart` (드라이브·위치) |
| `data/equipment.json` | `assets/sample_vault/` (예시 보관함) |
| `docs/` 4종 | `docs/` 4종 + AZ-xxx 문서 번호 |

## 문서

- [요구사항](docs/requirements.md): 무엇이 되어야 하나
- [설계](docs/design.md): 어떤 구조로 만들까 (레퍼런스 분석·화면·보관함 형식·객체 구조)
- [작업 순서](docs/tasks.md): 어떤 순서로 구현할까 (T1~T37)
- [진행 상황](docs/progress.md): 지금 어디까지 했나
- [작업 지침](AGENTS.md): 사람과 AI 도구가 이 저장소에서 지킬 규칙

## 적용 표준

문서와 앱은 아래 ISO·IEC 표준을 따릅니다. 어느 문서가 어느 표준을 따르는지는 각 문서 맨 위의 문서 정보 표에 있습니다.

| 표준 | 무엇에 | 적용한 곳 |
|---|---|---|
| ISO/IEC/IEEE 29148:2018 | 요구사항 명세 구조, 요구 속성(ID·우선순위·검증 방법) | AZ-SRS |
| ISO/IEC 25010:2023 | 품질 요구 분류 (성능·호환성·상호작용·신뢰성·보안·유지보수·유연성·안전) | AZ-SRS 3.3 |
| ISO/IEC/IEEE 42010:2022 | 아키텍처 기술 (이해관계자·관심사·관점·뷰·결정) | AZ-AD 0절 |
| ISO/IEC/IEEE 29119-3:2021 | 시험 문서 (시험 계획·시험 사례·완료 보고) | AZ-AD 11절, AZ-PSR |
| ISO/IEC/IEEE 12207:2017 | 소프트웨어 생애주기 프로세스 | AZ-SDP |
| ISO/IEC/IEEE 15289:2019 | 문서 정보·버전·변경 이력 | 모든 문서 |
| ISO/IEC 40500:2012 (WCAG 2.0) AA | 접근성 (글자 대비 4.5:1 등) | AZ-SRS NF-09, AZ-AD 2절 |
| ISO 9241-110:2020 | 상호작용 원칙 (자기 서술성, 학습 용이성 등) | 튜토리얼·안내 문구 |
| ISO 8601-1:2019 | 날짜·시각 | 모든 문서, 보관함 파일 |
| ISO 80000-1, IEC 80000-13 | 수량·단위 표기 (`2 s`, `500 MB`, `1 MiB`) | 모든 문서 |
| ISO/IEC 10646 | 문자 (UTF-8) | 모든 파일 |
| ISO 3166-1:2020, ISO 3166-2:2020 | 대상 국가 `KR`·`KOR`·`410`, 하위 구분 `KR-xx` | AZ-SRS 3.7, `AzRegion` |
| ISO 639, BCP 47 | 언어 `ko`, 로캘 `ko-KR` | 화면, 모든 문서 |
| (참고) UN M49 | 지역 Asia `142`, Eastern Asia `030` | `AzRegion` |

## 라이선스

- 저장소 라이선스: 아직 정하지 않았습니다(progress.md Q-05). 정하기 전까지는 모든 권리가 저작자에게 있습니다.
- 예시 자료(`assets/sample_vault/`의 사진·영상): 모두 `tools/make_sample_media.py`로 직접 만든 것입니다.
- 글꼴: Pretendard (SIL Open Font License 1.1)

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.1 | 2026-10-21 | 최초 작성 | Claude Code |
| 0.2 | 2026-10-21 | 문서 번호(AZ-xxx), 읽는 순서, AI 도구 안내 추가 | Claude Code |
| 0.3 | 2026-10-21 | ISO 표준 표, 대상 지역(KR·ko-KR) 추가 | Claude Code |
| 0.4 | 2026-10-21 | 폴더 구조를 ISO/IEC/IEEE 15289 문서 체계로 재작성 (AZ-xxx · 표준 · 시험 분리), 보관함 구조에 ISO 표기 규칙 주석 추가 | Claude Code |
