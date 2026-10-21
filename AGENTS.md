# AGENTS.md — 작업 지침 (사람과 모든 AI 도구 공통)

[처음으로](README.md) · [요구사항](docs/requirements.md) · [설계](docs/design.md) · [작업 순서](docs/tasks.md) · [진행 상황](docs/progress.md) · **작업 지침**

이 저장소에서 일하는 **사람과 AI 코딩 도구**(Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot 등)가 똑같이 지킬 규칙입니다.
문서와 코드가 어긋나면 **문서가 기준**입니다.

## 0. 이 파일과 다른 지침 파일

```
AGENTS.md  <-- 진짜 지침 (이 파일 하나만 고친다)
  ^
  +-- CLAUDE.md ......................... Claude Code가 읽음 -> AGENTS.md를 가져옴
  +-- GEMINI.md ......................... Gemini CLI가 읽음  -> AGENTS.md를 가져옴
  `-- .github/copilot-instructions.md ... GitHub Copilot이 읽음 -> AGENTS.md를 가리킴
  (Codex·Cursor 등은 AGENTS.md를 바로 읽음)
```

처음 온 사람·도구가 읽는 순서:

```
README.md ........ 무엇을 만드는지, 한눈에 보기
  -> AGENTS.md ... 지킬 규칙 (지금 이 파일)
  -> docs/progress.md ... 지금 상태, 다음 작업, 인수인계 메모
  -> docs/tasks.md ...... 다음 작업의 카드
  -> docs/requirements.md / docs/design.md ... 카드가 가리키는 부분만
```

## 1. 작업 순서

```
progress.md  ->  상태판에 [~] + 이름  ->  tasks.md 카드  ->  작업 하나  ->  완료 조건 확인  ->  progress.md 기록
 지금 어디?       "내가 잡았다"            할 일·완료 조건    (하나만!)      analyze·test·실행     [x] + 로그 + 인수인계
```

1. `docs/progress.md`에서 「다음 작업」과 상태판을 확인한다.
2. 상태판에서 그 작업을 `[~]`로 바꾸고 작업자 이름(사람 이름 또는 도구 이름)과 날짜를 적는다. 이미 다른 사람이 `[~]`로 잡은 작업은 하지 않는다.
3. `docs/tasks.md`에서 그 작업 카드의 **할 일**과 **완료 조건**을 읽는다. 카드가 가리키는 `requirements.md`·`design.md` 절만 읽으면 된다.
4. **한 번에 작업 하나만** 한다. 다음 작업의 일을 미리 끌어오지 않는다.
5. 완료 조건을 직접 확인한다 (아래 「6. 확인 방법」).
6. `docs/progress.md`를 고친다: 상태판 `[x]` · 작업 로그 한 줄 · 진행 막대 · 「다음 작업」 · 인수인계 메모.
7. 막히면 상태판을 `[!]`로 바꾸고 메모에 이유를, 「열린 질문」에 Q-번호로 질문을 남기고 멈춘다.
8. 요구가 바뀌어야 한다고 판단되면 코드를 먼저 고치지 말고 `docs/requirements.md` → `docs/design.md` 순으로 고치고, 「결정 기록」에 D-번호로 남긴 뒤 사용자에게 알린다.

## 2. 절대 규칙

- **바깥 원본은 읽기만.** 가져오기할 때 원본 사진·영상은 열어서 복사만 한다. 수정·이동·이름변경·삭제하지 않는다.
- **보관함 안에 절대 경로를 저장하지 않는다.** 모든 경로는 보관함 폴더 기준 상대 경로다. 그래야 어느 드라이브·기기로 옮겨도 그대로 열린다.
- **특정 드라이브·경로를 코드에 박지 않는다.** `C:\`, `D:\`, `Z:\`, `/storage/emulated/0` 같은 값은 코드에 쓰지 않는다. 위치는 항상 `StorageLocator`가 알려주고 사용자가 고른다.
- **디스크 쓰기는 `AtomicWriter`만.** 임시 파일에 쓰고 rename으로 바꾼다. 보관함 폴더 구조는 `Vault`만 안다.
- **삭제는 휴지통으로.** 포스트를 지우면 `.az/trash/`로 옮긴다. 보관함 파일을 영구 삭제하는 코드는 「휴지통 비우기」 하나뿐이다.
- **완전 로컬.** release 빌드에 INTERNET 권한을 넣지 않는다(디버그 빌드만 허용). CDN·원격 폰트·외부 API·분석 도구를 쓰지 않는다. 폰트와 예시 자료는 `assets/`에 넣는다.
- 저작권이 있는 캐릭터 이미지를 넣지 않는다. 마스코트와 예시 자료는 직접 만든 것만 쓴다.
- 비밀 정보(서명 키, `android/key.properties`, 개인 경로가 든 로그)를 커밋하지 않는다.

## 3. 객체지향 규칙

```
+---------------------------------------------------------------+
| main.dart     builds every object once (composition root)     |
+---------------------------------------------------------------+
                                |
                                v
+---------------------------------------------------------------+
| SCREEN   app.dart  ui/start  ui/feed  ui/orbit  ui/components |  <- 보여주기만
+---------------------------------------------------------------+
                                |  calls only, never touches disk
                                v
+---------------------------------------------------------------+
| LOGIC    archive.dart  importer.dart  media.dart  tutorial.dart|  <- 위젯 import 금지
+---------------------------------------------------------------+
                                |  read / write
                                v
+---------------------------------------------------------------+
| STORAGE  vault.dart  storage.dart                             |  <- 디스크는 여기만
+---------------------------------------------------------------+
```

1. **파일 = 맡은 일 하나, 클래스 = 할 일 하나.** 로직 파일(`archive`·`vault`·`storage`·`media`·`importer`·`tutorial.dart`)은 `package:flutter/widgets.dart`나 `material.dart`를 import하지 않는다(`foundation.dart`의 `ChangeNotifier`는 허용).
2. **조립은 `main.dart`에서만.** 다른 클래스는 필요한 객체를 생성자로 받는다. 클래스 안에서 다른 서비스를 직접 만들지 않는다. 파일 시스템은 `package:file`의 `FileSystem`으로 받는다(테스트에서는 `MemoryFileSystem`).
3. **경계를 지킨다.** 화면은 `AppState`와 `Archive`만 부른다. 디스크는 `vault.dart`·`storage.dart`만 만진다. 드라이브·위치는 `StorageLocator`만 안다.
4. **상태는 `AppState` 한 곳.** 외부 상태관리 패키지를 쓰지 않는다. 두 뷰(피드·궤도)는 같은 `AppState`를 구독하고, NavigatorCard·Legend·SearchBox·ControlBar를 함께 쓴다.
5. **확장은 상속 + 등록.** 새 미디어 형식은 `MediaProbe`를 상속한 클래스 하나와 `ProbeRegistry` 등록 한 줄로 추가한다. 새 플랫폼은 `StorageLocator` 구현 하나로 추가한다. 확장 지점마다 본보기 클래스(`PhotoProbe`, `WindowsStorageLocator`)를 보고 똑같이 만든다.
6. 공개 메서드에는 단위 테스트를 붙인다. 테스트 자료(사진·영상·보관함)는 테스트 안에서 즉석으로 만든다.
7. 오류는 `AzException` 계층으로 던지고, 화면은 그 종류를 보고 Toast로 알린다. 예외 하나 때문에 앱이 멈추면 안 된다.
8. 클래스·파일 이름은 `docs/design.md` 6.2 표의 이름을 그대로 쓴다. 새 클래스를 만들면 그 표에 먼저 추가한다.

## 4. Dart·화면 규칙

- `flutter analyze` 경고 0, `dart format` 적용.
- 공개 API에는 타입을 명시한다. `dynamic`은 JSON·YAML을 파싱하는 경계에서만 쓴다.
- 색·간격·반경·그림자·움직임 시간은 `lib/theme.dart`의 토큰(`AzColors`, `AzShapes`, `AzMotion`)만 쓴다. 위젯 안에 값을 직접 쓰지 않는다.
- 모든 움직임은 `MediaQuery.disableAnimationsOf(context)`가 참이면 줄이거나 끈다.
- 모든 기능은 탭·클릭으로 쓸 수 있어야 한다. 마우스 올리기(hover)는 보너스로만 쓴다. 터치 대상은 48dp 이상.
- 화면 문구는 한국어. 코드 식별자는 영어, 주석은 꼭 필요한 곳에만 한국어로 짧게.
- 무거운 일(해시 계산·썸네일·폴더 훑기)은 isolate나 비동기로 처리해 화면이 멈추지 않게 한다.
- 패키지를 새로 추가해야 하면 `docs/design.md` 13절 표에 이유를 먼저 적는다.

## 5. 함께 일하기 (사람·여러 AI 도구)

- **대화 기록에 기대지 않는다.** 다음 사람이 알아야 할 것은 모두 문서에 남긴다: 결정은 progress.md 「결정 기록」(D-번호), 질문은 「열린 질문」(Q-번호), 멈춘 지점은 「인수인계 메모」.
- **번호는 다시 매기지 않는다.** F(요구)·AC(수용 기준)·T(작업)·D(결정)·Q(질문) 번호는 한 번 붙이면 바꾸지 않는다. 없애야 하면 「(폐기)」를 붙이고 이유를 적는다.
- **상태는 progress.md 상태판에서만.** tasks.md는 작업의 정의만 담고, 정의가 바뀔 때만 고친다.
- **브랜치와 커밋은 작업 단위로.** 브랜치 이름은 `t17-feed-card`처럼 작업 번호로 시작한다. 커밋 메시지는 `T17: 피드 카드와 미디어 그리드`.
- 남이 잡은(`[~]`) 작업의 파일을 크게 고쳐야 하면, 먼저 「열린 질문」에 적고 기다린다.

## 6. 문서 형식 (어디서나 똑같이 보이게)

- 문서는 Markdown(GitHub 방식)만 쓴다. HTML·이미지 없이도 내용이 다 이해되어야 한다.
- 그림은 코드 블록 안의 **ASCII**로 그린다(`+ - | v > .` 등). 상자 안에는 영어·숫자만 쓰고, 한국어 설명은 상자 바깥 줄 끝에 둔다(글자 폭 차이로 줄이 어긋나지 않게).
- 링크는 상대 경로(`docs/design.md`)로 쓴다. 제목 앵커 링크(`#…`)는 쓰지 않는다(도구마다 다르게 만듦).
- 파일은 UTF-8, 줄바꿈 LF, 마지막 빈 줄 있음(`.editorconfig`, `.gitattributes`가 강제).
- 날짜는 `YYYY-MM-DD`, 시각은 ISO 8601(`2026-10-21T13:20:00+09:00`).

## 7. 확인 방법

| 언제 | 명령 |
|---|---|
| 모든 작업 | `flutter analyze` → `flutter test` |
| 화면을 바꿨을 때 | `flutter run -d windows`로 직접 보고 완료 조건 확인 |
| Android에 영향이 있을 때 | `flutter run -d <기기 id>` (에뮬레이터는 debug 빌드) |
| 마일스톤 끝 | `flutter test integration_test -d windows` |
| 배포 작업 | release APK 권한 목록에 INTERNET이 없는지 확인 |

- 테스트용 보관함은 시스템 임시 폴더 아래에 만든다. 사용자의 실제 보관함을 테스트에 쓰지 않는다.
- 확인하지 못한 것(예: XR 헤드셋이 없음)은 progress.md 로그에 「미확인」으로 그대로 적는다.

## 8. 커밋

- 사용자가 요청할 때만 커밋한다.
- 메시지 형식: `T17: 피드 카드와 미디어 그리드` (작업 번호 + 한 일)
- `android/key.properties`, 키스토어 파일, `build/`, `.dart_tool/`은 커밋하지 않는다.
