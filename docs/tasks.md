# 소프트웨어 개발 계획서 (SDP)

| 항목 | 내용 |
|---|---|
| 문서 번호 | AZ-SDP |
| 문서 이름 | A-Z 소프트웨어 개발 계획서 (작업 순서) |
| 버전 · 상태 | 1.0 · 초안 (검토 대기) |
| 작성일 · 수정일 | 2026-10-21 · 2026-10-21 |
| 작성 · 승인 | Claude Code (AI) · 프로젝트 소유자 (미승인) |
| 적용 표준 | ISO/IEC/IEEE 12207:2017, ISO/IEC/IEEE 15289:2019 |
| 상위 문서 | [AZ-SRS](requirements.md) · [AZ-AD](design.md) |

**[처음으로](../README.md)** · [요구사항](requirements.md) · [설계](design.md) · **[작업 순서](tasks.md)** · [진행 상황](progress.md) · [작업 지침](../AGENTS.md)

작업 **상태**는 [progress.md](progress.md) 상태판에서만 관리합니다.

---

## 로드맵

```
 M0        M1              M2            M3         M4
 준비      기록 엔진        피드 앱       궤도 뷰    출시
┌────┬───────────────┬─────────────┬──────────┬──────────┐
│ 01 │ 03 04 05 06 07│ 14 15 16 17 │ 25 26 27 │ 31 32 33 │
│ 02 │ 08 09 10 11   │ 18 19 20 21 │ 28 29 30 │ 34 35 36 │
│    │ 12 13         │ 22 23 24    │          │ 37       │
└────┴───────────────┴─────────────┴──────────┴──────────┘
```

| 마일스톤 | 끝나면 |
|---|---|
| M0 준비 | 빈 앱이 양쪽에서 뜸 |
| M1 기록 엔진 | 모델·저장·미디어·가져오기 (테스트 완료) |
| M2 피드 앱 | 시작 화면~피드 (매일 쓸 수 있음) |
| M3 궤도 뷰 | 3D + 튜토리얼 |
| M4 출시 | 다듬기·시험·배포 |

---

## M0 준비

### T1 개발 환경
- 선행: — · 관련: CN-01, AC-12
- 할 일: Flutter·Android SDK·JDK 설치, `flutter doctor` 확인
- 완료: Windows·Android 빌드 가능

### T2 프로젝트 뼈대
- 선행: T1 · 관련: CN-03, LC-02
- 할 일: `flutter create a_z`, 빈 창, INTERNET 제거, ko-KR, 패키지 폴더
- 완료: 양쪽에서 빈 창, `flutter analyze` 경고 0

---

## M1 기록 엔진

### T3 기록 모델
- 선행: T2 · 관련: F-01
- 파일: `lib/archive.dart`, `test/archive_model_test.dart`
- 할 일: `Post`·`MediaRef`·`Category`·`PostQuery`·`TagParser`·`KoText`·`AzException`
- 완료: 단위 테스트 통과

### T4 Archive
- 선행: T3 · 관련: F-01
- 파일: `lib/archive.dart`, `test/archive_test.dart`
- 할 일: `Archive`·`Clock` — 작성·수정·삭제·검색·통계
- 완료: 가짜 2,000개에서 query 50 ms 이내

### T5 PostCodec
- 선행: T4 · 관련: F-01, DR-01~05
- 파일: `lib/vault.dart`, `test/post_codec_test.dart`
- 할 일: `.md` ↔ `Post` 왕복, 모르는 필드 보존
- 완료: 왕복 테스트 통과

### T6 AtomicWriter · Vault · Trash
- 선행: T5 · 관련: F-06, F-07, DR-02
- 파일: `lib/vault.dart`, `test/vault_test.dart`
- 할 일: 원자적 쓰기·만들기·열기·첨부·휴지통·복원
- 완료: MemoryFileSystem 테스트, 이식 테스트 통과

### T7 StorageLocator
- 선행: T6 · 관련: F-06
- 파일: `lib/storage.dart`, `test/storage_test.dart`
- 할 일: 인터페이스·Windows 구현·LocationCheck·VaultCatalog
- 완료: 단위 테스트, Windows에서 볼륨 목록

### T8 VaultIndex · Settings · Watcher
- 선행: T6 · 관련: F-14, F-15
- 파일: `lib/vault.dart`, `test/vault_index_test.dart`
- 할 일: 색인·설정·바깥 변경 감지
- 완료: 속상 시 재생성 테스트

### T9 MediaProbe
- 선행: T3 · 관련: F-04
- 파일: `lib/media.dart`, `test/probe_test.dart`
- 할 일: `PhotoProbe`·`VideoProbe`·`ProbeRegistry`
- 완료: 생성 이미지로 테스트

### T10 ThumbnailCache
- 선행: T9 · 관련: F-03
- 파일: `lib/media.dart`, `test/thumbnail_test.dart`
- 할 일: 480 px 썸네일·무효화
- 완료: 캐시 테스트 통과

### T11 ImportJob
- 선행: T6, T9 · 관련: F-02
- 파일: `lib/importer.dart`, `test/import_test.dart`
- 할 일: 스캐너·해시·복사·진행률·취소·이어하기
- 완료: 원본 불변 확인 테스트

### T12 예시 자료
- 선행: T5 · 관련: F-10
- 파일: `tools/`, `assets/sample_vault/`
- 할 일: Pillow·OpenCV로 샘플 생성
- 완료: 5 MB 이하, PostCodec으로 읽힘

### T13 Seeder · TutorialController
- 선행: T12 · 관련: F-10
- 파일: `lib/tutorial.dart`, `test/seeder_test.dart`
- 할 일: 샘플 복사·튜토리얼 단계 관리
- 완료: 단위 테스트 통과

---

## M2 피드 앱

### T14 테마 · 배경
- 선행: M1 · 관련: NF-08
- 파일: `lib/theme.dart`
- 할 일: 디자인 토큰·Pretendard·배경 링·대비 자동 시험
- 완료: 위젯에 직접 값 없음, 대비 4.5:1 통과

### T15 HomeShell · AppState
- 선행: T14 · 관련: F-05
- 파일: `lib/app.dart`, `lib/main.dart`
- 할 일: 조립·반응형 1/2/3단·뷰 전환
- 완료: 창 폭에 따라 배치 변화

### T16 시작 화면
- 선행: T15 · 관련: F-06
- 파일: `lib/ui/start.dart`
- 할 일: 새로 만들기·열기·최근 보관함
- 완료: 위젯 테스트

### T17 피드
- 선행: T15 · 관련: F-03
- 파일: `lib/ui/feed.dart`
- 할 일: `FeedView`·`PostCard`·`MediaGrid`
- 완료: 1~5장 그리드 렌더링

### T18 작성칸
- 선행: T17 · 관련: F-01
- 파일: `lib/ui/components.dart`
- 할 일: `Composer`·끌어다 놓기
- 완료: 글·첨부·게시 동작

### T19 뷰어
- 선행: T17 · 관련: F-04
- 파일: `lib/ui/components.dart`
- 할 일: `MediaViewer`·재생·탐색
- 완료: 사진·영상 보기

### T20 내비게이터
- 선행: T17 · 관련: F-09
- 파일: `lib/ui/components.dart`
- 할 일: `NavigatorCard`
- 완료: 선택 연동

### T21 범례 · 검색 · 필터
- 선행: T17 · 관련: F-05, F-11, F-13
- 파일: `lib/ui/components.dart`
- 할 일: `Legend`·`SearchBox`·태그 칩
- 완료: 필터가 두 뷰에 적용

### T22 수정 · 삭제 · 즐겨찾기
- 선행: T18 · 관련: F-07, F-12
- 파일: `lib/ui/components.dart`
- 할 일: 인라인 수정·삭제 확인·별표·고정
- 완료: 휴지통 이동 확인

### T23 가져오기 화면
- 선행: T15 · 관련: F-02
- 파일: `lib/ui/components.dart`
- 할 일: 미리 보기·진행률·완료 요약
- 완료: 취소·이어하기

### T24 끊긴 첨부 · 바깥 편집
- 선행: T8 · 관련: F-14, F-15
- 파일: `lib/ui/components.dart`
- 할 일: 재연결 UI·충돌 대화상자
- 완료: 위젯 테스트

---

## M3 궤도 뷰

### T25 OrbitLayout · Camera3D
- 선행: M2 · 관련: F-08
- 파일: `lib/ui/orbit.dart`
- 할 일: 결정적 배치·투영
- 완료: 같은 자료 → 같은 자리

### T26 OrbitPainter
- 선행: T25 · 관련: F-08
- 파일: `lib/ui/orbit.dart`
- 할 일: 배경·링·구체·노드 그리기
- 완료: 데스크톱 60 fps

### T27 라벨 · 선택
- 선행: T26 · 관련: F-08
- 파일: `lib/ui/orbit.dart`
- 할 일: LOD·라벨·선택·날아가기
- 완료: 탭으로 선택

### T28 Tour
- 선행: T27 · 관련: F-16
- 파일: `lib/ui/orbit.dart`
- 할 일: 자동 여행·이전/다음
- 완료: 조작 시 정지

### T29 뷰 전환
- 선행: T27 · 관련: F-08
- 파일: `lib/ui/`
- 할 일: 전환 모션
- 완료: 선택 연동

### T30 코치마크
- 선행: T27 · 관련: F-10
- 파일: `lib/ui/coach_marks.dart`
- 할 일: 7단계·체크리스트 반영
- 완료: 건너뛰기·다시 보기

---

## M4 출시

### T31 접근성 · 입력
- 선행: M3 · 관련: NF-08, AC-15
- 할 일: 대비·키보드·낭독기·200 %·터치 48 dp
- 완료: TC-15 통과

### T32 장애 시나리오
- 선행: T31 · 관련: AC-13
- 할 일: index 손상·첨부 삭제·강제 종료·드라이브 분리
- 완료: TC-13 통과

### T33 성능
- 선행: T32 · 관련: NF-01~03
- 할 일: 2,000개 측정
- 완료: TC-14 통과

### T34 e2e
- 선행: T32 · 관련: AC-1~14
- 할 일: 시나리오 A~E
- 완료: Windows 통과, Android는 기기 가능 시

### T35 배포
- 선행: T33 · 관련: AC-12
- 할 일: APK 서명·Windows zip
- 완료: 사이드로드 성공

### T36 (선택) 휴지통 · 단축키 · zip
- 선행: T31 · 관련: F-17~19

### T37 마무리
- 선행: T35 · 관련: 모든 AC
- 할 일: AC-1~16 점검표·문서 1.0 승인
- 완료: 모든 AC 통과 또는 미확인 사유

---

## 요구 ↔ 작업 연결

| 요구 | 작업 |
|---|---|
| F-01 | T3 T4 T5 T6 T18 |
| F-02 | T9 T11 T23 |
| F-03 | T17 |
| F-04 | T19 |
| F-05 | T4 T21 |
| F-06 | T6 T7 T16 |
| F-07 | T6 T22 |
| F-08 | T25 T26 T27 T29 |
| F-09 | T20 |
| F-10 | T12 T13 T30 |
| F-11 · F-13 | T4 T21 |
| F-12 | T22 |
| F-14 · F-15 | T8 T24 |
| F-16 | T28 |
| NF-08 · AC-15 | T14 T31 |
| NF-01~03 · AC-14 | T33 |
| AC-13 | T32 |
| AC-16 | T3 T18 T21 T31 |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성 |
|---|---|---|---|
| 1.0 | 2026-10-21 | ISO 한국 표준으로 처음부터 재작성 | Claude Code |
