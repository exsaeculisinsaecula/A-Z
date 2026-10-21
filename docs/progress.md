# 진행 상태 보고서 (PSR)

| 항목 | 내용 |
|---|---|
| 문서 번호 | AZ-PSR |
| 문서 이름 | A-Z 진행 상태 보고서 |
| 버전 · 상태 | 1.1 · 계속 갱신 |
| 보고 기준일 | 2026-10-21 |
| 작성 | Claude Code (AI) |
| 적용 표준 | ISO/IEC/IEEE 15289:2019, ISO/IEC/IEEE 29119-3:2021 |
| 상위 문서 | [AZ-SDP](tasks.md) |

**[처음으로](../README.md)** · [요구사항](requirements.md) · [설계](design.md) · [작업 순서](tasks.md) · **[진행 상황](progress.md)** · [작업 지침](../AGENTS.md)

작업 상태의 **유일한 기록**입니다. 시작 전에 먼저 보고, 끝나면 고칩니다.

---

## 한눈에

```
M0  [##........] 100%   2/2     준비
M1  [##........]  18%   2/11    기록 엔진
M2  [..........]   0%   0/11    피드 앱
M3  [..........]   0%   0/6     궤도 뷰
M4  [..........]   0%   0/7     출시
```

- 현재 상태: **T4 완료.** Archive 작성·수정·삭제·검색·통계·그래프.
- 다음 작업: **T5 PostCodec**
- 막힌 것: 없음

---

## 상태판

`[ ]` 대기 · `[~]` 진행 · `[x]` 완료 · `[!]` 막힘

| 작업 | 이름 | 상태 | 작업자 | 날짜 | 메모 |
|---|---|---|---|---|---|
| T1 | 개발 환경 | [x] | Claude Code | 2026-10-21 | flutter doctor 전부 통과 |
| T2 | 프로젝트 뼈대 | [x] | Claude Code | 2026-10-21 | flutter analyze 0, APK 릴리즈 |
| T3 | 기록 모델 | [x] | Claude Code | 2026-10-21 | 테스트 28개, APK+exe 릴리즈 |
| T4 | Archive | [x] | Claude Code | 2026-10-21 | 테스트 51개, APK+exe 릴리즈 |
| T5 | PostCodec | [~] | Claude Code | 2026-10-21 | |
| T6 | AtomicWriter · Vault · Trash | [ ] | | | |
| T7 | StorageLocator | [ ] | | | |
| T8 | Index · Settings · Watcher | [ ] | | | |
| T9 | MediaProbe | [ ] | | | |
| T10 | ThumbnailCache | [ ] | | | |
| T11 | ImportJob | [ ] | | | |
| T12 | 예시 자료 | [ ] | | | |
| T13 | Seeder · Tutorial | [ ] | | | |
| T14 | 테마 · 배경 | [ ] | | | |
| T15 | HomeShell · AppState | [ ] | | | |
| T16 | 시작 화면 | [ ] | | | |
| T17 | 피드 | [ ] | | | |
| T18 | 작성칸 | [ ] | | | |
| T19 | 뷰어 | [ ] | | | |
| T20 | 내비게이터 | [ ] | | | |
| T21 | 범례 · 검색 · 필터 | [ ] | | | |
| T22 | 수정 · 삭제 · 즐겨찾기 | [ ] | | | |
| T23 | 가져오기 화면 | [ ] | | | |
| T24 | 끊긴 첨부 · 바깥 편집 | [ ] | | | |
| T25 | OrbitLayout · Camera3D | [ ] | | | |
| T26 | OrbitPainter | [ ] | | | |
| T27 | 라벨 · 선택 | [ ] | | | |
| T28 | Tour | [ ] | | | |
| T29 | 뷰 전환 | [ ] | | | |
| T30 | 코치마크 | [ ] | | | |
| T31 | 접근성 · 입력 | [ ] | | | |
| T32 | 장애 시나리오 | [ ] | | | |
| T33 | 성능 | [ ] | | | |
| T34 | e2e | [ ] | | | |
| T35 | 배포 | [ ] | | | |
| T36 | (선택) 휴지통 · 단축키 | [ ] | | | |
| T37 | 마무리 | [ ] | | | |

---

## 인수인계 메모

> T1 개발 환경 완료: Flutter 3.47.7, JDK 17, Android SDK 36, VS C++.
> 다음: T2 프로젝트 뼈대 (`flutter create` + 빈 창 + ko-KR + INTERNET 제거).
> 규칙: 기능 1개마다 release APK + Windows exe 릴리즈 (D-13, AGENTS.md 8절).
> PATH: `C:\dev\flutter\bin`, JAVA_HOME: `C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot`.

---

## 작업 로그

| 날짜 | 작업 | 작업자 | 결과 | 메모 |
|---|---|---|---|---|
| 2026-10-21 | T4 Archive | Claude Code | 테스트 51개, [Release](https://github.com/exsaeculisinsaecula/A-Z/releases/tag/t4-archive) | 작성·수정·삭제·검색·통계·궤도 그래프 |
| 2026-10-21 | T3 기록 모델 | Claude Code | 테스트 28개, APK+exe 릴리즈 | Post/MediaRef/TagParser/KoText/PostQuery/AzException |
| 2026-10-21 | T2 프로젝트 뼈대 | Claude Code | APK 릴리즈 완료 | app-arm64 14.8MB, INTERNET 없음, ko-KR, app.az.archive |
| 2026-10-21 | T1 개발 환경 | Claude Code | flutter doctor 0 issues | Flutter 3.47.7, JDK 17, Android SDK 36, VS C++ |
| 2026-10-21 | 문서 재작성 | Claude Code | ISO 한국 표준 1.0 | AZ-xxx 문서 체계, F/NF/DR/LC/AC/TC 정리 |

---

## 결정 기록

| ID | 날짜 | 결정 | 이유 |
|---|---|---|---|
| D-01 | 2026-10-21 | 이름 A-Z (패키지 `a_z`, 캐시 `.az/`) | 사용자 지정 |
| D-02 | 2026-10-21 | Flutter, Windows + Android | APK 필요 |
| D-03 | 2026-10-21 | 보관함 폴더 (.md + 첨부) | 이식성 |
| D-04 | 2026-10-21 | 아무 드라이브에 폴더 생성 | 위치 자유 |
| D-05 | 2026-10-21 | 객체지향 · 스타터형 | 유지보수성 |
| D-06 | 2026-10-21 | 궤도 뷰 CustomPainter 2.5D | 의존성 최소 |
| D-07 | 2026-10-21 | media_kit 영상 | 코덱 통일 |
| D-08 | 2026-10-21 | 내용 해시 중복 판정 | 사본은 경로가 다름 |
| D-09 | 2026-10-21 | AGENTS.md 단일 지침 | 도구 공통 |
| D-10 | 2026-10-21 | ISO 문서 체계 (AZ-xxx) | 사용자 요구 |
| D-11 | 2026-10-21 | 접근성 categoriesText | WCAG AA |
| D-12 | 2026-10-21 | 지역 KR · ko-KR | 사용자 지정 |
| D-13 | 2026-10-21 | **기능 1개 완료마다 release APK + Windows exe 릴리즈 → GitHub Release 업로드** | 사용자 지정. 진행 확인·배포용 |

---

## 열린 질문

| ID | 질문 | 기본값 |
|---|---|---|
| Q-01 | Android 앱 id | `app.az.archive` |
| Q-02 | 마스코트 | 동심원 링 로고 |
| Q-03 | 궤도 링크 규칙 | 태그 시간순 이웃 |
| Q-04 | XR 헤드셋 기종 | 없으면 「미확인」 |
| Q-05 | 저장소 라이선스 | 미정, 모든 권리 보유 |

---

## 환경 기록

| 항목 | 버전 |
|---|---|
| Flutter | 3.47.7 stable (`C:\dev\flutter`) |
| Dart | 3.13.5 |
| Android SDK | 36.0.0 (`%LOCALAPPDATA%\Android\Sdk`) |
| JDK | Microsoft OpenJDK 17.0.20.1 |
| Visual Studio | 2022 Community 17.14 (C++ 워크로드) |
| adb | 37.0.1 (platform-tools) |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 1.0 | 2026-10-21 | ISO 한국 표준으로 처음부터 재작성 | Claude Code |
| 1.1 | 2026-10-21 | T1 완료, D-13(APK 릴리즈) 기록 | Claude Code |
