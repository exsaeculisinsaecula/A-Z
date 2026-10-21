# 아키텍처 기술서 (AD) — 어떤 구조로 만들까

[처음으로](../README.md) · [요구사항](requirements.md) · **설계** · [작업 순서](tasks.md) · [진행 상황](progress.md) · [작업 지침](../AGENTS.md)

| 항목 | 내용 |
|---|---|
| 문서 번호 | AZ-AD |
| 문서 이름 | A-Z 아키텍처 기술서 (설계) |
| 버전 · 상태 | 0.3 · 초안 (검토 대기) |
| 작성일 · 수정일 | 2026-10-21 · 2026-10-21 |
| 작성 · 승인 | Claude Code (AI) · 프로젝트 소유자 (미승인) |
| 적용 표준 | ISO/IEC/IEEE 42010:2022 (아키텍처 기술), ISO/IEC/IEEE 29119-3:2021 (시험 문서, 11절), ISO/IEC 40500:2012 (접근성, 2절), ISO 3166-1:2020 (국가 코드, 2.7절) |
| 대상 지역 | 대한민국 — ISO 3166-1 `KR` · `KOR` · `410`, 로캘 `ko-KR` |
| 상위 문서 | [AZ-SRS 요구사항](requirements.md) |

목차: 0 아키텍처 기술 개요 · 1 레퍼런스 분석 · 2 화면 설계 · 3 궤도 뷰 · 4 보관함 형식 · 5 저장 위치 · 6 객체 구조 · 7 흐름도 · 8 튜토리얼과 예시 보관함 · 9 플랫폼 차이 · 10 가용성과 오류 · 11 시험 계획 · 12 빌드·배포 · 13 패키지 · 14 위험 · 변경 이력

---

## 0. 아키텍처 기술 개요 (ISO/IEC/IEEE 42010)

### 0.1 대상 시스템
A-Z: 사진·영상·메모를 보관함 폴더 하나에 모아 피드와 3D 궤도 공간으로 보여주는 로컬 앱(Windows, Android). 범위와 요구는 [AZ-SRS](requirements.md).

### 0.2 이해관계자와 관심사

| 이해관계자 | 관심사 | 다루는 뷰 |
|---|---|---|
| 앱 사용자 (본인) | 쉽게 익히기, 보기 좋은 화면, 자료를 잃지 않기, 옮기기·백업이 쉬움 | 화면, 정보, 신뢰성 |
| 개발자 (사람) | 구조 이해, 고치기 쉬움, 시험하기 쉬움 | 모듈, 실행, 시험 |
| AI 코딩 도구 | 대화 없이 문서만으로 이어서 작업, 이름·규칙이 분명함 | 모듈, 정보 |
| 다른 앱 (Obsidian, 메모장, 동기화 도구) | 같은 보관함을 읽고 써도 깨지지 않음 | 정보 |
| 미래의 XR 앱 개발자 | 보관함 형식만 보고 같은 자료를 읽기 | 정보, 배치 |
| 배포 담당 | APK·Windows 빌드, 오프라인 보장 | 배치 |

### 0.3 관점과 뷰

```
viewpoint            view (section in this document)
-------------------  ---------------------------------------------
context              0.4 context, 9 platforms
user interface       1 reference, 2 screens, 3 orbit view, 8 tutorial
module (logical)     6 object structure, 13 packages
information          4 vault format, 5 storage locations
runtime (process)    7 flows, 10 availability and errors
deployment           9 platforms, 12 build and release
test                 11 test plan
```

### 0.4 맥락 뷰

```
                +-------------------------------+
   user ------->|            A-Z app            |-------> OS shell: file manager, default apps
 (mouse, touch, |  SCREEN -> LOGIC -> STORAGE   |
  XR pointer)   +---------------+---------------+
                                |
                                v  read / write (no network)
                +-------------------------------+
                |  vault folder on any volume   |<------- Obsidian, text editor, sync tools
                |  *.md + attachments + .az/    |
                +-------------------------------+
                                ^
                                |  copy only (read-only source)
                    outside photo / video folders
```

### 0.5 대응 관계 (요구 → 설계 요소)
요구에서 설계·작업·시험까지의 추적표는 [AZ-SRS 5.1](requirements.md)에 있다. 이 문서의 클래스 이름은 6.2 표가 기준이다.

### 0.6 아키텍처 결정과 근거
결정은 [진행 상황](progress.md)의 「결정 기록」에 D-번호로 남긴다. 이 아키텍처에 영향을 준 결정:

| 결정 | 요약 | 영향을 받는 절 |
|---|---|---|
| D-02 | Flutter 하나로 Windows + Android | 6, 9, 12, 13 |
| D-04 | 보관함 폴더(.md + 첨부), 가져올 때 사본 | 4, 7 |
| D-05 | 아무 드라이브·위치에 새 보관함 | 5, 7 |
| D-06 | 스타터형 평면 + 객체지향 | 6 |
| D-07 | 궤도 뷰는 `CustomPainter` 2.5D | 3 |
| D-08 | 영상은 `media_kit` | 2.5, 13 |
| D-10 | 중복 판정은 내용 해시 | 6, 7 |
| D-15 | 글씨에는 대비 4.5:1 이상의 카테고리 글씨 색 | 2.2, 2.5, 3.3 |
| D-16 | 보관함 경로 구분자 `/`, 이름은 NFC | 4 |
| D-17 | 대상 지역 대한민국(ISO 3166-1 `KR`), 로캘 `ko-KR` | 2.7, 6.2, 13 |

---

## 1. 레퍼런스 분석

참고 영상: 58.5초 화면 녹화(2746×1818, 약 56 fps). 「OBSIDIAN SYNC — SECOND BRAIN」이라는 3D 지식 그래프 화면으로,
노트 437개·링크 830개를 11개 카테고리로 묶어 우주 공간처럼 띄워 놓고 마우스로 날아다니며 노트를 고르는 모습이다.
0.5초부터 58.1초까지 13프레임을 뽑아 관찰했고, 색은 k-means와 범례 점 샘플링으로 뽑았다.

| 요소 | 레퍼런스에서 본 것 | A-Z에 가져올 것 |
|---|---|---|
| 공간 | 아주 옅은 라벤더빛 흰 배경, 가장자리는 조금 더 푸름 | 배경 토큰 `space`·`spaceEdge`, 방사형 그라데이션 |
| 구체 | 카테고리마다 반투명 파스텔 구체. 얇은 테두리, 왼쪽 위 광택, 일부는 토성처럼 기울어진 타원 링 | 카테고리 = 구체 하나, 빌보드 원으로 그림 |
| 궤도 링 | 전체 중심을 감싸는 큰 동심 타원 여러 겹, 카테고리 색으로 아주 옅게 | 장면 중심 궤도 링 3겹, 피드 뷰 배경에도 같은 링 |
| 노드 | 멀리서는 카테고리 색 점, 가까이 가면 알약 라벨(흰 바탕·색 테두리·색 점·굵은 검은 글씨) | 거리에 따라 점 ↔ 라벨 알약 |
| 선택 | 선택한 라벨은 카테고리 색으로 꽉 차고 흰 글씨, 그 클러스터 뒤로 같은 색의 부드러운 빛 | 선택 하이라이트 + 클러스터 글로우 |
| 링크 | 노드 사이 가는 회색 직선이 다발처럼 | 같은 태그 포스트끼리 연결 |
| 카테고리 이름 | 클러스터 옆 공간에 넓은 자간의 카테고리 색 글씨 | 3D 공간 속 카테고리 이름 |
| 왼쪽 | 위: 「노트를 검색해서 날아가기 (Enter)」 / 아래: 카테고리 알약 범례(색 점·이름·개수), 누르면 흐리게 꺼짐 | [A] 검색, [C] 범례 |
| 위 가운데 | 넓은 자간 굵은 제목(두 번째 단어는 글자마다 다른 색), 부제, 「동기화 시각 \| 노트 수 \| 링크 수」 알약 | [B] 제목·상태 알약 |
| 오른쪽 | NAVIGATOR 카드: 마스코트 원형 아바타, 카테고리 점+이름, 굵은 제목, 본문 요약, 「갱신일 · 링크 수」, 보라 주 버튼 + 흰 닫기 버튼 | [F] 내비게이터 |
| 아래 가운데 | 떠 있는 흰 알약 막대: 마스코트 · 파랑-보라 그라데이션 「시작」 · 「← 이전」 「다음 →」 | [G] 컨트롤 막대 |
| 오른쪽 아래 | 작은 대문자 조작 안내 「드래그 회전 / 휠 전진·후퇴 / 클릭 선택 / 더블클릭 전체로」 | [I] 조작 안내 |
| 왼쪽 아래 | 「데이터 불러오기 / 내보내기」 알약 | [H] 가져오기·보관함 |
| 움직임 | 카메라가 클러스터 사이를 부드럽게 날아가며, 가까우면 라벨이 늘고 멀어지면 태양계 같은 전체 모습(구체·링·점 구름)이 됨 | 카메라 날아가기, 거리별 표시 단계, 전체 보기 |

뽑은 색:

| 용도 | 색 |
|---|---|
| 배경 | `#F3F3FA` · `#EEEEF7` · 가장자리 `#E8EAF6` |
| 선·흐린 요소 | `#D9E1ED` · `#B6B6BF` |
| 글씨 | 제목 `#090911` · 본문 `#302F35` · 보조 `#726E76` |
| 주 버튼 | `#4B5CDE` → `#6A3BD9` 그라데이션 |
| 카테고리 | 파랑 `#2970FC` · 초록 `#00C080` · 주황 `#E9980B` · 분홍 `#DE57A3` · 남보라 `#5C4AEC` · 청록 `#18B791` · 빨강 `#F62066` · 금색 `#D19E04` · 보라 `#6A3BD9` |
| 미분류 | 회색 `#868DA7` |

---

## 2. 화면 설계

### 2.1 원칙
1. **흰 공간**: 화면 대부분은 비어 있는 밝은 공간이다. 꾸밈은 옅은 링과 구체뿐이다.
2. **색은 카테고리에만**: 바탕·카드·글씨는 무채색이다. 색은 카테고리 점·테두리·글로우·선택에만 쓴다(주 버튼 하나만 예외).
3. **모두 떠 있다**: 카드·알약·패널은 흰 바탕 + 큰 둥근 모서리 + 부드러운 다층 그림자. 화면 테두리에 붙은 막대가 없다.
4. **움직임은 카메라처럼**: 화면이 바뀌는 게 아니라 시점이 옮겨 가는 느낌(확대·날아가기·깊이).
5. **트위터처럼 읽기 쉽게**: 피드는 폭 600 dp 한 줄, 카드 구조가 늘 같고, 정보가 촘촘하다.
6. **파일이 보인다**: 기록이 파일이라는 사실을 숨기지 않는다([보관함 폴더 열기], [파일 열기]). 고치는 법을 따로 배우지 않아도 되게.
7. **누구나 읽을 수 있게** (ISO/IEC 40500 AA): 글씨는 바탕과 대비 4.5:1 이상(큰 글씨 3:1). 카테고리는 색과 함께 **이름**으로도 구분한다(색만으로 구분하지 않음). 데스크톱에서는 키보드만으로 모든 기능을 쓰고, 모든 버튼에 화면 낭독기 레이블(`Semantics`)을 단다. 글자를 200 %까지 키워도 기능이 사라지지 않는다.

### 2.2 디자인 토큰 (`lib/theme.dart`)

```dart
abstract final class AzColors {
  // 공간
  static const space = Color(0xFFF3F3FA);
  static const spaceAlt = Color(0xFFEEEEF7);
  static const spaceEdge = Color(0xFFE8EAF6);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFD9E1ED);
  static const muted = Color(0xFFB6B6BF);
  // 글씨
  static const inkStrong = Color(0xFF090911);
  static const ink = Color(0xFF302F35);
  static const inkSub = Color(0xFF726E76);
  // 주 버튼 그라데이션
  static const primary = Color(0xFF4B5CDE);
  static const primaryEnd = Color(0xFF6A3BD9);
  // 카테고리 팔레트: 만든 순서대로 배정, 10번째부터 처음으로 돌아감
  static const categories = <Color>[
    Color(0xFF2970FC), Color(0xFF00C080), Color(0xFFE9980B),
    Color(0xFFDE57A3), Color(0xFF5C4AEC), Color(0xFF18B791),
    Color(0xFFF62066), Color(0xFFD19E04), Color(0xFF6A3BD9),
  ];
  static const uncategorized = Color(0xFF868DA7);
  // 글씨용 카테고리 색: 위 팔레트를 어둡게 해서 흰 바탕·space 바탕 모두 4.5:1 이상
  // (태그 글씨, 카테고리 이름, 선택된 라벨의 채움 + 흰 글씨에 사용)
  static const categoriesText = <Color>[
    Color(0xFF1563FC), Color(0xFF008055), Color(0xFF996407),
    Color(0xFFCB2884), Color(0xFF5C4AEC), Color(0xFF107C63),
    Color(0xFFDD094E), Color(0xFF8B6903), Color(0xFF6A3BD9),
  ];
  static const uncategorizedText = Color(0xFF666E8C);
}

abstract final class AzShapes {
  static const unit = 8.0;          // 간격은 8의 배수
  static const minTouch = 48.0;     // 터치·XR 포인터 최소 대상
  static const radiusPill = 999.0;
  static const radiusCard = 20.0;
  static const radiusPanel = 24.0;
  static const radiusMedia = 16.0;
  // 그림자 3단계: float1(알약) · float2(카드) · float3(패널·뷰어)
}

abstract final class AzMotion {
  static const fast = Duration(milliseconds: 180);
  static const base = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 900);
  static const fly = Duration(milliseconds: 1200);
  static const easeOut = Cubic(0.2, 0.8, 0.2, 1);
  static const easeInOut = Curves.easeInOutCubic;
}
```

색에서 파생되는 값: 구체 채움 = 카테고리 색 12 % + 테두리 40 % / 글로우 = 35 % → 0 % 방사형 / 링크 선 = `muted` 25 % / 숨긴 카테고리 = 8 %.

색 대비 (ISO/IEC 40500 AA, 2026-10-21 계산):

| 글씨 · 바탕 | 대비 | 판정 |
|---|---|---|
| `inkStrong` #090911 · 흰색 / `space` | 19.83 / 17.96 | 통과 |
| `ink` #302F35 · 흰색 / `space` | 13.26 / 12.00 | 통과 |
| `inkSub` #726E76 · 흰색 / `space` | 4.99 / 4.52 | 통과 (여유 적음, 더 밝게 바꾸지 말 것) |
| `muted` #B6B6BF · 흰색 | 2.01 | 글씨 금지 (장식·선 전용) |
| 흰 글씨 · `primary` #4B5CDE / `primaryEnd` #6A3BD9 | 5.41 / 6.48 | 통과 |
| `categories` 팔레트를 글씨로 · 흰색 | 2.34 ~ 6.48 | 9개 중 7개 미달 → 글씨에는 `categoriesText` 사용 |
| `categoriesText` · 흰색 / `space` | 4.97 이상 / 4.50 이상 | 통과 |

규칙: 점·테두리·구체·글로우에는 `categories`, 글씨와 「색 채움 + 흰 글씨」에는 `categoriesText`를 쓴다. 대비는 T14에서 자동 시험으로 확인한다.

글꼴: Pretendard(앱에 포함, OFL). 제목 「A - Z」는 굵기 800·넓은 자간이고, `A`는 `inkStrong`, `-`는 `muted`, `Z`는 카테고리 팔레트 그라데이션이다. 부제 「PHOTO // VIDEO // MEMO」는 11sp에 넓은 자간, 카드 메모는 15sp에 줄 간격 1.6, 라벨 알약은 13 sp 굵게.

마스코트: 직접 그린 동심원 링 로고(원 안의 작은 원과 기울어진 링). 저작권 캐릭터는 쓰지 않는다.

### 2.3 화면 구조도

**보관함 시작 화면** (첫 실행, 또는 [H] → 보관함 바꾸기)
```
+--------------------------------------------------------------+
|                          A  -  Z                             |
|                   PHOTO // VIDEO // MEMO                     |
|                                                              |
|   +--------------------+  +--------------------+             |
|   |  [+] NEW VAULT     |  |  [>] OPEN FOLDER   |             |
|   +--------------------+  +--------------------+             |
|                                                              |
|   RECENT                                                     |
|   (o) D:\A-Z vault ............ 437 posts . 2h ago           |
|   (o) E:\backup\A-Z vault ..... (missing) [find] [remove]    |
|                                                              |
|   NEW VAULT > where?                                         |
|   ( C:  local   120 GB free )  ( D:  local   1.2 TB free )   |
|   ( E:  usb      64 GB free )  ( Z:  network  ! slow     )   |
|   [browse...]   name: [ A-Z vault      ]   [x] with samples  |
|                                             [ create ]       |
+--------------------------------------------------------------+
```
(그림 속 글자는 자리표시다. 실제 화면은 한국어이고, 드라이브 목록은 그 기기에 있는 것만 보인다.)

**피드 뷰** (폭 1200 dp 이상, 3단)
```
+------------------------------------------------------------------------------+
| [A  search ........ ]                  A  -  Z                               |
|                                 PHOTO // VIDEO // MEMO                       |
|                          ( saved 10-21 13:20 | 437 | 300 | 40 )  [B]         |
|                                                                              |
| [C]                    +-----------------------------+     +---------------+ |
|  (o science  128)      | [D] write something...      |     | [F] NAVIGATOR | |
|  (o design    42)      |  [media] [category v] [post]|     | o science     | |
|  (o travel    97)      +-----------------------------+     | Title         | |
|  (o none      15)      +-----------------------------+     | +-----------+ | |
|                        | (@) science . 2h ago      * |     | |   thumb   | | |
|  type                  | memo text ... #design       |     | +-----------+ | |
|  (all) (photo)         | +-------------------------+ |     | summary ...   | |
|  (video) (memo)        | |                         | |     | [open] [x]    | |
|                        | |         > 0:58          | |     +---------------+ |
|                        | +-------------------------+ |                       |
|                        | #design #reference          |                       |
|                        +-----------------------------+                       |
|                          [E] feed (600dp)                                    |
|                                                                              |
| [H import/vault]     ( (@) [FEED|orbit]   < prev   next > )  [G]             |
+------------------------------------------------------------------------------+
```

**궤도 뷰** (같은 틀)
```
+------------------------------------------------------------------------------+
| [A  search ........ ]                  A  -  Z                               |
|                          ( saved 10-21 13:20 | 437 | 300 | 40 )  [B]         |
|                                                                              |
| [C]                                                        +---------------+ |
|  (o science  128)           .-''''''''''''''''''-.         | [F] NAVIGATOR | |
|  (o design    42)       .-'      ( DESIGN )        '-.     | o science     | |
|  (o travel    97)     .'       . : . : .              '.   | Title         | |
|  (o none      15)    /    ( SCIENCE )-----[o note]      \  | +-----------+ | |
|                     |     . : : : .       \  ( TRAVEL ) |  | |   thumb   | | |
|  type                \                     \  . : : .  /   | +-----------+ | |
|  (all) (photo)        '.       ( NONE )     \--'     .'    | summary ...   | |
|  (video) (memo)         '-.     . : .            .-'       | [open] [x]    | |
|                             '-..................-'         +---------------+ |
|                                                                              |
| [H import/vault]   ( (@) [feed|ORBIT] [tour]  < prev  next > )  [G]          |
|                        drag/swipe: rotate . wheel/pinch: move . tap: select  |
+------------------------------------------------------------------------------+
```

**폰** (폭 800 dp 미만, 1단)
```
+------------------------+
| [=]     A - Z     [?]  |
|  ( 437 | 300 | 40 )    |
| +--------------------+ |
| | (@) design . 2h  * | |
| | memo text #tag     | |
| | +-------+--------+ | |
| | |  img  |  img   | | |
| | +-------+--------+ | |
| +--------------------+ |
| +--------------------+ |
| | ...                | |
|                        |
|  ( [FEED|orbit]  [+] ) |
+------------------------+
```

| 영역 | 위젯 | 내용 |
|---|---|---|
| 시작 화면 | `VaultStartScreen` | 새로 만들기(드라이브·위치·이름·예시 포함) / 열기 / 최근 보관함 |
| [A] 검색 | `SearchBox` | 메모·태그·파일 이름 검색. 궤도 뷰에서는 `Enter`로 첫 결과로 날아감 |
| [B] 제목·상태 | `StatusPill` | 「A - Z」 제목, 마지막 저장 시각·포스트·사진·영상 수 |
| [C] 범례 | `Legend` | 카테고리(=폴더) 알약: 색 점·이름·개수, 누르면 숨김. 아래에 유형 필터 |
| [D] 작성칸 | `Composer` | 글·첨부(끌어다 놓기)·카테고리·[게시] |
| [E] 피드 | `FeedView` · `PostCard` · `MediaGrid` | 카드 목록 |
| [F] 내비게이터 | `NavigatorCard` | 선택한 포스트 상세 |
| [G] 컨트롤 막대 | `ControlBar` | 마스코트 · [피드\|궤도] · [궤도 여행] · ← 이전 · 다음 → · [+] · [?] |
| [H] 가져오기·보관함 | `ControlBar`의 왼쪽 알약 | 가져오기, 보관함 폴더 열기, 보관함 바꾸기 |
| [I] 조작 안내 | `OrbitView` 안 | 드래그·휠·탭 안내 (궤도 뷰에서만) |

### 2.4 반응형

| 폭 | 배치 |
|---|---|
| 1200 dp 이상 (데스크톱, 헤드셋 패널 기본 1280×800) | 3단: 범례 240 dp · 피드 600 dp · 내비게이터 360 dp |
| 800~1199 dp (태블릿, 좁은 창) | 2단: 범례는 72 dp 아이콘 줄로 접힘 · 피드. 내비게이터는 오른쪽에서 겹쳐 뜸 |
| 800 dp 미만 (폰) | 1단: 위 막대의 [=]로 범례 서랍 · 피드. 내비게이터는 아래에서 올라오는 시트 |

### 2.5 화면 조각 상세

**PostCard**
- 왼쪽 44 dp 원: 카테고리 색 링(2 dp) 안에 유형 아이콘(사진·영상·메모).
- 머리줄: 카테고리 이름(굵게) · 상대 시간(`inkSub`) · 오른쪽 ☆. 고정 포스트는 핀 표시.
- 본문: 메모 최대 6줄, 넘치면 「더 보기」. `#태그`는 `categoriesText` 색 글씨이고, 누르면 태그 필터.
- 미디어 그리드(`MediaGrid`): 1장 = 원래 비율(최대 높이 510 dp) · 2장 = 좌우 · 3장 = 왼쪽 큰 1 + 오른쪽 위아래 2 · 4장 = 2×2 · 5장 이상 = 4번째 칸에 「+n」. 모서리 16 dp. 영상에는 ▶와 길이 배지.
- 아래줄: 태그 칩 · 메뉴(수정·카테고리 옮기기·삭제·파일 열기).
- 연필 버튼: 데스크톱에서는 마우스를 올리면, 터치에서는 늘 작게 보인다. 누르면 그 자리에서 고친다.
- 선택된 카드: 테두리가 카테고리 색이 되고 그림자가 한 단계 깊어진다(내비게이터와 연동).
- 상대 시간: 방금 · n분 전 · n시간 전 · 어제 · n일 전(7일까지) · 그 뒤로는 ISO 8601 날짜 `2026-08-17`. 정확한 시각은 내비게이터에 `2026-08-17 04:57`로 보인다.
- 읽을 수 없는 파일: 회색 카드 「읽을 수 없는 파일」 + [메모장으로 열기].

**MediaViewer**: 화면 전체를 반투명 흰 막(블러 16)으로 덮고 미디어를 가운데 둔다. 아래에 파일 이름·크기·해상도·길이. `←` `→`(터치는 스와이프), `Esc` 닫기. 영상은 `media_kit` 재생 막대(탐색·음량·전체화면). 재생할 수 없으면 썸네일과 [기본 앱으로 열기].

**NavigatorCard**: 폭 360 dp, 오른쪽 여백 24 dp. 위: 마스코트 원 + 넓은 자간 「NAVIGATOR」 / 카테고리 점+이름 / 제목(굵게 20 sp) / 썸네일(16:9) / 메모 요약 5줄 / 「2026-10-01 · 태그 2 · 연결 3」 / 버튼: [파일 열기] (주 버튼 그라데이션) · [피드에서 보기] 또는 [궤도에서 보기] · [닫기].

**Composer**: 안내 문구 「무슨 기록을 남길까요? #태그도 돼요」. 파일을 끌어 오면 테두리가 주 버튼 색으로 빛나고 「여기에 놓으세요」. 첨부 미리보기 칩(×로 빼기). 카테고리 선택(기본은 마지막에 쓴 카테고리).

**EmptyHint**: 빈 피드에는 「아직 기록이 없어요 — 사진을 끌어다 놓거나 [+]를 눌러 보세요」, 검색 결과가 없으면 「찾는 기록이 없어요」와 [필터 지우기].

### 2.6 움직임

| 상황 | 움직임 | 시간·곡선 |
|---|---|---|
| 피드 카드 등장 | 아래 12dp에서 올라오며 투명도 0→1, 카드마다 40ms씩 늦게 | `base` · `easeOut` |
| 카드에 마우스 올리기 | 4 dp 떠오름 + 마우스 방향으로 최대 3° 기울기(원근 행렬) + 그림자 깊어짐 | `fast` |
| 썸네일 → 뷰어 | 썸네일 자리에서 화면 가운데로 커짐(Hero), 배경 블러 | 360 ms · `easeOut` |
| 궤도 뷰 노드 선택 | 카메라가 날아감, 라벨이 색으로 채워짐, 클러스터 글로우 | `fly` · `easeInOut` |
| 멀어짐 ↔ 가까워짐 | 점 ↔ 라벨 알약 페이드 | `fast` |
| 피드 ↔ 궤도 전환 | 피드가 0.96배로 줄며 흐려지고, 궤도 장면은 먼 곳에서 전체 보기 위치로 다가옴(반대도 같음). 선택된 포스트가 있으면 그 노드·카드로 바로 감 | `slow` |
| 대기 | 30초 동안 조작이 없으면 궤도 장면이 아주 느리게 자동 회전(90초에 한 바퀴). 피드 배경 링도 천천히 회전 | — |
| 피드 배경 | 배경 링·구체가 스크롤의 0.15배 속도로 움직임(패럴랙스) | — |
| 애니메이션 줄이기 켜짐 | 이동·회전·기울기 없음, 페이드만 120 ms | — |

### 2.7 지역화 (대한민국, ISO 3166-1 `KR`)

대상 지역의 코드는 한 곳(`AzRegion`)에만 둔다. 다른 코드는 이 값을 가져다 쓴다.

```dart
// lib/app.dart
abstract final class AzRegion {
  static const countryAlpha2 = 'KR';            // ISO 3166-1 alpha-2
  static const countryAlpha3 = 'KOR';           // ISO 3166-1 alpha-3
  static const countryNumeric = '410';          // ISO 3166-1 numeric
  static const subdivisionStandard = 'ISO 3166-2:KR';
  static const m49Region = '142';               // UN M49: Asia
  static const m49SubRegion = '030';            // UN M49: Eastern Asia
  static const languageTag = 'ko-KR';           // BCP 47 = ISO 639 'ko' + ISO 3166-1 'KR'
  static const locale = Locale('ko', 'KR');
  static const defaultTimeZone = 'Asia/Seoul';  // 문서용 기본값. 표시는 기기 시간대를 따른다
}
```

| 항목 | 설계 | 요구 |
|---|---|---|
| 앱 로캘 | `MaterialApp(locale: AzRegion.locale, supportedLocales: [AzRegion.locale], localizationsDelegates: GlobalMaterialLocalizations.delegates)` — 날짜 선택기·복사/붙여넣기 메뉴 등 기본 위젯도 한국어 | LC-02 |
| 날짜·시각 | 저장: 오프셋 포함 ISO 8601. 표시: 기기 시간대로 바꾼 뒤 `2026-08-17`, `2026-08-17 04:57`. 상대 시간은 한국어 | LC-03, LC-05 |
| 숫자 | `intl`의 `NumberFormat.decimalPattern('ko_KR')` → `2,000` | LC-04 |
| 글꼴 | Pretendard(현대 한글 11,172자 포함). 글꼴에 없는 글자는 OS 기본 한글 글꼴로 대체 | LC-06 |
| 한글 입력 | 작성칸·검색칸은 Flutter 기본 `TextField`를 쓰고, 조합 중(composing) 상태에서는 저장·필터를 하지 않는다. Windows IME·Android 한글 키보드에서 시험 | LC-07 |
| 정렬 | `KoText.compare`: NFC 정규화 → 숫자 → 영문(대소문자 무시) → 한글(완성형 음절은 코드 순서가 곧 가나다순) | LC-08 |
| 검색 | `KoText.normalize`(NFC)를 검색어와 대상에 똑같이 적용한 뒤 포함 여부 비교 | LC-09 |
| 단축키 | `PhysicalKeyboardKey`(물리 키 위치)로 판단 → 한글 자판에서 `N`(ㅜ)을 눌러도 「새 포스트」 | LC-10 |
| 지역 코드 사용 | 국가·하위 구분이 필요하면(예: 나중에 사진 위치 정보) `AzRegion` 값과 ISO 3166-2:KR 코드(`KR-11` 등)만 쓴다 | LC-01 |

---

## 3. 궤도 뷰 (2.5D)

3D 엔진 없이 `CustomPainter`로 그린다. 구체·링·점·선·라벨이 모두 「카메라를 보는 평면 도형」이라서, 3D 좌표를 화면 좌표로 투영하기만 하면 된다.

```
OrbitLayout   (posts, categories -> 3D points, same result every time)
     |
     v
OrbitPainter <------ Camera3D   (yaw, pitch, distance, target -> projection)
     |                  ^
     |                  +---- gestures   (drag, wheel, pinch, tap)
     |                  `---- Tour       (auto fly)
     v
  Canvas  +  LabelLayer   (nearest 120 labels)
```

`OrbitLayout`이 포스트·카테고리를 3D 좌표로 바꾸고(늘 같은 결과), `Camera3D`가 제스처와 `Tour`를 받아 시점을 바꾸며, `OrbitPainter`가 그 시점으로 투영해 그린다. 라벨은 `LabelLayer`가 가까운 120개만 맡는다.

### 3.1 Camera3D
- 상태: `target`(Vector3), `yaw`, `pitch`(-80°~80°), `distance`(150~3000), 시야각 50°.
- `project(Vector3 p) → ProjectedPoint(offset, depth, scale)`: lookAt 행렬 × 원근 행렬(`vector_math`의 `Matrix4`).
- `flyTo(target, distance)`: `AzMotion.fly` 동안 target·distance·yaw를 보간한다.

### 3.2 OrbitLayout (결정적 배치)
- 같은 자료라면 늘 같은 자리에 놓는다 → 공간을 기억할 수 있다.
- 「미분류」는 장면 가운데(0,0,0)의 허브다.
- 다른 카테고리는 반지름 600인 큰 타원 위에 순서대로 같은 간격으로 놓고, 높이는 이름 해시로 ±80 범위 안에서 정한다.
- 구체 반지름: `r = 60 + 18 × √(포스트 수)`.
- 포스트: 만든 순서대로 피보나치 나선 방향에 놓는다. 중심에서의 거리는 `((i+1)/n)^(1/3) × 0.9r`라서 오래된 것은 안쪽, 최신은 바깥쪽에 온다.
- 링크: 태그마다 그 태그를 가진 포스트를 시간순으로 세우고 이웃끼리만 잇는다. 선 개수는 Σ(태그별 포스트 수 − 1).

### 3.3 그리는 층 (뒤에서 앞으로)

| 층 | 그리는 법 |
|---|---|
| 1 배경 | `space` → `spaceEdge` 방사형 그라데이션 |
| 2 큰 궤도 링 3겹 | 타원 위 96점을 투영해 경로로 그림, 카테고리 색 번갈아 25 % |
| 3 카테고리 구체 | 투영 중심·크기로 원: 방사형 채움 + 얇은 테두리 + 왼쪽 위 광택 호. 일부는 기울어진 작은 타원 링 |
| 4 링크 선 | `muted` 25 %. 선택한 노드의 선만 카테고리 색 |
| 5 노드 점 | 카테고리 색, 크기는 원근에 비례, 깊이순 정렬, 색별로 묶어 한 번에 그림 |
| 6 라벨 알약 | 카메라에서 가까운 120개 + 선택 노드. 흰 바탕·색 테두리·색 점·굵은 `ink` 글씨, 사진·영상 포스트는 왼쪽에 원형 썸네일. 선택된 라벨은 `categoriesText` 채움 + 흰 글씨. 글자 그림은 300개까지 캐시 |
| 7 카테고리 이름 | 구체 아래 바깥쪽, 넓은 자간 `categoriesText` 글씨 |
| 8 선택 글로우 | 선택한 카테고리 뒤에 방사형 빛 |

궤도 뷰는 그림이라 화면 낭독기가 읽을 수 없으므로, 같은 내용을 피드 뷰와 내비게이터로 언제든 볼 수 있게 한다(ISO/IEC 40500의 「대체 수단」). 키보드로는 `Tab`으로 노드를 시간순으로 옮겨 가며 고를 수 있다.

### 3.4 조작
- 드래그·스와이프 = 회전(관성 있음), 휠·핀치 = 앞뒤 이동, 탭 = 가장 가까운 노드(14 dp 안) 또는 라벨 선택 → 날아가기 + 내비게이터, 더블탭 = 전체 보기, 길게 누르기 = 날아가지 않고 내비게이터만.
- 범례에서 숨긴 카테고리는 8%로 흐리게 남긴다(자리는 그대로).
- 궤도 여행(`Tour`): 지금 필터에 보이는 포스트를 시간순으로 4초마다 날아가며 보여준다. 이전·다음으로 넘기고, 직접 조작하면 멈춘다.
- 성능: 2초 넘게 한 프레임이 33ms를 넘으면 라벨 60개, 링 48점으로 줄인다.

---

## 4. 보관함 형식 — 앱의 핵심 약속

이 형식만 지키면 다른 앱(Obsidian, 메모장, 나중의 XR 앱)도 같은 보관함을 읽고 쓸 수 있다.

```
<아무 드라이브·위치>/                        예: C:\Users\me\Documents\  D:\  E:\(외장)  SD 카드/
 `-- A-Z 보관함/                            <- 이 폴더째 복사·이동 = 옮기기·백업
      +-- A-Z 시작하기.md                   <- 튜토리얼 포스트 (pinned, 예시 포함일 때)
      +-- 디자인/                           <- 폴더 = 카테고리 = 궤도 뷰의 구체 하나
      |    +-- 2026-10-01 0930 궤도 링 색감 연구.md   <- 포스트 = 마크다운 파일 하나
      |    `-- 첨부/
      |         +-- ring-01.jpg ... ring-04.jpg
      +-- 미분류/                           <- 카테고리 없이 쓴 기록
      `-- .az/                              <- 앱 전용 (캐시는 지워도 다시 만들어짐)
           +-- vault.json ....... 보관함 표시 (형식 이름, 버전, 만든 날짜)
           +-- settings.json .... 카테고리 색·순서, 튜토리얼 진행
           +-- index.json ....... 빠른 시작용 색인 + 첨부 내용 해시 (캐시)
           +-- thumbs/ .......... 썸네일 (캐시)
           +-- import_state.json  가져오기 이어하기 정보
           `-- trash/ ........... 지운 포스트·첨부 (복원 가능)

(보관함 밖, 기기별 앱 설정 폴더)
 +-- recent_vaults.json ......... 이 기기에서 연 보관함 목록 (VaultCatalog)
 `-- logs/a_z.log ............... 로그 (보관함에는 남기지 않음)
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
궤도 링 색감 연구
레퍼런스에서 뽑은 색으로 링 네 개를 그려 봤다 #색감 #레퍼런스

![[디자인/첨부/ring-01.jpg]]
![[디자인/첨부/ring-02.jpg]]
![[디자인/첨부/ring-03.jpg]]
![[디자인/첨부/ring-04.jpg]]
```

| 머리말 필드 | 없으면 | 뜻 |
|---|---|---|
| `id` | 경로로 임시 id를 만들고, 앱에서 고칠 때 머리말에 써 넣음 | `p_` + 16진수 12자리. 파일 이름이 바뀌어도 같은 포스트로 알아봄 |
| `created` | 파일 수정 시각 | 처음 쓴 시각. 피드 정렬 기준 |
| `updated` | `created` | 마지막으로 고친 시각 |
| `starred` | `false` | 즐겨찾기 |
| `pinned` | `false` | 피드 맨 위 고정 |
| 그 밖의 필드 | — | 모르는 필드도 지우지 않고 그대로 보존(Obsidian 속성 등) |

파일 규칙 (AZ-SRS DR-01~06):
- 인코딩 UTF-8(ISO/IEC 10646, BOM 없음), 줄바꿈 LF, 머리말은 YAML 1.2, 본문은 GFM.
- 보관함 안의 모든 경로는 보관함 기준 상대 경로이고 구분자는 **어느 OS에서든 `/`**다(Windows에서도 `디자인/첨부/ring-01.jpg`). 디스크에 접근할 때만 OS 구분자로 바꾼다.
- 파일·폴더 이름은 유니코드 NFC로 정규화한다(기기마다 한글 자모가 나뉘어 저장되는 문제 방지).
- 시각은 ISO 8601 확장 형식 + 시간대(`2026-10-01T09:30:00+09:00`).

본문 규칙:
- 첫 줄이 제목이다(`# 제목`이면 `#`를 떼고 읽음).
- `#단어`는 태그다. 코드 블록 안이나 `# `(뒤에 공백) 같은 마크다운 제목 표시는 제외한다.
- `![[보관함 기준 경로]]`가 첨부다. 이름만 있으면(`![[ring-01.jpg]]`) Obsidian처럼 보관함 전체에서 같은 이름을 찾는다. 표준 마크다운 이미지 `![](경로)`도 읽는다.
- 체크리스트 `- [ ]`/`- [x]`는 그대로 보여주고 누르면 바뀐다.

파일 이름 규칙: `YYYY-MM-DD HHmm 제목.md`(제목은 40자까지, `\ / : * ? " < > |`는 뺌). 같은 이름이 있으면 ` (2)`를 붙인다. 이름은 보기 좋으라고 붙이는 것이라 사용자가 바꿔도 된다.

첨부 규칙: `<카테고리>/첨부/원래이름.확장자`. 이름이 같고 내용이 다르면 `원래이름 (2).확장자`. 내용이 같은 파일은 다시 복사하지 않고 이미 있는 첨부를 가리킨다.

카테고리 바꾸기: `.md`와 그 포스트만 쓰는 첨부를 새 폴더로 옮기고 링크를 고친다. 다른 포스트도 쓰는 첨부는 그 자리에 둔다.

휴지통: `.az/trash/<시각>/` 아래에 원래 상대 경로 그대로 옮기고, 되돌릴 정보를 `restore.json`에 적는다.

### 4.2 `.az/` 파일 예시

`vault.json` — 「이 폴더는 A-Z 보관함」 표시
```json
{
  "format": "a-z-vault",
  "version": 1,
  "created": "2026-10-21T13:20:00+09:00"
}
```

`settings.json` — 색은 HEX가 아니라 팔레트 번호로 적는다(색 값은 `theme.dart`에만)
```json
{
  "version": 1,
  "categories": {
    "디자인": { "color": 0, "order": 1 },
    "실험": { "color": 1, "order": 2 },
    "과학 노트": { "color": 2, "order": 3 }
  },
  "tutorial": { "done": ["welcome", "editCard"], "dismissed": false }
}
```

`index.json` — 캐시. 파일마다 `상대 경로·크기·수정 시각·읽어 둔 요약`, 첨부마다 `크기·수정 시각·내용 해시`를 담는다. 버전이 다르거나 읽을 수 없으면 버리고 다시 만든다.

### 4.3 Obsidian과 함께 쓰기
- `.az/`는 점으로 시작하는 폴더라 Obsidian이 무시한다. A-Z도 `.obsidian/`을 무시한다.
- Obsidian에서 만든 노트(머리말 없음)도 포스트로 읽힌다. 「⓪-2 열기」로 Obsidian 보관함을 그대로 열 수 있다.

---

## 5. 저장 위치 설계

보관함은 **사용자가 고른 아무 드라이브·위치**에 만든다. 코드에는 드라이브 문자나 경로를 쓰지 않는다. 위치는 `StorageLocator`가 알려준다.

```
StorageLocator (interface)
 +-- WindowsStorageLocator ..... win32: GetLogicalDrives, GetDriveTypeW,
 |                               GetDiskFreeSpaceExW, GetVolumeInformationW
 |                               -> C:(로컬) D:(로컬) E:(이동식) Z:(네트워크) ...
 `-- AndroidStorageLocator ..... path_provider 외부 저장소 목록 + StatFs 채널
                                 -> 내부 저장소 / SD 카드 / USB
```

| 클래스 | 하는 일 |
|---|---|
| `StorageVolume` | 볼륨 하나: 표시 이름, 루트 경로, 종류(로컬·이동식·네트워크·내부·SD·USB), 남은 공간 |
| `StorageLocator` | `listVolumes()`, `freeBytes(path)`, `ensurePermission()`, `appConfigDir` (기기별 설정 폴더) |
| `LocationCheck` | 새 보관함을 만들어도 되는 자리인지 점검 (아래 표) |
| `VaultCatalog` | 이 기기에서 연 보관함 목록(`recent_vaults.json`, 최대 20개). 열 때마다 경로가 살아 있는지 확인 |

`LocationCheck` 규칙:

| 점검 | 실패하면 |
|---|---|
| 쓰기 권한: 임시 파일을 써 보고 지움 | 막음 「여기에는 쓸 수 없어요」 |
| 남은 공간 500 MB 이상 | 막음 |
| 시스템 폴더: Windows 폴더·Program Files·ProgramData(환경 변수로 위치 확인), 드라이브의 `$Recycle.Bin`·`System Volume Information`, Android의 `Android/data`·`Android/obb` | 막음 |
| 다른 보관함 안이거나, 고른 폴더 아래에 이미 보관함이 있음 (위·아래로 `.az/vault.json` 확인) | 막음 |
| 같은 이름 폴더가 이미 있음 | 「A-Z 보관함 (2)」 제안 |
| 네트워크 드라이브 | 경고 「느릴 수 있어요」 후 계속 가능 |
| 경로가 길어짐 (Windows 긴 경로 지원이 꺼져 있을 때) | 경고 + 짧은 이름 제안 |

---

## 6. 객체 구조

### 6.1 구조도

```
+---------------------------------------------------------------+
| main.dart     builds every object once (composition root)     |
+---------------------------------------------------------------+
                                |
                                v
+---------------------------------------------------------------+
| SCREEN   app.dart     HomeShell, AppState(view/filter/select)  |  <- 보여주기만
|          ui/start     VaultStartScreen                        |
|          ui/feed      FeedView, PostCard, MediaGrid           |
|          ui/orbit     OrbitView, Camera3D, OrbitPainter       |
|          ui/comps     NavigatorCard, Legend, Composer ...     |
+---------------------------------------------------------------+
                                |  calls only, never touches disk
                                v
+---------------------------------------------------------------+
| LOGIC    archive.dart   Archive, Post, PostQuery, TagParser   |  <- 위젯 import 금지
|          importer.dart  ImportJob, FolderScanner, Hasher      |
|          media.dart     ProbeRegistry, ThumbnailCache         |
|          tutorial.dart  TutorialController, SampleVaultSeeder |
+---------------------------------------------------------------+
                                |  read / write
                                v
+---------------------------------------------------------------+
| STORAGE  vault.dart     Vault, PostCodec, AtomicWriter,       |  <- 디스크는 여기만
|                         VaultIndex, VaultSettings, Watcher    |
|          storage.dart   StorageLocator, LocationCheck,        |
|                         VaultCatalog (recent vaults)          |
+---------------------------------------------------------------+
                                |
                                v
        [ 아무 드라이브 / 아무 위치 ]/A-Z 보관함/  *.md + 첨부 + .az/
```

### 6.2 파일별 클래스 책임표

| 파일 | 클래스 | 책임 | 생성자로 받는 것 | 테스트 |
|---|---|---|---|---|
| main.dart | `main()` | 플랫폼을 확인하고 모든 객체를 한 번씩 만들어 연결 | — | e2e |
| app.dart | `AzApp` | 테마 적용, 시작 화면 ↔ HomeShell 전환 | `AppState` | 위젯 |
| | `AppScope` | 조립된 객체를 화면 트리에 제공(InheritedWidget) | 객체 묶음 | — |
| | `AppState` | 열린 보관함, 보기(피드·궤도), 필터(`PostQuery`), 선택한 포스트, 튜토리얼 오버레이. 화면 명령을 `Archive`에 전달 | `Archive`, `VaultCatalog`, `TutorialController` | 단위 |
| | `HomeShell` | 공통 틀 [A]~[I] 배치, 반응형 1·2·3단, 뷰 전환 | `AppState` | 위젯 |
| | `AzRegion` | 대상 지역 코드(ISO 3166-1 `KR`)와 로캘 `ko-KR` 상수 (2.7) | — | — |
| archive.dart | `Post` · `MediaRef` · `Category` | 값 객체(`copyWith`). `MediaRef`는 보관함 기준 상대 경로 | — | 단위 |
| | `MediaKind` | `photo` · `video` | — | — |
| | `PostQuery` | 필터 값 객체: 숨긴 카테고리, 유형, 태그, 검색어, 즐겨찾기만 | — | 단위 |
| | `TagParser` | 본문에서 `#태그` 추출(코드 블록·제목 제외) | — | 단위 |
| | `Archive` | 메모리 속 포스트 목록, 검색·통계·궤도 그래프 자료, 작성·수정·삭제를 `Vault`에 맡김, 변경 알림 | `Vault`, `ProbeRegistry`, `Clock` | 단위 |
| | `Clock` | 지금 시각을 알려줌 (테스트에서 시각을 고정하려고 따로 둠) | — | — |
| | `KoText` | 한국어 문자열 도구: NFC 정규화, ko-KR 정렬 비교 (2.7) | — | 단위 |
| | `AzException` 계층 | 10.1 참고 | — | 단위 |
| vault.dart | `Vault` | 보관함 하나: 만들기·열기·포스트 목록·읽기·쓰기·옮기기·첨부 복사·휴지통·복원 | `FileSystem`, `AtomicWriter`, `PostCodec`, `VaultIndex` | 단위(MemoryFileSystem) |
| | `PostCodec` | `.md` 문자열 ↔ `Post` (모르는 머리말 보존) | — | 단위(왕복) |
| | `AtomicWriter` | 임시 파일 쓰기 → rename, 파일 복사·이동 | `FileSystem` | 단위 |
| | `VaultIndex` | `index.json` 읽기·검증·다시 만들기 | `FileSystem`, `AtomicWriter` | 단위 |
| | `VaultSettings` | `settings.json` (카테고리 색·순서, 튜토리얼 진행) | `FileSystem`, `AtomicWriter` | 단위 |
| | `VaultWatcher` | 바깥 변경을 `Stream<VaultChange>`로 알림 | `FileSystem`, 플랫폼 정보 | 단위 |
| | `Trash` | 휴지통으로 옮기기·복원·비우기 | `FileSystem`, `AtomicWriter` | 단위 |
| storage.dart | `StorageLocator` (interface) | 볼륨 목록·남은 공간·권한·설정 폴더 | — | — |
| | `WindowsStorageLocator` · `AndroidStorageLocator` | 플랫폼별 구현 (본보기: Windows) | — | 기기에서 수동 + e2e |
| | `StorageVolume` | 볼륨 값 객체 | — | — |
| | `LocationCheck` | 새 보관함 자리 점검 (5절 표) | `StorageLocator`, `FileSystem` | 단위(가짜 Locator) |
| | `VaultCatalog` | 최근 보관함 목록 | `StorageLocator`, `FileSystem`, `AtomicWriter` | 단위 |
| media.dart | `MediaProbe` (abstract) | 확장자·종류·`probe()`·`thumbnail()` 약속 | — | — |
| | `PhotoProbe` | 크기·EXIF 촬영일·썸네일 (확장 본보기) | — | 단위(생성 이미지) |
| | `VideoProbe` | 크기·길이·대표 프레임 썸네일 | — | 기기 확인 |
| | `ProbeRegistry` | 확장자 → 알맞은 Probe | — | 단위 |
| | `MediaInfo` | 너비·높이·길이·촬영일 | — | — |
| | `ThumbnailCache` | `.az/thumbs/` 썸네일 만들기·찾기·무효화(크기+수정 시각) | `ProbeRegistry`, `FileSystem`, `AtomicWriter` | 단위 |
| importer.dart | `FolderScanner` | 하위 폴더까지 지원 파일 찾기(숨김·시스템 파일 제외) | `FileSystem`, `ProbeRegistry` | 단위 |
| | `ContentHasher` | 크기 + 앞뒤 1 MiB SHA-1 | `FileSystem` | 단위 |
| | `ImportJob` | 계획(개수·용량·공간) → 실행(복사·포스트 생성·진행률) → 취소·이어하기 | `Archive`, `FolderScanner`, `ContentHasher`, `ProbeRegistry`, `StorageLocator` | 단위(원본 불변 확인) |
| tutorial.dart | `TutorialStep` | 단계 하나: id, 가리킬 곳, 문구, 완료 조건 | — | — |
| | `TutorialController` | 현재 단계, 완료 처리, 「A-Z 시작하기.md」 체크리스트 반영 | `Archive`, `VaultSettings` | 단위 |
| | `SampleVaultSeeder` | `assets/sample_vault`를 새 보관함에 복사, 날짜를 오늘 기준으로 맞춤 | `AssetBundle`, `Vault` | 단위 |
| theme.dart | `AzColors` · `AzShapes` · `AzMotion` · `AzTheme` | 디자인 토큰과 `ThemeData` | — | — |
| ui/start.dart | `VaultStartScreen` | 새로 만들기·열기·최근 보관함 | `AppState`, `StorageLocator`, `LocationCheck` | 위젯 |
| ui/components.dart | `Legend` · `SearchBox` · `StatusPill` · `NavigatorCard` · `ControlBar` · `Composer` · `MediaViewer` · `Toast` · `EmptyHint` | 두 뷰가 함께 쓰는 화면 조각 | `AppState` | 위젯 |
| ui/feed.dart | `FeedView` · `PostCard` · `MediaGrid` | 피드 뷰 | `AppState` | 위젯 |
| ui/orbit.dart | `OrbitView` · `OrbitLayout` · `Camera3D` · `OrbitPainter` · `LabelLayer` · `Tour` | 궤도 뷰 (3절) | `AppState` | 단위(Layout·Camera) + 위젯 |
| ui/coach_marks.dart | `CoachMarkOverlay` | 튜토리얼 말풍선과 강조 | `TutorialController` | 위젯 |

### 6.3 주요 공개 메서드

```dart
// archive.dart
class Archive extends ChangeNotifier {
  Archive(Vault vault, ProbeRegistry probes, Clock clock);
  List<Post> query(PostQuery q, {int offset = 0, int limit = 30});
  ArchiveStats stats();                       // 범례 개수, 상태 알약
  OrbitGraph graph(PostQuery q);              // 궤도 뷰 노드·링크
  Future<Post> create(String text, {required String category, List<File> files = const []});
  Future<Post> update(Post post);
  Future<void> moveToCategory(String postId, String category);
  Future<void> delete(String postId);         // 휴지통으로
  Future<void> reload([Set<String>? changedPaths]);   // 바깥 변경 반영
}

// vault.dart
class Vault {
  static Future<Vault> create(Directory parent, String name, {required FileSystem fs, required AtomicWriter writer});
  static Future<Vault> open(Directory root, {required FileSystem fs, required AtomicWriter writer});
  Directory get root;
  Stream<PostFile> listPosts();
  Future<Post> readPost(String relativePath);
  Future<void> writePost(Post post, {DateTime? expectedModified});   // 다르면 VaultConflict
  Future<String> copyAttachment(File source, String category);       // 보관함 기준 상대 경로
  Future<void> trash(Post post);
  Future<void> restore(String trashId);
}

// storage.dart
abstract interface class StorageLocator {
  Future<List<StorageVolume>> listVolumes();
  Future<int?> freeBytes(String path);
  Future<bool> ensurePermission();
  Directory get appConfigDir;                 // 기기별 설정 폴더 (보관함 밖)
}

class LocationCheck {
  LocationCheck(StorageLocator locator, FileSystem fs);
  Future<CheckResult> check(Directory parent, String name);   // ok · warnings · errors
}

// media.dart
abstract class MediaProbe {
  Set<String> get extensions;                 // {'.jpg', '.png', ...}
  MediaKind get kind;
  Future<MediaInfo> probe(File file);
  Future<Uint8List?> thumbnail(File file, {int maxSide = 480});
}

class ProbeRegistry {
  void register(MediaProbe probe);
  MediaProbe? forPath(String path);
}

// importer.dart
class ImportJob {
  ImportJob(Archive archive, FolderScanner scanner, ContentHasher hasher, ProbeRegistry probes, StorageLocator locator);
  Future<ImportPlan> plan(Directory source);                  // 개수·총 용량·남은 공간
  Stream<ImportProgress> run(ImportPlan plan, {required String category});
  void cancel();
}
```

### 6.4 확장 지점

```
확장 지점                        본보기                      새로 추가할 때
MediaProbe (abstract)     ---->  PhotoProbe           --->  HeicProbe 클래스 + ProbeRegistry.register() 1줄
StorageLocator (interface) --->  WindowsStorageLocator --->  새 플랫폼 클래스 1개 + main.dart에서 선택
TutorialStep (data)       ---->  editCard             --->  단계 객체 1개 추가
ui 위젯                   ---->  StatusPill           --->  위젯 클래스 1개 + HomeShell에 배치
```

본보기 클래스에는 「새로 만들 때 바꿀 곳」을 주석으로 달아 둔다. 문서를 읽지 않아도 본보기를 복사해서 고치면 되게.

### 6.5 상태와 두 뷰

```
             +-------------------- AppState (ChangeNotifier) --------------------+
             |  vault, viewMode(feed/orbit), query(PostQuery), selectedPostId    |
             +-------------------------------------------------------------------+
                  ^            ^             ^              ^             ^
                  | listen     | listen      | listen       | listen      | listen
              FeedView     OrbitView    NavigatorCard     Legend      SearchBox / ControlBar
                  |            |             |
                  +-- select(id) / setQuery(q) / setView(v) --> AppState --> Archive
```

두 뷰는 서로를 모른다. 같은 `AppState`를 보고, 선택을 바꾸면 다른 뷰와 내비게이터가 따라온다.

---

## 7. 흐름도

**⓪ 새 보관함 만들기 (첫 실행, 또는 [H] → 보관함 바꾸기 → 새로 만들기)**
```
VaultStartScreen:  [새로 만들기]  [열기]  [최근 보관함 목록]
  |
  v
StorageLocator.listVolumes()
  +-- Windows ... C:  D:  E:(외장)  Z:(네트워크) ...  종류·남은 공간 표시
  `-- Android ... 내부 저장소 / SD 카드 / USB
  |
  v
위치 고르기 ............ 드라이브 바로 아래, 또는 [찾아보기]로 아무 폴더
  |
  v
이름 정하기 ............ 기본 「A-Z 보관함」, 같은 이름이 있으면 「A-Z 보관함 (2)」
  |
  v
LocationCheck .......... 쓰기 권한 / 남은 공간 / 시스템 폴더 금지
                         다른 보관함 안 중첩 금지 / 네트워크 드라이브는 경고만
  |
  v
Vault.create() ......... 새 폴더 + 미분류/ + .az/vault.json
  +-- [예시 포함] --> SampleVaultSeeder --> 튜토리얼 시작 (8절)
  `-- [빈 보관함]
  |
  v
VaultCatalog.remember()  이 기기의 「최근 보관함」에 추가 (보관함 밖에 저장)
```

**⓪-2 기존 보관함 열기 (다른 드라이브·기기에서 복사해 온 폴더 포함)**
```
[열기] -> 폴더 고르기
  |
  v
has .az/vault.json ? -- yes --> 열기 (index.json이 없거나 낡았으면 다시 만들고, 썸네일은 뒤에서 차례로)
  |
  | no
  v
has *.md ? ----------- yes --> 「보관함으로 만들까요?」 (Obsidian 폴더도 이렇게 열림)
  |
  | no
  v
「보관함이 아니에요」

최근 목록의 경로가 사라졌으면 (드라이브 분리·폴더 이동) -> [다시 찾기] [목록에서 빼기]
```

**① 포스트 작성**
```
사용자: 작성칸에 글 쓰고 사진을 끌어다 놓기
  |
  v
Composer --submit--> AppState.createPost(text, files, category)
  |
  v
Archive.create()
  +-- TagParser.extract(text) ............ #태그 뽑기
  +-- Vault.copyAttachment() ............. 사본을 <카테고리>/첨부/로, 바깥 원본은 읽기만
  +-- Vault.writePost(post)
  |     `-- PostCodec.encode -> AtomicWriter (tmp 파일 -> rename)
  `-- notifyListeners()
  |
  v
FeedView: 새 카드가 떠오르며 등장   +   OrbitView: 새 노드
```

**② 바깥 폴더 가져오기**
```
[가져오기] -> 폴더 선택 (아무 드라이브)
  |
  v
FolderScanner ...... 하위 폴더까지, 지원 형식만
  |
  v
ImportJob.plan ..... 개수 / 총 용량 / 보관함 드라이브의 남은 공간  -> [시작]
  |
  v
ImportJob.run (isolate), for each file:
  +-- ContentHasher ..... 이미 있으면 건너뜀
  +-- copyAttachment .... 사본
  +-- Photo/VideoProbe .. 촬영일·크기·길이
  +-- Vault.writePost + ThumbnailCache
  `-- progress .......... 진행 막대 갱신, 실패한 파일은 목록에 남기고 다음 파일로
  |
  v
완료 요약: 새로 n / 건너뜀 n / 실패 n   (취소하면 import_state.json으로 다음에 이어서)
```

**③ 다른 드라이브·기기로 옮기기**
```
[PC]  D:\A-Z 보관함\            (아무 드라이브·위치)
      |
      |  폴더째 복사·이동 (탐색기, USB, 외장 디스크, adb push, Syncthing ... 아무 방법)
      v
[다른 드라이브 / Android 폰 / XR 헤드셋]  .../A-Z 보관함/
      |
      v
A-Z 앱 -> [열기] -> ⓪-2 흐름
      `-- 포스트·카테고리·즐겨찾기 그대로 (절대 경로가 없으니 링크가 안 깨짐)
```

**④ 바깥 편집 반영**
```
메모장·Obsidian에서 .md 저장, 또는 탐색기에서 파일 이동
  |
  v
VaultWatcher ...... 데스크톱: 폴더 감시 / Android: 앱으로 돌아올 때 다시 훑기
  |
  v
바뀐 파일만 PostCodec.decode -> Archive.reload(changed)
  +-- 앱에서 같은 포스트를 고치는 중? -> 「다시 불러오기 / 덮어쓰기」
  `-- notifyListeners() -> 카드·노드가 바뀜
```

---

## 8. 튜토리얼과 예시 보관함

목표: **설명서를 읽지 않아도 고치는 법이 자연스럽게 느껴지게.** 「기록 = 파일」이라는 사실을 처음부터 보여주고, 직접 고쳐 보게 한다.

```
첫 실행
  |
  v
새 보관함 만들기 (7-⓪) ........ 드라이브·위치 고르기, [x] 예시 포함
  |
  v
SampleVaultSeeder ............. 예시 보관함 내용 복사 (날짜는 오늘 기준으로)
  |
  v
코치마크 7단계 ................ 언제든 [건너뛰기], [?] 버튼으로 다시 보기
  |
  v
「A-Z 시작하기.md」의 체크리스트가 채워짐 -> 파일이 실제로 바뀌는 걸 눈으로 봄
```

### 8.1 코치마크 단계

| # | id | 가리키는 곳 | 말풍선 | 다음으로 넘어가는 조건 |
|---|---|---|---|---|
| 1 | `welcome` | 화면 가운데 | 「A-Z의 모든 기록은 방금 만든 폴더 속 평범한 파일이에요.」 [보관함 폴더 열기] | [다음] |
| 2 | `editCard` | 첫 예시 카드의 연필 | 「카드 하나 = 파일 하나. 연필을 눌러 문장 하나를 고쳐 보세요.」 | 포스트 수정 저장 |
| 3 | `compose` | 작성칸 | 「여기에 쓰고 사진을 끌어다 놓아 보세요. #태그는 자동으로 붙어요.」 | 새 포스트 게시 |
| 4 | `legend` | 범례 | 「폴더가 곧 카테고리예요. 눌러서 숨기고 켜 보세요.」 | 범례 한 번 누르기 |
| 5 | `orbit` | 컨트롤 막대의 궤도 버튼 | 「같은 기록을 3D 공간에서 볼 수 있어요. 노드 하나를 눌러 보세요.」 | 궤도 뷰에서 선택 |
| 6 | `navigator` | 내비게이터 | 「선택한 기록의 자세한 정보예요. 파일 열기나 피드에서 보기를 눌러 보세요.」 | [다음] |
| 7 | `backup` | [H] | 「옮기거나 백업하려면 이 폴더를 통째로 복사하면 끝이에요. 어느 드라이브로든요.」 | [끝] |

### 8.2 예시 보관함 (`assets/sample_vault/`)

시작하기 포스트 1개 + 예시 포스트 6개, 사진 5장, 영상 1개. 모두 `tools/make_sample_media.py`(Pillow·OpenCV)로 팔레트 색에 맞춰 직접 만든 자료이고 합계 5 MB 이하다.

```
sample_vault/
 +-- A-Z 시작하기.md ............... 튜토리얼 + 체크리스트 (pinned)
 +-- 디자인/
 |    +-- 궤도 링 색감 연구.md ...... 사진 4장 -> 2x2 그리드 체험
 |    `-- 배경 그라데이션.md ........ 사진 1장
 +-- 실험/
 |    `-- 회전하는 링 영상.md ....... 6초 영상 -> 뷰어·재생 체험
 +-- 과학 노트/
 |    +-- 행성 궤도 메모.md ......... 메모만, 「메모장으로 열어 고쳐 보세요」
 |    `-- 포스트 파일 해부도.md ..... 머리말 필드마다 설명 (고치는 법 본보기)
 `-- 미분류/
      `-- 끊긴 링크 연습.md ......... 일부러 없는 첨부 -> 복구 연습
```

`A-Z 시작하기.md`:
```markdown
---
id: p_000000000001
created: 2026-10-21T09:00:00+09:00
starred: true
pinned: true
---
A-Z 시작하기
이 카드도 그냥 파일이에요. 보관함 폴더의 「A-Z 시작하기.md」를 메모장으로 열어 보세요. #시작하기

- [ ] 카드 하나 고쳐 보기
- [ ] 사진을 끌어다 놓아 새 포스트 쓰기
- [ ] 궤도 뷰에서 노드 하나 눌러 보기
- [ ] 보관함 폴더 열어 보기
```

`포스트 파일 해부도.md`의 본문은 머리말 필드(`id`·`created`·`updated`·`starred`·`pinned`)와 본문 규칙(첫 줄 제목, `#태그`, `![[첨부]]`)을 한 줄씩 설명한다. 설명은 YAML 주석이 아니라 본문에 적는다(앱이 다시 저장할 때 주석이 사라질 수 있어서).

### 8.3 그 밖의 학습 장치
- [보관함 폴더 열기]가 시작 화면·튜토리얼·[H]에 늘 있다.
- 빈 화면·입력칸·검색 결과 없음에 안내 문구를 둔다(2.5 `EmptyHint`).
- 파일을 끌어 오면 놓을 자리가 빛난다.
- 카드의 연필 버튼은 그 자리에서 고치게 하고, 저장하면 「파일에 저장됨」 토스트를 잠깐 띄운다.
- [?] 버튼: 튜토리얼 다시 보기, 예시 보관함 새로 만들기.

---

## 9. 플랫폼 차이

| 항목 | Windows | Android 폰·태블릿 | XR 헤드셋 (Quest·Android XR) |
|---|---|---|---|
| 보관함 위치 | 아무 드라이브·폴더 (로컬·이동식·네트워크) | 내부 저장소·SD 카드·USB 아래 아무 폴더 | 내부 저장소 아래 아무 폴더 |
| 볼륨 목록 | `win32` 드라이브 API | 외부 저장소 목록 + StatFs 채널(`MainActivity.kt`) | 같음 |
| 권한 | 필요 없음 | 「모든 파일 접근」 (설정 화면으로 안내) | 설정 화면이 없으면 `adb shell appops set app.az.archive MANAGE_EXTERNAL_STORAGE allow` |
| 바깥 변경 감지 | `Directory.watch` (+ 창이 다시 활성화될 때 훑기) | 앱으로 돌아올 때 다시 훑기 | 같음 |
| 파일·폴더 열기 | 탐색기·기본 앱(`url_launcher`) | 기본 앱(`open_filex`). 폴더는 경로 복사 안내 | 같음 |
| 첨부 넣기 | 끌어다 놓기 + 파일 선택 | 파일 선택 | 파일 선택 |
| 입력 | 마우스·키보드·휠 | 터치·핀치 | 컨트롤러 포인터·손 핀치 |
| 기본 배치 | 3단 | 1단(폰)·2단(태블릿) | 3단 (패널 1280×800) |

---

## 10. 가용성과 오류

### 10.1 예외 계층

```
AzException
 +-- NotFound ............. 포스트·첨부·보관함이 없음
 +-- InvalidLocation ...... 만들 수 없는 위치 (LocationCheck)
 +-- StorageUnavailable ... 드라이브 분리·권한 없음·공간 부족
 +-- VaultConflict ........ 바깥에서 동시에 바뀜
 +-- CorruptedFile ........ 읽을 수 없는 .md·캐시
 `-- MediaUnsupported ..... 분석·재생할 수 없는 형식
```

화면은 예외의 종류를 보고 Toast·띠·대화상자로 알린다. 예외 하나 때문에 앱이 멈추지 않는다.

### 10.2 장애 상황표

| 상황 | 감지 | 처리 | 사용자에게 보이는 것 |
|---|---|---|---|
| `index.json` 없음·깨짐 | 읽기 실패, 버전 불일치 | 버리고 `.md`를 다시 훑어 새로 만듦 | 「정리하는 중…」 진행 표시 |
| `.md` 하나가 깨짐 (YAML 오류) | `PostCodec` 실패 | 그 파일만 따로 표시, 나머지는 정상 | 「읽을 수 없는 파일」 카드 + [메모장으로 열기] |
| 첨부 없음 | 파일 없음 | 자리표시, 다시 연결 가능 | 「파일을 찾을 수 없음」 |
| 저장 중 강제 종료 | 다음 실행 때 `.tmp` 발견 | 원래 파일 유지, `.tmp` 삭제 | 없음 |
| 보관함 드라이브 분리 | 읽기·쓰기 예외 | 쓰기 멈춤, 읽기 전용, 다시 연결되면 재개 | 위에 「보관함에 연결할 수 없어요」 띠 |
| 썸네일 실패 | Probe 예외 | 유형 아이콘 자리표시 | 아이콘 |
| 재생 실패 | `media_kit` 오류 | [기본 앱으로 열기] | 안내 |
| 가져오기 중 종료·취소 | `import_state.json` | 다음 가져오기에서 이어서 (해시로 건너뜀) | 「이어서 가져올까요?」 |
| 바깥과 동시 수정 | 저장 직전 수정 시각 비교 | `VaultConflict` | [다시 불러오기] [덮어쓰기] |
| 공간 부족 | 쓰기 전 `freeBytes` | 막음 | 「공간이 모자라요 (필요 n, 남은 m)」 |

로그: 기기별 앱 설정 폴더의 `logs/a_z.log` (1 MiB × 3개 순환). 보관함 안에는 로그를 남기지 않는다(옮길 때 기기 정보가 섞이지 않게).

---

## 11. 시험 계획 (ISO/IEC/IEEE 29119-3)

### 11.1 범위와 시험 대상
- 시험 대상: `lib/`의 모든 클래스(6.2 표), 보관함 형식(4절), Windows 앱, Android APK.
- 시험 기준 문서: [AZ-SRS](requirements.md)의 F·NF·IF·DR 요구와 수용 기준 AC-1~16.
- 시험하지 않는 것: 외부 패키지 자체의 내부 동작, OS 파일 관리자의 동작.

### 11.2 시험 수준과 방법

```
            /\
           /  \          system / acceptance: integration_test on Windows + Android  (TC-01 ~ TC-16)
          / e2e\
         /------\
        / widget \       widget tests with a fake AppState
       /----------\
      /    unit    \     unit tests with MemoryFileSystem, fake StorageLocator
     /--------------\
```

| 수준 | 도구 | 대상 | 시험 자료 |
|---|---|---|---|
| 단위 | `flutter test` | `Post`·`TagParser`·`PostQuery`, `Archive`, `PostCodec`(왕복), `Vault`·`AtomicWriter`·`Trash`, `LocationCheck`(가짜 Locator), `ImportJob`, `SampleVaultSeeder`, `TutorialController`, `OrbitLayout`·`Camera3D` | 시험 안에서 즉석 생성 |
| 위젯 | `flutter test` | `VaultStartScreen`, `PostCard`, `MediaGrid`(1~5개), `NavigatorCard`, `Legend`, `CoachMarkOverlay`, 색 대비 | 가짜 `AppState` |
| 시스템·인수 | `integration_test` | 아래 TC-01~16 | 시스템 임시 폴더의 보관함 |

설계 기법: 동등 분할(첨부 0·1·2·3·4·5개 이상, 볼륨 종류별), 경계값(남은 공간 500 MB 전후, 라벨 120개 전후), 상태 전이(가져오기 대기 → 진행 → 취소 → 이어하기), 오류 추정(10.2 장애 상황표).

### 11.3 시험 사례 (TC)

| ID | 시험 사례 | 절차 요약 | 기대 결과 | 수준 | 요구·AC |
|---|---|---|---|---|---|
| TC-01 | 첫 실행·튜토리얼 | 시작 화면 → 임시 위치에 예시 포함 보관함 → 코치마크 7단계 → 카드 고치기 | `.md` 내용이 바뀌고 체크리스트가 채워짐 | 시스템 | F-06 F-10 F-17, AC-1 |
| TC-02 | 볼륨별 보관함 | 서로 다른 두 위치에 보관함 → 오가며 포스트 작성 | 두 보관함의 내용이 섞이지 않음 | 시스템 | F-06, AC-2 |
| TC-03 | 금지 위치·공간 | 시스템 폴더, 다른 보관함 안, 남은 공간 부족(가짜 Locator) | 만들기 거부와 안내 문구 | 단위 + 시스템 | F-06.3 NF-24, AC-3 |
| TC-04 | 가져오기·원본 불변 | 사진 10장·영상 1개 폴더 가져오기 → 영상 재생·탐색 | 사본 생성, 원본 크기·수정 시각·해시 같음 | 시스템 | F-02 F-04 NF-17, AC-4 |
| TC-05 | 중복 0 | TC-04의 폴더를 다시 가져오기 | 새 포스트 0개 | 단위 + 시스템 | F-02.4, AC-5 |
| TC-06 | 이식 | 보관함 폴더를 다른 위치로 복사 → 열기 | 포스트 수·카테고리·즐겨찾기·첨부 링크 같음 | 시스템 | F-06.4 NF-21 DR-02, AC-6 |
| TC-07 | 바깥 편집 | `.md`를 직접 고침 / 동시에 앱에서도 고침 | 카드 반영 / 충돌 대화상자 | 시스템 | F-15, AC-7 |
| TC-08 | 궤도 뷰 조작 | 드래그·휠·탭·더블탭 | 회전·이동·선택·전체 보기 | 시스템 | F-08, AC-8 |
| TC-09 | 두 뷰 연동 | 궤도에서 선택 → 피드에서 보기, 반대로도 | 같은 포스트가 선택된 채 이동 | 시스템 | F-08 F-09, AC-9 |
| TC-10 | 휴지통 | 삭제 → 휴지통 → 복원 | 파일이 원래 자리로 돌아옴 | 단위 + 시스템 | F-07.3 NF-10, AC-10 |
| TC-11 | 완전 로컬 | 네트워크 끊고 TC-01~10 / release APK 권한 확인 | 모두 동작, INTERNET 권한 없음 | 시스템 + 검토 | IF-08 NF-16, AC-11 |
| TC-12 | 사이드로드 | `adb install -r` → 실행 | 폰·헤드셋에서 실행 | 시연 | CN-02 NF-23, AC-12 |
| TC-13 | 장애 상황 | 10.2 표의 상황을 하나씩 재현 | 멈추지 않음, 자료 손실 없음 | 시스템 | NF-13~15 NF-25, AC-13 |
| TC-14 | 성능·회귀 | 포스트 2,000개 보관함으로 측정 + 전체 시험 실행 | NF-01~03 만족, 전부 통과 | 분석 + 시스템 | NF-01~03 NF-19, AC-14 |
| TC-15 | 접근성 | 색 대비 자동 계산, 키보드만으로 조작, `Semantics` 레이블 확인, 글자 200 % | NF-09 기준 만족 | 위젯 + 시연 | NF-09, AC-15 |
| TC-16 | 한국어·지역화 | 한글 입력기로 조합하며 쓰기 · 한글 11,172자 렌더링 · 「가」「나」「A」「1」 정렬 · NFD로 저장된 이름 검색 · 날짜·숫자 형식 · 한글 자판에서 단축키 | LC-01~10 기준 만족 | 단위 + 위젯 + 시연 | LC-01~10, AC-16 |

### 11.4 환경, 시작·종료 기준
- 환경: Windows 11 x64 개발 PC(매 마일스톤), Android 기기 또는 에뮬레이터(debug 빌드), 가능하면 XR 헤드셋 1대. 네트워크 없이도 돈다.
- 시작 기준: 해당 작업의 코드가 `flutter analyze` 경고 0.
- 종료 기준: 마일스톤의 모든 단위·위젯 시험 통과, M4에서 TC-01~16 통과 또는 이유가 적힌 「미확인」.
- 결함은 progress.md 「작업 로그」에 TC 번호와 함께 남기고, 고칠 작업이 크면 「열린 질문」에 올린다.
- 시험 완료 보고는 T37에서 progress.md에 AC별 결과 표로 남긴다.

---

## 12. 빌드·배포

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
              +-- 권한 목록에 INTERNET 없음 확인  =  완전 로컬
              `-- adb install -r  ->  폰 / Meta Quest / Android XR 헤드셋
```

| 항목 | 값 |
|---|---|
| 앱 이름 | `A-Z` |
| Dart 패키지 | `a_z` |
| 앱 id | `app.az.archive` (가칭, progress.md 열린 질문) |
| 버전 | `pubspec.yaml`의 `0.1.0+1`부터, 마일스톤마다 두 번째 자리 올림 |
| release 권한 | `MANAGE_EXTERNAL_STORAGE`만. INTERNET 없음 |
| 권한 확인 | `apkanalyzer manifest permissions app-arm64-v8a-release.apk` |
| 서명 | 로컬 키스토어. `android/key.properties`와 키 파일은 커밋하지 않음. 키를 잃으면 업데이트 설치가 안 되므로 백업 위치를 progress.md에 적음 |
| Windows | `build\windows\x64\runner\Release\` 폴더를 `A-Z-windows.zip`으로 |

XR: 지금은 2D 패널 앱이다. 몰입형은 범위 밖이지만 **보관함 형식(4절)이 약속**이라, 나중에 Unity·Android XR 네이티브 앱이 같은 폴더를 읽으면 된다.

---

## 13. 패키지

버전은 `pubspec.lock`으로 고정한다. 새 패키지가 필요하면 이 표에 이유를 먼저 적는다.

| 패키지 | 용도 | 쓰는 곳 |
|---|---|---|
| `media_kit`, `media_kit_video`, `media_kit_libs_video` | 영상 재생 (Windows·Android 같은 코덱) | `MediaViewer` |
| `fc_native_video_thumbnail` | 영상 대표 프레임 | `VideoProbe` |
| `exif` | 사진 촬영일 | `PhotoProbe` |
| `yaml` | 머리말 읽기 | `PostCodec` |
| `file` | 파일 시스템 추상화 (테스트용 `MemoryFileSystem`) | 로직 전체 |
| `path` | 경로 다루기 | 로직 전체 |
| `path_provider` | 기기별 설정 폴더, Android 저장소 목록 | `storage.dart` |
| `permission_handler` | 「모든 파일 접근」 권한 | `AndroidStorageLocator` |
| `win32`, `ffi` | 드라이브 목록·종류·남은 공간 | `WindowsStorageLocator` |
| `crypto` | SHA-1 | `ContentHasher` |
| `file_picker` | 파일·폴더 고르기 | `Composer`, `VaultStartScreen`, 가져오기 |
| `desktop_drop` | 끌어다 놓기 (Windows) | `Composer` |
| `vector_math` | 3D 투영 | `Camera3D` |
| `url_launcher` | 탐색기·기본 앱 열기 (Windows) | `NavigatorCard`, [H] |
| `open_filex` | 기본 앱으로 열기 (Android) | `NavigatorCard` |
| `flutter_localizations` (SDK) | 기본 위젯의 한국어(`ko-KR`) | `AzApp` |
| `intl` | ko-KR 날짜·숫자 형식 | 화면 전체 |
| `unorm_dart` | 유니코드 NFC 정규화 | `KoText`, `Vault` (DR-03) |
| (개발) `flutter_lints`, `integration_test` | 분석, e2e | — |

---

## 14. 위험

| 위험 | 확인 시점 | 대안 |
|---|---|---|
| Flutter·Android SDK 설치가 큼(수 GB) | T1 | — |
| Windows 플러그인 빌드에 개발자 모드·VS C++ 워크로드 필요 | T1 | 설치 안내를 README에 |
| 헤드셋(Quest)에 「모든 파일 접근」 설정 화면이 없을 수 있음 | T7·T35 | `adb shell appops`로 허용 |
| SD 카드 쓰기가 막힐 수 있음 | T7 | 그 기기에서는 내부 저장소만 고르게 |
| `fc_native_video_thumbnail`의 Windows 지원·코덱 범위 | T9 | `media_kit` 화면 캡처로 대신 |
| `media_kit` 때문에 APK가 20~30 MB 커짐 | T35 | 받아들임 (`--split-per-abi`) |
| 폰·헤드셋에서 2.5D 궤도 뷰 성능 | T26·T33 | 라벨 수·링 정밀도 자동 조절 (3.4) |
| Obsidian과 첨부 링크 해석 차이 | T5 | 보관함 기준 전체 경로로 씀 |
| Windows 긴 경로(260자) | T7 | 경고 + 짧은 이름 제안 |
| 네트워크 드라이브에서 폴더 감시가 불안정 | T8 | 창이 활성화될 때 다시 훑기 + 수동 새로고침 |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 0.1 | 2026-10-21 | 최초 작성 | Claude Code |
| 0.2 | 2026-10-21 | ISO/IEC/IEEE 42010 개요(0절: 이해관계자·관심사·관점·맥락·결정) 추가. 11절을 ISO/IEC/IEEE 29119-3 시험 계획(TC-01~15)으로 개편. ISO/IEC 40500 접근성: 원칙 7, 글씨용 카테고리 색 `categoriesText`, 대비표. 보관함 경로 구분자 `/`·NFC·ISO 8601 규칙 추가 | Claude Code |
| 0.3 | 2026-10-21 | 대상 지역 대한민국(ISO 3166-1 `KR`): 2.7 지역화 설계, `AzRegion`·`KoText`, TC-16, 패키지 `flutter_localizations`·`intl`·`unorm_dart` 추가 | Claude Code |
