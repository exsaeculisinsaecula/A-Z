# 소프트웨어 개발 계획서 (SDP) — 어떤 순서로 구현할까

[처음으로](../README.md) · [요구사항](requirements.md) · [설계](design.md) · **작업 순서** · [진행 상황](progress.md) · [작업 지침](../AGENTS.md)

| 항목 | 내용 |
|---|---|
| 문서 번호 | AZ-SDP |
| 문서 이름 | A-Z 소프트웨어 개발 계획서 (작업 순서) |
| 버전 · 상태 | 0.3 · 초안 (검토 대기) |
| 작성일 · 수정일 | 2026-10-21 · 2026-10-21 |
| 작성 · 승인 | Claude Code (AI) · 프로젝트 소유자 (미승인) |
| 적용 표준 | ISO/IEC/IEEE 12207:2017 (생애주기 프로세스), ISO/IEC/IEEE 15289:2019 (문서 내용) |
| 상위 문서 | [AZ-SRS 요구사항](requirements.md), [AZ-AD 설계](design.md) |

이 문서는 **작업 카드 모음**입니다. 사람이든 AI 도구든, 대화 기록 없이 이 카드와 링크된 문서만 보고 작업을 이어갈 수 있게 썼습니다.

- 작업의 **상태(대기·진행·완료·막힘)와 작업자**는 [progress.md](progress.md)의 상태판 한 곳에서만 관리합니다. 이 문서는 작업의 **정의**만 담고, 정의가 바뀔 때만 고칩니다.
- 번호(T·F·AC)는 다시 매기지 않습니다. 작업을 없애야 하면 제목에 「(폐기)」를 붙이고 이유를 적습니다.
- 「선행」 작업이 끝나야 시작할 수 있습니다. 선행이 같은 작업끼리는 동시에 해도 됩니다.

## 작업 카드 읽는 법

```
### T00 작업 이름
- 마일스톤 · 관련 요구(F-xx) · 선행 작업(Txx)
- 파일 ........ 만들거나 고칠 파일
- 만들 것 ..... 클래스·위젯 이름 (docs/design.md 6.2 표와 같은 이름)
- 할 일 ....... 무엇을 하는지
- 완료 조건 ... 이것이 모두 참이면 끝 (테스트 포함)
- 확인 ........ 실행할 명령
```

## 로드맵

```
    +-------+----------------------------------+-------------------------+-------------------+----------------------+
    |  M0   |                M1                |           M2            |        M3         |          M4          |
    +-------+----------------------------------+-------------------------+-------------------+----------------------+
T   | 01 02 | 03 04 05 06 07 08 09 10 11 12 13 | 14 15 16 17 18 ... 24   | 25 26 27 28 29 30 | 31 32 33 34 35 36 37 |
    +-------+----------------------------------+-------------------------+-------------------+----------------------+
```

| 마일스톤 | 끝나면 되는 것 |
|---|---|
| M0 준비 | 빈 앱이 Windows와 Android에서 뜬다 |
| M1 기록 엔진 | 모델·보관함·저장 위치·미디어·가져오기·예시 자료가 화면 없이 단위 테스트로 완성된다 |
| M2 피드 앱 | 시작 화면부터 피드까지. 이 시점부터 매일 쓸 수 있다 |
| M3 궤도 뷰 | 3D 공간과 튜토리얼 화면 |
| M4 출시 | 다듬기·장애 점검·성능·e2e·APK와 Windows 배포 |

### 생애주기 프로세스 대응 (ISO/IEC/IEEE 12207)

| 12207 프로세스 | 이 프로젝트에서 | 산출물 |
|---|---|---|
| 이해관계자 요구 정의 · 시스템/소프트웨어 요구 정의 | 계획 단계 (완료) | AZ-SRS |
| 아키텍처 정의 · 설계 정의 | 계획 단계 (완료) | AZ-AD |
| 프로젝트 계획 · 평가·통제 | 이 문서, progress.md | AZ-SDP, AZ-PSR |
| 인프라 관리 | M0 (T1~T2) | 개발 환경, 빈 앱 |
| 구현 | M1~M3 (T3~T30) | `lib/`, `assets/` |
| 통합 | M2~M3 끝, T29 | 두 뷰가 이어진 앱 |
| 검증 (verification) | 모든 카드의 「완료 조건」, T32~T34 | 시험 결과 (TC-01~16) |
| 전이 (transition) | T35 | 서명된 APK, Windows zip |
| 확인 (validation) | T30(처음 보는 사람 시연), T37 | 수용 기준 결과 |
| 형상 관리 | AGENTS.md 5·8절 (브랜치·커밋·버전), 문서 변경 이력 | Git 기록 |
| 품질 보증 | `flutter analyze` 0, 커버리지 80 % (NF-19, NF-20) | 분석 결과 |

선행 관계 (화살표 = 먼저 끝나야 함):

```
T1 -> T2 -> T3 -> T4 -> T5 -> T6 -+-> T7 --------------------------------------+
                                  +-> T8                                       |
                                  +-> T9 -> T10 -> T11 ------------------------+
                                  `-> T12 -> T13 ------------------------------+
                                                                               v
            T14 -> T15 -> T16 -> T17 -> T18 ... T24  (M2, 화면은 M1이 끝난 뒤)
                                   |
                                   `-> T25 -> T26 -> T27 -> T28 -> T29 -> T30  (M3)
                                                                           |
                                                     T31 ... T37 (M4) <----+
```

## 요구 ↔ 작업 연결

| 요구 (우선순위) | 작업 |
|---|---|
| F-01 포스트 작성 (Must) | T3 T4 T6 T18 |
| F-02 바깥 폴더 가져오기 (Must) | T9 T11 T23 |
| F-03 피드 (Must) | T17 |
| F-04 뷰어 (Must) | T19 |
| F-05 범례·유형 필터 (Must) | T4 T21 |
| F-06 보관함 만들기·열기 (Must) | T6 T7 T8 T16 |
| F-07 수정·삭제·카테고리 (Must) | T6 T22 |
| F-08 궤도 뷰 (Must) | T25 T26 T27 T29 |
| F-09 내비게이터 (Must) | T20 |
| F-10 튜토리얼·예시 보관함 (Must) | T12 T13 T30 |
| F-11 검색 · F-13 태그 필터 (Should) | T4 T21 |
| F-12 즐겨찾기·고정 (Should) | T22 |
| F-14 끊긴 첨부 · F-15 바깥 편집 반영 (Should) | T8 T24 |
| F-16 궤도 여행 (Should) | T28 |
| F-17 튜토리얼 체크리스트 (Should) | T13 T30 |
| F-18 휴지통 화면 · F-19 단축키 · F-20 zip 내보내기 (Could) | T36 |

| 수용 기준 | 확인하는 작업 |
|---|---|
| AC-1 첫 실행·튜토리얼 | T30 T34 |
| AC-2 드라이브별 보관함 | T16 T34 |
| AC-3 위치 점검 | T7 T16 |
| AC-4 가져오기·원본 불변 | T11 T23 T34 |
| AC-5 중복 0 | T11 |
| AC-6 이식 | T6 T34 |
| AC-7 Obsidian·메모장 | T5 T24 |
| AC-8 궤도 뷰 조작 | T27 |
| AC-9 두 뷰 연동 | T29 |
| AC-10 휴지통 복원 | T6 T36 |
| AC-11 완전 로컬 | T2 T35 |
| AC-12 폰·헤드셋 사이드로드 | T35 |
| AC-13 장애 시나리오 | T32 |
| AC-14 테스트·성능 | T33 T34 |
| AC-15 접근성 | T14 T31 |
| AC-16 한국어·지역화 | T3 T18 T21 T31 T36 |

---

## M0 준비

### T1 개발 환경
- M0 · 관련: — · 선행: 없음
- 파일: 없음 (설치만)
- 할 일: Flutter SDK(stable) 설치 · Visual Studio 2022 「C++를 사용한 데스크톱 개발」 워크로드 · Windows 개발자 모드 켜기 · Android Studio(또는 SDK + JDK 17) 설치 · `flutter doctor --android-licenses` 동의
- 완료 조건: `flutter doctor`에서 Flutter·Windows·Android 항목이 통과한다 · Flutter·Dart·JDK·Android SDK 버전을 progress.md 「환경 기록」에 적는다
- 확인: `flutter doctor -v`

### T2 프로젝트 뼈대
- M0 · 관련: 완전 로컬 · 선행: T1
- 파일: `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `lib/app.dart`, `android/`, `windows/`, `.gitignore`
- 만들 것: 빈 `AzApp`, design.md 6.2 표의 파일들(빈 파일)
- 할 일: 저장소 루트에서 `flutter create --project-name a_z --platforms=windows,android .` 실행(`--overwrite`는 쓰지 않음. 기존 README·docs가 그대로인지 확인) · Android `applicationId`를 `app.az.archive`로, 앱·창 이름을 `A-Z`로 · release `AndroidManifest.xml`에서 INTERNET 빼기(debug·profile에만) · `MANAGE_EXTERNAL_STORAGE` 선언 · `flutter_lints` 적용 · `.gitignore`에 `android/key.properties`, `*.jks` 추가 · 로캘 `ko-KR` 설정(`flutter_localizations`, design.md 2.7의 `AzRegion`)
- 완료 조건: 빈 창이 Windows와 Android(기기 또는 에뮬레이터)에서 뜬다 · `flutter analyze` 경고 0 · release APK 권한 목록에 INTERNET이 없다 · 기본 위젯 문구(복사·붙여넣기 메뉴 등)가 한국어로 나온다(LC-02)
- 확인: `flutter run -d windows` · `flutter run -d <기기>` · `flutter build apk --release` 후 `apkanalyzer manifest permissions`

---

## M1 기록 엔진 (화면 없이, 전부 단위 테스트)

### T3 기록 모델
- M1 · 관련: F-01 · 선행: T2
- 파일: `lib/archive.dart`, `test/archive_model_test.dart`
- 만들 것: `Post`, `MediaRef`, `MediaKind`, `Category`, `PostQuery`, `TagParser`, `KoText`, `AzException` 계층(`NotFound`, `InvalidLocation`, `StorageUnavailable`, `VaultConflict`, `CorruptedFile`, `MediaUnsupported`)
- 할 일: 값 객체와 `copyWith`, `PostQuery.matches(post)`, 태그 추출(design.md 4.1 본문 규칙), `KoText`(NFC 정규화·ko-KR 정렬, design.md 2.7)
- 완료 조건: 한글 태그 · 코드 블록 속 `#` 제외 · `# 제목` 제외 · 유형 필터(사진·영상·메모) · 숨긴 카테고리 테스트 통과 · NFD 문자열 검색과 「1 → A → 가 → 나」 정렬 시험 통과(LC-08, LC-09)
- 확인: `flutter test test/archive_model_test.dart`

### T4 Archive
- M1 · 관련: F-01 F-05 F-11 F-13 · 선행: T3
- 파일: `lib/archive.dart`, `lib/vault.dart`(공개 API 뼈대만), `test/archive_test.dart`
- 만들 것: `Archive`, `ArchiveStats`, `OrbitGraph`, `Clock`(지금 시각, 테스트에서 고정)
- 할 일: design.md 6.3의 `Archive` 메서드 구현 · `Vault`는 공개 메서드 시그니처만 먼저 만들고(`UnimplementedError`), 테스트에서는 `class FakeVault implements Vault`로 대신 · 궤도 그래프 링크 규칙(같은 태그끼리 시간순 이웃)
- 완료 조건: 작성·수정·삭제·카테고리 이동이 `Vault` 호출로 이어진다 · 변경 알림이 온다 · 가짜 포스트 2,000개에서 `query` 50 ms 이내
- 확인: `flutter test test/archive_test.dart`

### T5 PostCodec
- M1 · 관련: F-01 F-15, DR-01 DR-04 DR-05, AC-7 · 선행: T4
- 파일: `lib/vault.dart`, `test/post_codec_test.dart`, `test/fixtures/`(예시 `.md`)
- 만들 것: `PostCodec`
- 할 일: `.md` ↔ `Post`. 머리말 없음·일부 없음·모르는 필드 보존·`![[이름만]]`·`![](경로)`·체크리스트
- 완료 조건: 왕복(decode → encode → decode) 결과가 같다 · 모르는 머리말 필드가 사라지지 않는다 · Obsidian에서 만든 머리말 없는 노트를 읽는다 · 깨진 YAML은 `CorruptedFile`
- 확인: `flutter test test/post_codec_test.dart`

### T6 AtomicWriter · Vault · Trash
- M1 · 관련: F-01 F-06 F-07, AC-6 AC-10 · 선행: T5
- 파일: `lib/vault.dart`, `test/vault_test.dart`
- 만들 것: `AtomicWriter`, `Vault`(T4 뼈대를 실제 구현으로), `Trash`
- 할 일: design.md 4절 규칙 그대로: 만들기·열기·목록·읽기·쓰기(수정 시각 비교 → `VaultConflict`)·첨부 복사(이름 충돌 ` (2)`)·카테고리 이동·휴지통·복원 · 모든 경로는 보관함 기준 상대 경로, 구분자 `/`, 이름은 NFC (DR-02, DR-03)
- 완료 조건: `MemoryFileSystem`으로 위 기능 테스트 통과 · 보관함 폴더를 다른 경로로 복사해서 열어도 같은 결과(이식 테스트) · 남은 `.tmp`는 다음 열 때 정리
- 확인: `flutter test test/vault_test.dart`

### T7 StorageLocator · LocationCheck · VaultCatalog
- M1 · 관련: F-06, AC-2 AC-3 · 선행: T6
- 파일: `lib/storage.dart`, `android/app/src/main/kotlin/.../MainActivity.kt`(StatFs 채널), `test/storage_test.dart`
- 만들 것: `StorageLocator`, `WindowsStorageLocator`(본보기 주석 포함), `AndroidStorageLocator`, `StorageVolume`, `LocationCheck`, `VaultCatalog`
- 할 일: 볼륨 목록·종류·남은 공간 · design.md 5절 `LocationCheck` 규칙 전부(시스템 폴더 위치는 환경 변수로) · 최근 보관함 목록(최대 20, 사라진 경로 표시)
- 완료 조건: 가짜 Locator로 `LocationCheck` 규칙별 테스트 통과 · Windows에서 실제 드라이브 목록이 맞게 나온다 · Android 실기기에서 내부 저장소(가능하면 SD 카드) 목록과 남은 공간이 나온다(못 하면 「미확인」 기록)
- 확인: `flutter test test/storage_test.dart` · 작은 확인용 화면 또는 로그

### T8 VaultIndex · VaultSettings · VaultWatcher
- M1 · 관련: F-06 F-14 F-15 · 선행: T6
- 파일: `lib/vault.dart`, `test/vault_index_test.dart`
- 만들 것: `VaultIndex`, `VaultSettings`, `VaultWatcher`
- 할 일: `index.json` 읽기·검증·다시 만들기 · `settings.json`(카테고리 색 번호·순서·튜토리얼) · 바깥 변경을 `Stream<VaultChange>`로
- 완료 조건: `index.json`을 지우거나 망가뜨려도 같은 결과로 다시 만들어진다 · 바깥에서 `.md`를 고치면 변경 이벤트가 온다(데스크톱) · 다시 훑기 함수가 바뀐 파일만 찾는다
- 확인: `flutter test test/vault_index_test.dart`

### T9 MediaProbe 계열
- M1 · 관련: F-02 · 선행: T6
- 파일: `lib/media.dart`, `test/media_test.dart`
- 만들 것: `MediaProbe`, `PhotoProbe`(본보기 주석 포함), `VideoProbe`, `ProbeRegistry`, `MediaInfo`
- 할 일: 확장자 등록, 크기·EXIF 촬영일·영상 길이, 썸네일 바이트 · `fc_native_video_thumbnail`이 Windows에서 되는지 확인
- 완료 조건: 테스트에서 즉석으로 만든 jpg·png로 크기·촬영일 테스트 통과 · Windows와 Android에서 mp4 썸네일이 나온다(안 되면 design.md 14절 대안 적용 후 기록)
- 확인: `flutter test test/media_test.dart`

### T10 ThumbnailCache
- M1 · 관련: F-03 · 선행: T9
- 파일: `lib/media.dart`, `test/thumbnail_test.dart`
- 만들 것: `ThumbnailCache`
- 할 일: `.az/thumbs/`에 긴 변 480 px JPEG · 크기+수정 시각이 바뀌면 다시 만듦 · 무거운 일은 isolate
- 완료 조건: 같은 파일은 한 번만 만든다 · 원본이 바뀌면 다시 만든다 · 실패하면 `null`(앱은 자리표시)
- 확인: `flutter test test/thumbnail_test.dart`

### T11 가져오기
- M1 · 관련: F-02, AC-4 AC-5 · 선행: T10, T7
- 파일: `lib/importer.dart`, `test/importer_test.dart`
- 만들 것: `FolderScanner`, `ContentHasher`, `ImportJob`, `ImportPlan`, `ImportProgress`
- 할 일: 계획(개수·총 용량·남은 공간) → 실행(사본 복사·포스트 생성·썸네일·진행률) → 취소 → `import_state.json`으로 이어하기 · 실패한 파일은 목록에 남기고 계속
- 완료 조건: 원본 파일의 크기·수정 시각·내용 해시가 가져오기 전후로 같다 · 같은 폴더를 다시 가져오면 새 포스트 0개 · 공간이 모자라면 시작하지 않는다 · 중간 취소 후 이어서 하면 빠짐없이 끝난다
- 확인: `flutter test test/importer_test.dart`

### T12 예시 자료 만들기
- M1 · 관련: F-10 · 선행: T6
- 파일: `tools/make_sample_media.py`, `assets/sample_vault/**`, `pubspec.yaml`(assets 등록)
- 만들 것: 예시 보관함 (design.md 8.2)
- 할 일: Pillow·OpenCV로 팔레트 색 링 이미지 4장·그라데이션 1장·6초 링 영상 1개 생성 · 포스트 7개 작성(시작하기·해부도·끊긴 링크 연습 포함)
- 완료 조건: 합계 5 MB 이하 · 모든 `.md`가 `PostCodec`으로 읽힌다(끊긴 링크 연습만 첨부 없음) · 자료가 모두 직접 만든 것임을 README의 라이선스 줄에 적는다
- 확인: `python tools/make_sample_media.py` · `flutter test test/sample_vault_test.dart`

### T13 SampleVaultSeeder · TutorialController
- M1 · 관련: F-10 F-17 · 선행: T12, T8
- 파일: `lib/tutorial.dart`, `test/tutorial_test.dart`
- 만들 것: `TutorialStep`(design.md 8.1의 7단계), `TutorialController`, `SampleVaultSeeder`
- 할 일: 예시 보관함 복사(날짜를 오늘 기준으로 맞춤) · 단계 진행·완료 저장(`settings.json`) · 행동 완료 시 「A-Z 시작하기.md」 체크리스트 반영
- 완료 조건: 새 보관함에 예시 7개 포스트가 들어간다 · 단계 완료 이벤트로 체크리스트의 해당 줄이 `- [x]`가 된다 · 건너뛰기·다시 보기 상태가 저장된다
- 확인: `flutter test test/tutorial_test.dart`

---

## M2 피드 앱 (이 마일스톤 끝에서 매일 쓸 수 있음)

### T14 테마와 배경
- M2 · 관련: — · 선행: M1 완료
- 파일: `lib/theme.dart`, `assets/fonts/`, `pubspec.yaml`
- 만들 것: `AzColors`, `AzShapes`, `AzMotion`, `AzTheme`, 배경 링 페인터
- 할 일: design.md 2.2 토큰 그대로(`categoriesText` 포함) · Pretendard 포함 · 피드 배경의 옅은 링·구체(패럴랙스·느린 회전)
- 완료 조건: 위젯에 색·반경·시간 값을 직접 쓴 곳이 없다(`grep`으로 `Color(0x` 검색 시 theme.dart만) · 애니메이션 줄이기에서 배경이 멈춘다 · 글씨 색과 바탕 조합이 모두 4.5:1 이상이라는 자동 시험이 통과한다(TC-15 일부)
- 확인: `flutter run -d windows`

### T15 HomeShell · AppState · 반응형
- M2 · 관련: F-05 F-09 · 선행: T14
- 파일: `lib/app.dart`, `lib/main.dart`, `test/app_state_test.dart`
- 만들 것: `AzApp`, `AppScope`, `AppState`, `HomeShell`, `ControlBar`(자리만), `Toast`
- 할 일: `main.dart`에서 객체 조립 · 영역 [A]~[I] 자리 잡기 · 1단·2단·3단 배치(design.md 2.4) · 피드 ↔ 궤도 자리 전환(궤도는 빈 자리)
- 완료 조건: 창 폭을 바꾸면 1·2·3단이 바뀐다 · `AppState` 단위 테스트(선택·필터·보기 전환) 통과
- 확인: `flutter test test/app_state_test.dart` · `flutter run -d windows`

### T16 보관함 시작 화면
- M2 · 관련: F-06, AC-2 AC-3 · 선행: T15, T7, T13
- 파일: `lib/ui/start.dart`, `test/ui/start_test.dart`
- 만들 것: `VaultStartScreen`
- 할 일: design.md 2.3·7-⓪·7-⓪-2 흐름: 볼륨 목록(종류·남은 공간) → 위치(찾아보기) → 이름 → 점검 결과 표시 → 만들기(예시 포함/빈) · 열기 · 최근 보관함(사라진 경로: 다시 찾기·빼기) · 마지막 보관함 자동 열기
- 완료 조건: C:와 D:(또는 임시 폴더 두 곳)에 보관함을 하나씩 만들고 오갈 수 있다 · 시스템 폴더·보관함 안은 막힌다 · 위젯 테스트 통과
- 확인: `flutter test test/ui/start_test.dart` · `flutter run -d windows`

### T17 피드
- M2 · 관련: F-03 · 선행: T16
- 파일: `lib/ui/feed.dart`, `test/ui/feed_test.dart`
- 만들 것: `FeedView`, `PostCard`, `MediaGrid`
- 할 일: design.md 2.5 카드 규칙 · 1~5장 이상 그리드 · 상대 시간 · 고정 포스트 맨 위 · 30개씩 이어 불러오기 · 읽을 수 없는 파일 카드
- 완료 조건: 예시 보관함이 피드에 다 보인다 · 그리드 1·2·3·4·5장 위젯 테스트 통과
- 확인: `flutter test test/ui/feed_test.dart` · `flutter run -d windows`

### T18 작성칸
- M2 · 관련: F-01 · 선행: T17
- 파일: `lib/ui/components.dart`
- 만들 것: `Composer`
- 할 일: 글·첨부(Windows 끌어다 놓기 + 파일 선택)·카테고리·[게시] · 첨부 미리보기 칩 · 놓을 자리 강조
- 완료 조건: 사진을 끌어다 놓아 게시하면 보관함에 `.md`와 사본이 생기고 피드 맨 위에 카드가 나타난다 · Windows IME와 Android 한글 키보드로 조합 중인 글자가 깨지거나 두 번 들어가지 않는다(LC-07)
- 확인: `flutter run -d windows` · 보관함 폴더 확인

### T19 뷰어
- M2 · 관련: F-04, AC-4 · 선행: T17
- 파일: `lib/ui/components.dart`
- 만들 것: `MediaViewer`
- 할 일: 사진 확대·영상 재생(`media_kit`)·탐색·음량·전체화면·←→·Esc·스와이프 · 재생 실패 시 [기본 앱으로 열기]
- 완료 조건: 예시 영상과 큰 영상 하나(아무 드라이브의 파일을 가져와서)를 재생·탐색할 수 있다
- 확인: `flutter run -d windows` · Android 기기

### T20 내비게이터
- M2 · 관련: F-09 · 선행: T17
- 파일: `lib/ui/components.dart`, `test/ui/navigator_test.dart`
- 만들 것: `NavigatorCard`
- 할 일: design.md 2.5 · 3단에서는 오른쪽, 2단은 겹침, 1단은 아래 시트 · [파일 열기] 버튼 (Windows `url_launcher`, Android `open_filex`)
- 완료 조건: 카드를 누르면 내비게이터가 바뀌고 [파일 열기]로 기본 앱이 열린다 · 위젯 테스트 통과
- 확인: `flutter test test/ui/navigator_test.dart`

### T21 범례 · 검색 · 태그 필터
- M2 · 관련: F-05 F-11 F-13 · 선행: T17
- 파일: `lib/ui/components.dart`
- 만들 것: `Legend`, `SearchBox`, `StatusPill`, `EmptyHint`
- 할 일: 범례 숨김·유형 필터·검색·태그 칩 누르면 필터·결과 없음 안내·상태 알약 · 범례·태그는 `KoText.compare`로 정렬, 검색은 `KoText.normalize` 후 비교 · 개수는 `2,000`처럼 ko-KR 형식
- 완료 조건: 필터가 피드에 바로 적용되고 개수가 맞다 · LC-04, LC-08, LC-09를 만족한다
- 확인: `flutter run -d windows`

### T22 수정 · 삭제 · 즐겨찾기 · 카테고리
- M2 · 관련: F-07 F-12, AC-10 · 선행: T21
- 파일: `lib/ui/feed.dart`, `lib/ui/components.dart`
- 만들 것: 카드 메뉴, 그 자리 편집, 카테고리 관리 대화상자
- 할 일: 연필 → 그 자리에서 고치기 → 「파일에 저장됨」 토스트 · 카테고리 옮기기·추가·이름·색 · 삭제 확인 → 휴지통 · ☆ · 고정
- 완료 조건: 고친 내용이 `.md`에 들어가고, 지운 포스트가 `.az/trash/`에 있다
- 확인: `flutter run -d windows` · 보관함 폴더 확인

### T23 가져오기 화면
- M2 · 관련: F-02, AC-4 · 선행: T22, T11
- 파일: `lib/ui/components.dart`
- 만들 것: 가져오기 대화상자(계획 → 진행 → 요약)
- 할 일: 폴더 선택 → 개수·용량·남은 공간 → 진행 막대·취소 → 「새로 n / 건너뜀 n / 실패 n」 · 이어서 가져오기 물어보기
- 완료 조건: 아무 드라이브의 사진·영상 폴더를 가져올 수 있고 원본이 그대로다
- 확인: `flutter run -d windows`

### T24 끊긴 첨부 · 바깥 편집
- M2 · 관련: F-14 F-15, AC-7 · 선행: T23, T8
- 파일: `lib/app.dart`, `lib/ui/components.dart`
- 만들 것: 다시 연결 대화상자, 충돌 대화상자, 연결 끊김 띠
- 할 일: 「파일을 찾을 수 없음」 → 다른 파일로 다시 연결 · `VaultWatcher` 이벤트로 카드 갱신 · 충돌 시 [다시 불러오기] [덮어쓰기] · 보관함 드라이브 분리 시 읽기 전용 띠
- 완료 조건: 메모장으로 `.md`를 고치면 몇 초 안에 카드가 바뀐다 · 끊긴 링크 연습 포스트를 복구할 수 있다
- 확인: `flutter run -d windows`

---

## M3 궤도 뷰

### T25 OrbitLayout · Camera3D
- M3 · 관련: F-08 · 선행: M2 완료
- 파일: `lib/ui/orbit.dart`, `test/orbit_layout_test.dart`
- 만들 것: `OrbitLayout`, `Camera3D`
- 할 일: design.md 3.1·3.2 · 결정적 배치 · 투영·flyTo
- 완료 조건: 같은 자료로 두 번 배치하면 좌표가 같다 · 투영 결과 테스트(중심점이 화면 가운데) 통과
- 확인: `flutter test test/orbit_layout_test.dart`

### T26 OrbitPainter
- M3 · 관련: F-08 · 선행: T25
- 파일: `lib/ui/orbit.dart`
- 만들 것: `OrbitPainter`, `OrbitView`(그리기만)
- 할 일: design.md 3.3의 층 1~5·7·8 · 숨긴 카테고리 8 %
- 완료 조건: 예시 보관함과 가짜 2,000개 자료가 레퍼런스와 비슷한 모습으로 그려진다 · 데스크톱 60 fps
- 확인: `flutter run -d windows --profile`

### T27 라벨 · 선택 · 날아가기
- M3 · 관련: F-08 F-09, AC-8 · 선행: T26
- 파일: `lib/ui/orbit.dart`
- 만들 것: `LabelLayer`, 제스처 처리
- 할 일: 가까운 120개 라벨 · 드래그·휠·핀치·탭·더블탭·길게 누르기 · 선택하면 날아가기 + 글로우 + 내비게이터 · `Enter` 검색 날아가기
- 완료 조건: 마우스와 터치 모두로 AC-8 조작이 된다
- 확인: `flutter run -d windows` · Android 기기

### T28 궤도 여행
- M3 · 관련: F-16 · 선행: T27
- 파일: `lib/ui/orbit.dart`
- 만들 것: `Tour`
- 할 일: 보이는 포스트를 시간순으로 4초마다 · 이전·다음 · 조작하면 멈춤
- 완료 조건: 여행 중 내비게이터가 따라 바뀌고, 드래그하면 멈춘다
- 확인: `flutter run -d windows`

### T29 피드 ↔ 궤도 전환
- M3 · 관련: F-08 F-09, AC-9 · 선행: T27
- 파일: `lib/app.dart`, `lib/ui/orbit.dart`, `lib/ui/feed.dart`
- 만들 것: 전환 애니메이션, 「피드에서 보기」/「궤도에서 보기」
- 할 일: design.md 2.6 전환 · 선택 유지 · 피드는 그 카드로 스크롤, 궤도는 그 노드로 날아감
- 완료 조건: AC-9
- 확인: `flutter run -d windows`

### T30 코치마크와 첫 실행
- M3 · 관련: F-10 F-17, AC-1 · 선행: T29, T13
- 파일: `lib/ui/coach_marks.dart`, `lib/ui/start.dart`
- 만들 것: `CoachMarkOverlay`
- 할 일: design.md 8.1 7단계 · 강조 구멍 + 말풍선 · 건너뛰기·[?] 다시 보기 · 체크리스트 자동 체크 연결
- 완료 조건: 처음 보는 사람이 설명 없이 튜토리얼만 보고 카드 하나를 고친다(직접 해 보고 기록)
- 확인: `flutter run -d windows` (새 임시 보관함)

---

## M4 출시

### T31 움직임 · 입력 · 접근성 다듬기
- M4 · 관련: NF-08 NF-09 NF-12 LC-02~06, AC-15 AC-16 · 선행: M3 완료
- 파일: `lib/ui/*`, `test/ui/accessibility_test.dart`
- 할 일: design.md 2.6 표 전체 점검 · 애니메이션 줄이기 · hover 없이 모든 기능 · 터치 대상 48 dp · 폰 1단 점검 · ISO/IEC 40500 AA 점검(대비, 키보드만으로 조작, 모든 버튼에 `Semantics` 레이블, 글자 200 % 확대, 궤도 뷰의 대체 수단) · 한국어 점검(한글 11,172자 렌더링, ko-KR 날짜·숫자, 시간대 표시, TC-16)
- 완료 조건: 애니메이션 줄이기를 켜면 이동·회전이 없다 · 마우스 없이(터치만) 모든 기능을 쓸 수 있다 · TC-15·TC-16 통과
- 확인: Windows 설정 「애니메이션 효과」 끄고 실행 · Windows 내레이터 · Android TalkBack · `flutter test test/ui/accessibility_test.dart`

### T32 장애 시나리오
- M4 · 관련: 가용성, AC-13 · 선행: T31
- 파일: `integration_test/failure_test.dart`, 필요하면 `lib/*`
- 할 일: design.md 10.2 표의 상황을 하나씩 재현 · 로그 순환(`logs/a_z.log`)
- 완료 조건: 모든 상황에서 앱이 멈추지 않고 자료가 사라지지 않는다
- 확인: `flutter test integration_test/failure_test.dart -d windows`

### T33 성능
- M4 · 관련: 성능, AC-14 · 선행: T31
- 파일: `tools/`(가짜 2,000개 보관함 생성 스크립트), 필요하면 `lib/*`
- 할 일: 포스트 2,000개·첨부 3,000개 보관함으로 측정 · 궤도 뷰 자동 품질 조절(design.md 3.4)
- 완료 조건: 피드 첫 화면 2초 이내 · 궤도 뷰 데스크톱 60 fps, 폰 30 fps 이상(헤드셋은 가능하면) · 측정값을 progress.md에 기록
- 확인: `flutter run --profile` + DevTools

### T34 e2e
- M4 · 관련: AC-1 AC-2 AC-4 AC-6 AC-14 · 선행: T32
- 파일: `integration_test/app_test.dart`
- 할 일: design.md 11.3의 시스템 수준 시험 사례(TC-01~11, TC-13, TC-14)를 `integration_test`로 · 보관함은 시스템 임시 폴더에
- 완료 조건: Windows에서 전부 통과 · Android(debug)에서 통과(기기가 없으면 「미확인」 기록)
- 확인: `flutter test integration_test -d windows` · `flutter test integration_test -d <기기>`

### T35 배포
- M4 · 관련: 배포, AC-11 AC-12 · 선행: T34
- 파일: `android/app/build.gradle`, `android/key.properties`(커밋 안 함), `README.md`
- 할 일: 키스토어 만들기·서명 · `flutter build apk --release --split-per-abi` · 권한 확인 · 폰·헤드셋에 `adb install -r` · `flutter build windows --release` → zip · 키 백업 위치를 progress.md에
- 완료 조건: arm64 APK가 폰에 설치·실행된다(헤드셋은 가능하면, 아니면 「미확인」) · release APK에 INTERNET이 없다 · Windows zip을 다른 폴더에 풀어도 실행된다
- 확인: `apkanalyzer manifest permissions …` · `adb install -r …`

### T36 (Could) 휴지통 화면 · 단축키 · zip 내보내기
- M4 · 관련: F-18 F-19 F-20, AC-10 · 선행: T35
- 파일: `lib/ui/components.dart`, `lib/vault.dart`
- 할 일: 휴지통 목록·복원·비우기 · 단축키(N, /, 1, 2, J, K)는 `PhysicalKeyboardKey`로(한글 자판에서도 동작, LC-10) · 보관함 zip 내보내기
- 완료 조건: 각 기능을 화면에서 쓸 수 있다
- 확인: `flutter run -d windows`

### T37 마무리 점검
- M4 · 관련: 모든 AC · 선행: T35
- 파일: `README.md`, `docs/progress.md`
- 할 일: 스크린샷(시작 화면·피드·궤도·폰) 추가 · requirements.md 4.2의 AC-1~16을 하나씩 확인해 결과를 progress.md에 「시험 완료 보고」 표로(ISO/IEC/IEEE 29119-3) · 모든 문서의 버전을 1.0으로 올리고 상태를 「승인」으로(프로젝트 소유자 확인 후)
- 완료 조건: 모든 AC가 「통과」 또는 이유가 적힌 「미확인」이다 · 문서 정보 표와 변경 이력이 갱신되었다
- 확인: 문서 검토

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.1 | 2026-10-21 | 최초 작성 (T1~T37) | Claude Code |
| 0.2 | 2026-10-21 | 문서 정보 표, ISO/IEC/IEEE 12207 프로세스 대응표 추가. 시험 사례(TC)·자료 요구(DR)·접근성(AC-15, T31) 연결 | Claude Code |
| 0.3 | 2026-10-21 | 대상 지역 대한민국(ISO 3166-1 `KR`) 반영: T2 로캘, T3 `KoText`, T18 한글 입력, T21 정렬·검색·숫자, T31 한국어 점검, T36 물리 키 단축키, AC-16 | Claude Code |
