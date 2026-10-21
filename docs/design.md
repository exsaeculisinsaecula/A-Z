# 아키텍처 기술서 (AD)

| 항목 | 내용 |
|---|---|
| 문서 번호 | AZ-AD |
| 문서 이름 | A-Z 아키텍처 기술 + 시험 계획 |
| 버전 · 상태 | 1.0 · 초안 (검토 대기) |
| 작성일 · 수정일 | 2026-10-21 · 2026-10-21 |
| 작성 · 승인 | Claude Code (AI) · 프로젝트 소유자 (미승인) |
| 적용 표준 | ISO/IEC/IEEE 42010:2022, ISO/IEC/IEEE 29119-3:2021 |
| 대상 지역 | 대한민국 (ISO 3166-1 `KR`), 로캘 `ko-KR` |
| 상위 문서 | [AZ-SRS](requirements.md) |

**[처음으로](../README.md)** · [요구사항](requirements.md) · **[설계](design.md)** · [작업 순서](tasks.md) · [진행 상황](progress.md) · [작업 지침](../AGENTS.md)

목차: 0 아키텍처 개요 · 1 레퍼런스 · 2 화면 · 3 궤도 뷰 · 4 보관함 · 5 저장 위치 · 6 객체 · 7 흐름 · 8 튜토리얼 · 9 플랫폼 · 10 오류 · 11 시험 · 12 배포 · 13 패키지 · 14 위험

---

## 0. 아키텍처 개요 (ISO/IEC/IEEE 42010)

### 0.1 대상

A-Z: 보관함 폴더 하나에 모은 사진·영상을 피드와 3D 궤도로 보여주는 로컬 앱.

### 0.2 이해관계자와 관심사

| 이해관계자 | 관심사 |
|---|---|
| 사용자 (본인) | 쓰기 쉽고, 자료를 잃지 않기, 옮기기 쉬움 |
| 개발자 | 구조 이해, 고치기·시험하기 쉬움 |
| AI 도구 | 문서만으로 이어서 작업 |
| 다른 앱 | 보관함을 읽고 써도 깨지지 않음 |

### 0.3 맥락

```
   user ───►  A-Z app  ───► OS: 탐색기, 기본 앱
              (SCREEN→LOGIC→STORAGE)
                    │
                    ▼
              보관함 폴더 (아무 드라이브)  ◄── Obsidian, 메모장
              *.md + 첨부 + .az/
                    ▲
                    │ 복사만 (원본은 읽기 전용)
              바깥 사진 · 영상 폴더
```

---

## 1. 레퍼런스 분석

참고: 「OBSIDIAN SYNC — SECOND BRAIN」 58.5초 화면 녹화. 카테고리별 구체와 기울어진 궤도 링, 알약 라벨, NAVIGATOR 카드.

| 요소 | A-Z에 가져올 것 |
|---|---|
| 공간 | 옅은 라벤더 흰 배경 + 동심원 링 |
| 구체 | 카테고리 = 반투명 구체 + 광택 |
| 라벨 | 알약 모양 (흰 바탕·색 테두리·색 점) |
| 선택 | 색 채움 + 글로우 |
| 카메라 | 날아가기, 거리별 표시 단계 |

색:

| 용도 | 색 |
|---|---|
| 배경 | `#F3F3FA` · `#EEEEF7` · `#E8EAF6` |
| 선 | `#D9E1ED` · `#B6B6BF` |
| 글씨 | `#090911` · `#302F35` · `#726E76` |
| 주 버튼 | `#4B5CDE` → `#6A3BD9` |
| 카테고리 | `#2970FC` `#00C080` `#E9980B` `#DE57A3` `#5C4AEC` `#18B791` `#F62066` `#D19E04` `#6A3BD9` |
| 미분류 | `#868DA7` |

글씨용 대비 4.5:1 이상 색은 `categoriesText` 별도 팔레트 (WCAG 2.0 AA).

---

## 2. 화면 설계

### 2.1 원칙

1. 흰 공간, 색은 카테고리에만
2. 모두 떠 있다 (큰 둥근 모서리 + 다층 그림자)
3. 카메라처럼 움직인다
4. 트위터처럼 읽기 쉽게 (피드 폭 600 dp)
5. 파일이 보인다 ([파일 열기])
6. 누구나 읽을 수 있게 (WCAG AA)

### 2.2 디자인 토큰 (theme.dart)

- `AzColors`: 공간·글씨·주 버튼·카테고리·`categoriesText`
- `AzShapes`: 간격 8 dp 배수, 터치 48 dp, 반경 20·24 dp, 그림자 3단계
- `AzMotion`: fast 160 ms · base 320 ms · slow 560 ms · fly 1,200 ms

### 2.3 화면 배치

```
데스크톱 (1200 dp+, 3단):
┌─────────────────────────────────────────────────────────┐
│ [A 검색]                 A - Z                    [B]    │
│ [C 범례]   [D 작성칸]                [F 내비게이터]      │
│            [E 피드 (600 dp)]                             │
│ [H 가져오기]        [G 컨트롤 막대]                      │
└─────────────────────────────────────────────────────────┘

폰 (800 dp 미만, 1단):
┌──────────────────┐
│ [≡]  A - Z  [?]  │
│ [E 피드]         │
│ [G 컨트롤]       │
└──────────────────┘
```

| 영역 | 위젯 | 내용 |
|---|---|---|
| A | `SearchBox` | 검색, 궤도에서 Enter 시 날아가기 |
| B | `StatusPill` | 제목·개수·저장 시각 |
| C | `Legend` | 카테고리 알약 (색·이름·개수) |
| D | `Composer` | 글·첨부·카테고리·게시 |
| E | `FeedView` | 카드 목록 |
| F | `NavigatorCard` | 선택 상세 |
| G | `ControlBar` | 뷰 전환·여행·이전·다음 |
| H | 가져오기 | 가져오기·보관함 열기 |

### 2.4 반응형

| 폭 | 배치 |
|---|---|
| 1200 dp+ | 3단 (범례 · 피드 · 내비게이터) |
| 800~1199 dp | 2단 (범례 접힘 · 피드) |
| 800 dp 미만 | 1단 |

### 2.5 모션

| 상황 | 움직임 | 시간 |
|---|---|---|
| 카드 등장 | 아래에서 페이드 | 320 ms |
| 썸네일 → 뷰어 | Hero 확대 | 360 ms |
| 노드 선택 | 카메라 날아가기 | 1,200 ms |
| 뷰 전환 | 축소 후 전환 | 560 ms |
| reduced-motion | 페이드만 | 120 ms |

---

## 3. 궤도 뷰 (2.5D)

`CustomPainter`로 3D 좌표를 투영. 엔진 없음.

```
OrbitLayout (결정적 배치) → Camera3D (투영) → OrbitPainter (Canvas)
                               ▲                    │
                          제스처 · Tour          LabelLayer (120개)
```

- 카테고리 구체 + 큰 타원 링 + 포스트 노드
- 태그로 이웃 연결 (시간순)
- 드래그=회전, 휠=이동, 탭=선택, 더블탭=전체보기
- 라벨 LOD: 가까운 120개, 성능 낮으면 60개로 축소

---

## 4. 보관함 형식

```
A-Z 보관함/
 ├─ <카테고리>/
 │   ├─ 2026-10-01 0930 제목.md
 │   └─ 첨부/
 ├─ 미분류/
 └─ .az/
     ├─ vault.json
     ├─ settings.json
     ├─ index.json
     ├─ thumbs/
     └─ trash/
```

### 4.1 포스트 파일

```markdown
---
id: p_3f9a1c2b7d10
created: 2026-10-01T09:30:00+09:00
updated: 2026-10-21T13:20:00+09:00
starred: true
pinned: false
---
제목
본문 #태그

![[카테고리/첨부/ring-01.jpg]]
```

규칙: UTF-8, LF, YAML 1.2 + GFM. 경로 `/` 구분자, 이름 NFC, 시각 ISO 8601.

---

## 5. 저장 위치

```
StorageLocator (interface)
 ├─ WindowsStorageLocator   win32 드라이브 API
 └─ AndroidStorageLocator   외부 저장소 + 권한
```

`LocationCheck`: 쓰기 권한 · 남은 공간 · 시스템 폴더 금지 · 중첩 금지 · 네트워크 경고.

---

## 6. 객체 구조

### 6.1 계층

```
┌─────────────────────────────────────────────────┐
│ main.dart     합성 루트                           │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│ SCREEN   app.dart · ui/*   (보여주기만)            │
└─────────────────────────────────────────────────┘
                    │ 호출만
                    ▼
┌─────────────────────────────────────────────────┐
│ LOGIC    archive · media · importer · tutorial   │
└─────────────────────────────────────────────────┘
                    │ 읽기 / 쓰기
                    ▼
┌─────────────────────────────────────────────────┐
│ STORAGE  vault.dart · storage.dart               │
└─────────────────────────────────────────────────┘
```

### 6.2 클래스 책임표

| 파일 | 클래스 | 책임 |
|---|---|---|
| main.dart | `main()` | 객체 조립 |
| app.dart | `AzApp` · `AppScope` · `AppState` · `HomeShell` · `AzRegion` | 테마·상태·배치·지역 |
| archive.dart | `Post` · `MediaRef` · `Category` · `PostQuery` · `TagParser` · `Archive` · `Clock` · `KoText` · `AzException` | 기록 모델·검색 |
| vault.dart | `Vault` · `PostCodec` · `AtomicWriter` · `VaultIndex` · `VaultSettings` · `VaultWatcher` · `Trash` | 보관함 읽기·쓰기 |
| storage.dart | `StorageLocator` · `WindowsStorageLocator` · `AndroidStorageLocator` · `StorageVolume` · `LocationCheck` · `VaultCatalog` | 드라이브·위치 |
| media.dart | `MediaProbe` · `PhotoProbe` · `VideoProbe` · `ProbeRegistry` · `MediaInfo` · `ThumbnailCache` | 사진·영상 |
| importer.dart | `FolderScanner` · `ContentHasher` · `ImportJob` | 가져오기 |
| tutorial.dart | `TutorialStep` · `TutorialController` · `SampleVaultSeeder` | 튜토리얼 |
| theme.dart | `AzColors` · `AzShapes` · `AzMotion` · `AzTheme` | 디자인 토큰 |
| ui/start.dart | `VaultStartScreen` | 시작 화면 |
| ui/components.dart | `Legend` · `SearchBox` · `StatusPill` · `NavigatorCard` · `ControlBar` · `Composer` · `MediaViewer` · `Toast` · `EmptyHint` | 공통 위젯 |
| ui/feed.dart | `FeedView` · `PostCard` · `MediaGrid` | 피드 |
| ui/orbit.dart | `OrbitView` · `OrbitLayout` · `Camera3D` · `OrbitPainter` · `LabelLayer` · `Tour` | 궤도 |
| ui/coach_marks.dart | `CoachMarkOverlay` | 튜토리얼 UI |

### 6.3 확장 지점

| 지점 | 본보기 | 추가 방법 |
|---|---|---|
| `MediaProbe` | `PhotoProbe` | 클래스 1개 + 등록 |
| `StorageLocator` | `WindowsStorageLocator` | 구현 1개 |
| `TutorialStep` | 예시 단계 | 객체 1개 |

---

## 7. 흐름도

### 포스트 작성
```
Composer → AppState.create() → Archive.create()
  → TagParser → Vault.copyAttachment() → Vault.writePost() (AtomicWriter)
  → notifyListeners() → FeedView · OrbitView
```

### 가져오기
```
폴더 선택 → ImportJob.plan (개수·용량·공간)
  → ImportJob.run (isolate)
      파일마다: Hasher → 복사 → Probe → writePost → ThumbnailCache
  → 완료 요약 (새로 n / 건너뜀 n / 실패 n)
```

---

## 8. 튜토리얼

코치마크 7단계: 환영 → 카드 고치기 → 작성칸 → 범례 → 궤도 → 내비게이터 → 백업.

예시 보관함: 시작하기 1 + 포스트 6 + 사진 5 + 영상 1 (직접 생성, 5 MB 이하).

---

## 9. 플랫폼 차이

| 항목 | Windows | Android |
|---|---|---|
| 볼륨 | win32 드라이브 | 내부·SD·USB |
| 권한 | 불필요 | 모든 파일 접근 |
| 변경 감지 | `Directory.watch` | 앱 복귀 시 |
| 기본 배치 | 3단 | 1~2단 |

---

## 10. 오류 처리

```
AzException
 ├─ NotFound · InvalidLocation · StorageUnavailable
 ├─ VaultConflict · CorruptedFile · MediaUnsupported
```

| 상황 | 처리 |
|---|---|
| index.json 깨짐 | 다시 생성 |
| 첨부 없음 | 「파일을 찾을 수 없음」 |
| 저장 중 종료 | .tmp 정리, 원본 유지 |
| 드라이브 분리 | 읽기 전용 + 재시도 |
| 재생 실패 | 기본 앱으로 열기 |

---

## 11. 시험 계획 (ISO/IEC/IEEE 29119-3)

| 수준 | 도구 | 대상 |
|---|---|---|
| 단위 | `flutter test` | 모델·저장소·서비스 (MemoryFileSystem) |
| 위젯 | `flutter test` | 화면 조각 |
| 시스템 | `integration_test` | 실제 앱 시나리오 |

| TC | 시나리오 | 기준 |
|---|---|---|
| TC-01 | 첫 실행 → 튜토리얼 → 작성 | AC-1 |
| TC-02 | 보관함 여러 개 | AC-2 |
| TC-03 | 금지 위치 | AC-3 |
| TC-04 | 가져오기 → 원본 불변 | AC-4 |
| TC-05 | 재가져오기 | AC-5 |
| TC-06 | 폴더 복사 → 이식 | AC-6 |
| TC-07 | 외부 편집 반영 | AC-7 |
| TC-08 | 궤도 조작 | AC-8 |
| TC-09 | 뷰 간 이동 | AC-9 |
| TC-10 | 휴지통 복원 | AC-10 |
| TC-11 | 오프라인 · 권한 | AC-11 |
| TC-12 | 사이드로드 | AC-12 |
| TC-13 | 장애 상황 | AC-13 |
| TC-14 | 성능 · 회귀 | AC-14 |
| TC-15 | 접근성 | AC-15 |
| TC-16 | 한국어 · 지역화 | AC-16 |

---

## 12. 빌드 · 배포

```
flutter analyze → flutter test → flutter test integration_test -d windows
  ├─ flutter build windows --release  → A-Z-windows.zip
  └─ flutter build apk --release --split-per-abi
       → app-arm64-v8a-release.apk (서명, INTERNET 없음)
```

앱 id: `app.az.archive` (가칭).

---

## 13. 패키지

| 패키지 | 용도 |
|---|---|
| media_kit (+ video) | 영상 재생 |
| fc_native_video_thumbnail | 영상 썸네일 |
| exif | 촬영일 |
| yaml | 머리말 |
| file · path · path_provider | 파일·경로 |
| permission_handler | Android 권한 |
| win32 · ffi | Windows 드라이브 |
| crypto | SHA-1 |
| file_picker · desktop_drop | 파일 선택·드래그 |
| vector_math | 3D 투영 |
| url_launcher · open_filex | 파일 열기 |
| flutter_localizations · intl · unorm_dart | ko-KR · NFC |
| flutter_lints · integration_test | 분석·시험 |

---

## 14. 위험

| 위험 | 대응 |
|---|---|
| Flutter·Android SDK 설치 | T1에서 확인 |
| Quest 저장소 권한 | adb appops |
| 궤도 뷰 성능 | LOD 자동 조절 |
| media_kit APK 크기 | split-per-abi |
| 한글 경로 cv2 문제 | Pillow 사용 |
| 긴 경로 (Windows 260자) | 경고 + 짧은 이름 제안 |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 1.0 | 2026-10-21 | ISO 한국 표준으로 처음부터 재작성 | Claude Code |
