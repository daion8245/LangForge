# ROADMAP.md — LangForge

> 이 문서는 **어떤 순서로 만들 것인가**를 정의합니다.
> 무엇을·왜는 `PRODUCT.md`, 흐름과 수용 조건은 `EXPERIENCE.md`, 시각은 `DESIGN.md`, 구현은 `TECHNICAL.md`, 작업 규칙은 `AGENTS.md` 를 참조하세요.

- 문서 버전: 1.0
- 최종 수정: 2026-08-07
- 개발 방식: 1인 + AI 에이전트 협업

---

## 1. 원칙

| # | 원칙 | 의미 |
|---|---|---|
| R1 | 각 Phase 는 끝났는지 아닌지가 명확하다 | 완료 조건이 `EXPERIENCE.md` 의 `AC-*` 번호로 지정된다. "대충 됐다" 가 없다 |
| R2 | 완료 조건을 통과하지 못하면 다음 Phase 로 가지 않는다 | 미완 항목을 쌓아두고 진행하면 MVP 막판에 전부 터진다 |
| R3 | 안전 장치를 먼저 만든다 | 변수 보호와 검증(Phase 2)이 실제 번역(Phase 3)보다 앞선다 |
| R4 | 매 Phase 마다 테스트를 함께 쓴다 | 나중에 몰아 쓰지 않는다. 테스트 없는 Phase 는 완료가 아니다 |
| R5 | 크기는 상대값으로만 표기한다 | 날짜를 약속하지 않는다. 순서와 규모만 관리한다 |

**작업 크기 표기**

```text
S    한 번에 끝나는 작업. 파일 1~3개
M    여러 파일에 걸침. 하루 안에 마무리 가능한 규모
L    설계 판단이 필요함. 여러 번에 나눠 진행
XL   Phase 하나에 맞먹음. 더 쪼개야 하는 신호
```

---

## 2. 전체 지도

```text
╔══════════════════════ MVP ══════════════════════╗
║                                                 ║
║  Phase 0  토대                            L    ║
║     ↓                                           ║
║  Phase 1  입력과 탐색                     XL   ║
║     ↓                                           ║
║  Phase 2  JSON 구조와 변수 보호           L    ║
║     ↓                                           ║
║  Phase 3  번역 실행 (Gemini)              XL   ║
║     ↓                                           ║
║  Phase 4  편집과 병합                     L    ║
║     ↓                                           ║
║  Phase 5  출력                            L    ║
║     ↓                                           ║
║  Phase 6  프로젝트 저장과 다중 모드        L    ║
║     ↓                                           ║
║  Phase 7  MVP 마감                        M    ║
║                                                 ║
╚═════════════════════════════════════════════════╝
                      ↓
╔══════════════════════ 1.0 ══════════════════════╗
║                                                 ║
║  Phase 8   번역 엔진 3종 추가              L    ║
║  Phase 9   캐시와 용어집                   L    ║
║  Phase 10  충돌 해결과 환경설정            L    ║
║  Phase 11  출력·언어 확장                  M    ║
║  Phase 12  1.0 마감                        M    ║
║                                                 ║
╚═════════════════════════════════════════════════╝
                      ↓
╔═══════════════════ 이후 ════════════════════════╗
║  Phase 13  모바일 (Android)               XL   ║
║  Phase 14  macOS · Linux                   M    ║
╚═════════════════════════════════════════════════╝
```

**Phase 8~11 은 서로 독립적입니다.** 순서를 바꿔도 됩니다. Phase 0~7 은 순차입니다.

---

## Phase 0 — 토대

> 코드를 한 줄도 안 쓰고 끝나는 게 아니라, **앞으로 모든 코드가 딛고 설 바닥**을 만든다.

**크기: L**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 0.1 | git 저장소 초기화, `.gitignore` 확인, MIT `LICENSE` 추가 | S |
| 0.2 | `pubspec.yaml` 의 `name` 을 `nodtranslationproject` → `langforge` 로 변경. 앱 표시 이름·창 제목 설정. `android/`·`ios/`·`web/`·`linux/`·`macos/`·`windows/` 플랫폼 폴더를 `langforge` 기준으로 전부 재생성 | M |
| 0.3 | `TECHNICAL.md` 1.1절의 의존성 추가. `pubspec.lock` 커밋 | S |
| 0.4 | `TECHNICAL.md` 2.2절의 디렉터리 구조 생성 | S |
| 0.5 | `analysis_options.yaml` 을 `TECHNICAL.md` 12.2절대로 교체 | S |
| 0.6 | 폰트 자산 번들 (IBM Plex Sans KR 3종 + JetBrains Mono 2종 + `OFL.txt`) | S |
| 0.7 | 디자인 시스템 토큰 구현 — `LfColors` · `LfSpacing` · `LfRadii` · `LfTypography` ThemeExtension + `context.c/s/r/t` 확장 | M |
| 0.8 | 공통 위젯 뼈대 — `DESIGN.md` 13.3절 목록 중 `LfButton` · `LfStatusChip` · `LfCheckbox` · `LfTextField` · `LfPanel` 우선 | L |
| 0.9 | Drift 스키마 정의 (`TECHNICAL.md` 3.2 · 3.3) + 인메모리 DB 로 삽입/조회 확인 | M |
| 0.10 | 정적 데이터 자산 — `mc_versions.json` (12개) · `language_profiles.json` (6개) · `providers.json` (Gemini 모델 2개와 `v1beta` 엔드포인트) | S |
| 0.11 | 로거 + `SensitiveFilter` + 파일 회전 | M |
| 0.12 | `window_manager` 로 최소 창 크기 900×600 설정 | S |
| 0.13 | GitHub Actions CI (`TECHNICAL.md` 12.1) | S |
| 0.14 | **Example Mode 테스트 픽스처 제작** — `test_fixtures/Example Mode/generate.dart` 로 JAR 3개를 결정론적으로 생성. 3절 참조 | M |
| 0.15 | 앱이 실행되고 빈 다크 화면이 뜨는 것까지 확인 | S |

### 완료 조건

```text
[ ] flutter run -d windows 로 실행되고 #161616 배경의 빈 화면이 뜬다
[ ] flutter analyze 무경고
[ ] dart format 검사 통과
[ ] CI 가 PR 에서 초록불
[ ] 인메모리 Drift DB 에 entries 1,000행을 배치 삽입하고 인덱스로 조회하는 테스트가 통과한다
[ ] LfButton 등 5개 위젯의 위젯 테스트가 통과한다
[ ] 디자인 토큰이 하드코딩 없이 ThemeExtension 으로만 접근된다
[ ] test_fixtures/Example Mode/ 에 예제 모드 3개가 준비되어 있다
[ ] 로그 파일이 생성되고 회전한다. SensitiveFilter 단위 테스트가 통과한다
```

### 위험

| 위험 | 대응 |
|---|---|
| 폰트 전체 번들로 앱 용량이 크게 증가 | 첫 빌드에서 실측. 15MB 초과 시 서브셋 재검토 (`DESIGN.md` Q4) |
| Drift 코드 생성이 CI 에서 재현되지 않음 | CI 에 `build_runner` 실행 후 diff 검사 단계 포함 |

---

## Phase 1 — 입력과 탐색

> 사용자가 파일을 넣으면 namespace 와 언어 파일 목록이 정확히 나오는 것까지.
> **API 키 없이 여기까지 도달할 수 있어야 한다.** (`EXPERIENCE.md` E1)

**크기: XL**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 1.1 | `ArchiveGuard` — 경로 탈출·압축 폭탄·크기 상한 (`TECHNICAL.md` 4.4) | M |
| 1.2 | `ArchiveReader` — 스트리밍 ZIP 읽기, `assets/*/lang/*.json` 만 실제 읽기 | M |
| 1.3 | `DirectoryReader` — 압축 해제된 폴더 및 mods 폴더 재귀 탐색 | S |
| 1.4 | `ResourcePathParser` — 경로 파싱 (`TECHNICAL.md` 4.5) | S |
| 1.5 | `LanguageCodeNormalizer` — 코드 정규화 (`TECHNICAL.md` 4.6) | S |
| 1.6 | SHA-256 해시 계산 + 중복 감지 | S |
| 1.7 | Isolate 워커 풀 (`TECHNICAL.md` 4.2) | L |
| 1.8 | 스캔 결과 → DB 배치 삽입 | M |
| 1.9 | S1 빈 프로젝트 화면 — 드롭 영역, 파일 선택, 폴더 선택, 드래그 오버 상태 | M |
| 1.10 | S2-A 프로젝트 탐색기 — 3단 트리, 체크박스 연동, 상태 점, JAR 필터 | L |
| 1.11 | S2-B 목록 (읽기 전용) — key · 원문 표시. 번역 열은 비어 있음 | M |
| 1.12 | 상단 바 · 상태 바 · 하단 배너 (`EXPERIENCE.md` S7 · S8) | M |
| 1.13 | 진행률 스트리밍 + 취소 | M |
| 1.14 | 입력 거부 처리 — 배너에 개수와 사유 요약 | S |

### 완료 조건

```text
AC-1.1 ~ AC-1.9   입력 전체
AC-2.1 ~ AC-2.6   탐색 전체
AC-12.1           트리·목록 스크롤이 대규모에서 끊기지 않음
AC-12.2           ZIP 해제·JSON 파싱이 UI 스레드에서 실행되지 않음
AC-12.3           진행률 스트리밍
AC-12.4           목록 가상 스크롤

[ ] Example Mode 3개를 넣으면 namespace 6개가 정확히 나온다
[ ] 파일명과 namespace 가 다른 경우가 정상 처리된다 (ExampleMultiNs.jar → 3개 namespace)
[ ] 악성 ZIP (경로 탈출 · 압축 폭탄) 이 거부된다
[ ] 입력 JAR 의 SHA-256 이 추가 전후로 동일하다
[ ] 대규모 입력 중 취소가 즉시 동작한다
```

### 테스트 게이트

```text
단위    ArchiveGuard · ResourcePathParser · LanguageCodeNormalizer · isSafeEntryPath
인프라  프로그램 생성 악성 ZIP · 정상 ZIP · Drift DAO
위젯    S1 · S2-A · 배너
통합    IT-1 (파일 추가 → 탐색 → 목록 표시)
```

### 위험

| 위험 | 대응 |
|---|---|
| Isolate 간 데이터 전달 비용이 예상보다 큼 | 원시 타입·`TransferableTypedData` 사용. 실측 후 조정 |
| 180개 JAR 탐색이 60초를 넘김 | 워커 풀 크기 조정 (`TECHNICAL.md` Q4). 필요 없는 항목 읽기 제거 확인 |
| 대소문자·경로 구분자 차이로 일부 JAR 탐색 실패 | Example Mode 픽스처에 해당 케이스 포함 |

---

## Phase 2 — JSON 구조와 변수 보호

> **이 Phase 가 제품의 안전 장치다.** 여기가 틀리면 게임이 깨진다.
> 실제 번역 API 를 붙이기 전에 완성한다. (`R3`)

**크기: L**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 2.1 | `JsonPrecheck` — 문법·최상위 Object·문자열 value·중복 key·빈 key·제어 문자·길이 (`TECHNICAL.md` 7.3) | M |
| 2.2 | namespace 단위 오류 격리 + S4 JSON 오류 안내 화면 | M |
| 2.3 | key 순서 보존 파싱 (`keyOrder`) + 중첩 Object/Array `unsupported structure` 판정 | M |
| 2.4 | `TokenPattern` — 9개 분기, 순서 포함 (`TECHNICAL.md` 5.1) | M |
| 2.5 | `TokenProtector` — 치환·복원, 자리표시자 잔존 감지 (`TECHNICAL.md` 5.2) | M |
| 2.6 | `MultisetValidator` (`TECHNICAL.md` 5.3) | S |
| 2.7 | `ExclusionPolicy` — 번역 제외 규칙 (`TECHNICAL.md` 5.4) | S |
| 2.8 | S2-B 대조 편집 뷰 — 상태 칩 · 변수 칩 · 판정문 (`DESIGN.md` 7.10) | L |
| 2.9 | S3 원본 언어 지정 화면 | M |
| 2.10 | 상태 필터 · 검색 | M |
| 2.11 | JSON 재구성 (`JsonRebuilder`) — 평탄 구조·원본 key 순서 보존 | M |

### 완료 조건

```text
AC-3.1 ~ AC-3.5   JSON 검사와 오류 격리
AC-4.1 ~ AC-4.6   원본 언어
AC-6.1 ~ AC-6.8   변수 보호와 검증
AC-7.6 ~ AC-7.7   검색 · 상태 필터

[ ] TokenPattern 단위 테스트 커버리지 100%
[ ] §x§F§F§A§A§0§0 이 토큰 1개로 인식된다 (7개로 쪼개지지 않음)
[ ] %1$s 가 %s 보다 먼저 매칭된다
[ ] %% 가 %s 로 오인되지 않는다
[ ] 치환 → 복원 왕복이 원문과 문자 단위로 동일하다 (Example Mode 전 항목)
[ ] 원문 %s×2 vs 번역 %s×1 %d×1 이 검증 실패로 판정된다
[ ] JSON 오류가 있는 namespace 를 제외한 나머지가 정상 표시된다
[ ] 재구성한 JSON 의 key 순서가 원본과 동일하다
```

### 테스트 게이트

```text
단위    TokenPattern (9분기 + 순서 3케이스) · TokenProtector · MultisetValidator
        ExclusionPolicy · JsonPrecheck · ResourcePathParser
        → domain 계층 커버리지 90% 이상
위젯    S2-B 목록 (상태 칩 · 변수 칩) · S3 · S4
```

### 위험

| 위험 | 대응 |
|---|---|
| 실제 모드에 예상 못 한 토큰 형태가 있음 | Example Mode 에 알려진 형태를 전부 넣고, 미지 형태는 Phase 7 코퍼스 검증에서 발견 |
| 표준 밖 중첩 JSON 이 입력됨 | 지원하지 않는 구조로 표시하고 해당 namespace 만 격리. 다른 namespace 작업은 계속 |

---

## Phase 3 — 번역 실행 (Gemini)

> 처음으로 외부 API 를 붙인다. **검증 장치가 이미 있으므로** 실패해도 안전하다.

**크기: XL**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 3.1 | `TranslationProvider` 인터페이스 + `AuthField` · `BatchLimits` (`TECHNICAL.md` 6.1) | M |
| 3.2 | `CredentialStore` — `flutter_secure_storage` 래핑 (`TECHNICAL.md` 9.2) | M |
| 3.3 | S2-C 작업 설정 패널 — 엔진 선택, 인증 필드 동적 렌더링, 마스킹, 발급 링크 | L |
| 3.4 | `GeminiProvider` — `gemini-3.6-flash` 기본, `gemini-3.5-flash-lite` 선택, `v1beta` REST 호출, 구조화 응답 스키마 확정, 프롬프트 (`TECHNICAL.md` 6.3) | L |
| 3.5 | 연결 테스트 (`verify`) + 연결 상태 칩 | S |
| 3.6 | `TranslationError` 분류 + 매핑 (`TECHNICAL.md` 6.5) | M |
| 3.7 | 지수 백오프 + 지터 + 시도 상한 | S |
| 3.8 | `TranslationRunner` — 대기열·배치·동시성·일시정지·재개·취소 (`TECHNICAL.md` 6.4) | L |
| 3.9 | 개수 불일치 시 배치 분할 재시도 | M |
| 3.10 | 실행 중 UI 잠금 (`EXPERIENCE.md` 6.4) | M |
| 3.11 | 실패 항목 재시도 · 원문 유지 액션 | M |
| 3.12 | 네트워크 단절 감지 → 자동 일시정지 | S |
| 3.13 | **자리표시자 실측** — Gemini 가 `⁣LF0⁣` 를 보존하는지 확인 (`TECHNICAL.md` Q1) | M |
| 3.14 | **배치 크기 실측** — 개수 불일치율·속도·품질 측정 후 확정 (`TECHNICAL.md` Q2) | M |

### 완료 조건

```text
AC-5.1 ~ AC-5.12  번역 실행 전체
AC-11.1 ~ AC-11.5 보안 전체

[ ] API 키 없이 번역 시작을 누르면 어느 필드가 비었는지 배너에 나온다
[ ] 연결 테스트가 실제 API 호출로 키를 검증한다
[ ] key 가 요청 본문에 포함되지 않는다 (요청 캡처로 확인)
[ ] API 키가 URL 이 아닌 헤더로 전달된다
[ ] 자리표시자가 응답에서 보존된다 (실측 통과율 기록)
[ ] 일시정지 → 재개가 이어서 진행된다
[ ] 429 응답에 지수 백오프로 재시도하고 5회 후 포기한다
[ ] 401 응답에 전체 대기열이 중단된다
[ ] 실행 중에도 탐색·검색·필터·탭 이동이 가능하고 UI 가 멈추지 않는다
[ ] 로그·프로젝트 파일에 API 키가 0건이다
```

### 테스트 게이트

```text
단위    TranslationError 매핑 · 백오프 계산 · 배치 구성
인프라  dio 어댑터 목으로 401/403/413/429/500/타임아웃 시나리오
        SensitiveFilter 가 각 제공자 키 형식을 마스킹
위젯    S2-C · 실행 중 잠금 상태
통합    IT-2 (목 제공자로 번역 실행 → 상태 전이)
        IT-8 (일시정지 → 재개 → 완주)
수동    실제 Gemini API 로 자리표시자 보존 실측 (3.13)
```

### 위험

| 위험 | 대응 |
|---|---|
| **Gemini 가 자리표시자를 변형함** | 3.13 을 Phase 시작 시점에 먼저 실행. 실패 시 대체 자리표시자 탐색을 3.13 안에서 해결하고 진행 |
| LLM 이 항목 개수를 안 맞춤 | 3.9 배치 분할 재시도. 최악의 경우 1개씩 요청 |
| 실측 없이 잡은 배치 크기 50 이 부적절 | 3.14 에서 확정 |
| API 비용이 개발 중에 누적 | Example Mode 로만 반복 테스트. 대규모 실행은 Phase 7 에서 1회 |

---

## Phase 4 — 편집과 병합

> 사용자가 손으로 고친 값이 절대 사라지지 않게 한다.

**크기: L**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 4.1 | `MergePolicy` — 6단계 우선순위 (`TECHNICAL.md` 7.1) | M |
| 4.2 | 기존 번역 분류 (`TECHNICAL.md` 7.2) | M |
| 4.3 | 인라인 편집 — 입력 즉시 반영, `confirm` 상태 전환 | M |
| 4.4 | 빈 값으로 되돌리면 `wait` 로 전환 | S |
| 4.5 | 빈 문자열 원문 → `empty` 고정, API 미전송 | S |
| 4.6 | 검증 실패 행의 `다시 시도` · `원문 유지` 액션 | M |
| 4.7 | 오래된 key (원본에 없음) 감지 및 출력 제외 | S |
| 4.8 | 후처리 파이프라인 (`TECHNICAL.md` 5.5) | M |

### 완료 조건

```text
AC-7.1 ~ AC-7.5   편집과 병합

[ ] MergePolicy 의 27가지 조합이 모두 단위 테스트로 검증된다 (후보 3개 x 없음·빈문자열·값있음)
[ ] 기존 ko_kr.json 값이 자동 번역으로 덮이지 않는다
[ ] 사용자가 수정한 값이 이후 번역 실행에서 유지된다
[ ] 원문이 빈 문자열인 항목이 API 로 전송되지 않는다
[ ] 후처리가 원문의 의미를 확장하지 않는다 (key 무변경 · 토큰 무변경)
```

### 테스트 게이트

```text
단위    MergePolicy 전수 · 기존 번역 분류 · 후처리
위젯    인라인 편집 · 상태 전환 · 재시도/원문유지 액션
```

---

## Phase 5 — 출력

> 게임이 실제로 인식하는 파일을 만든다.

**크기: L**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 5.1 | `ExportGate` — 차단 판정 (`TECHNICAL.md` 7.4) | M |
| 5.2 | S5 출력 전 검사 모달 — 집계, 정책 라디오, 판정문 | L |
| 5.3 | `JsonExporter` — 개별 JSON · 경로 보존 JSON | M |
| 5.4 | `PackMetaBuilder` — `mc_versions.json` 조회 | S |
| 5.5 | `ResourcePackExporter` — 폴더형 | M |
| 5.6 | `ZipExporter` — 통합 ZIP + 8.2절 구조 검증 | M |
| 5.7 | 원자적 쓰기 (임시 → 검증 → 이동) (`TECHNICAL.md` 8.5) | M |
| 5.8 | 덮어쓰기 확인 대화상자 + `.bak` 백업 | S |
| 5.9 | S2-B2 출력 구조 미리보기 뷰 | M |
| 5.10 | `ReportExporter` — `Translation_Report.md` (`TECHNICAL.md` 8.6) | M |
| 5.11 | 기본 `pack.png` 자산 제작 및 포함 | S |

### 완료 조건

```text
AC-9.1 ~ AC-9.14  출력 전체

[ ] ZIP 최상단에 pack.mcmeta 가 있다 (팩 이름 폴더 없음)
[ ] ZIP 경로 구분자가 전부 '/' 이다
[ ] 12개 Minecraft 버전 각각의 pack_format 이 정확하다
[ ] 출력 JSON 의 key 순서가 원본과 동일하다
[ ] 출력 실패 시 부분 생성 파일이 남지 않는다
[ ] 출력 구조 미리보기가 실제 결과와 일치한다
[ ] 보고서에 API 키가 0건이다
[ ] 검증 실패가 있으면 기본 정책으로 차단된다
```

### 테스트 게이트

```text
단위    ExportGate 조합 · PackMetaBuilder 12버전
인프라  ZipExporter 생성 후 verifyPackZip 재확인 · 원자적 쓰기 롤백
위젯    S5 (집계 · 정책 · 판정문 · 버튼 라벨 변화) · S2-B2
통합    IT-3 (검증 실패 → 차단) · IT-4 (정책 변경 → 출력 성공)
수동    출력한 ZIP 을 실제 Minecraft 에 넣어 인식 확인
```

### 위험

| 위험 | 대응 |
|---|---|
| Windows 에서 ZIP 경로 구분자가 `\` 가 됨 | 5.6 의 구조 검증에 명시적으로 포함. 단위 테스트로 고정 |
| pack_format 값이 틀림 | 5.4 를 데이터 파일로 분리하고 12개 전부 단위 테스트 |

---

## Phase 6 — 프로젝트 저장과 다중 모드

> 사용자 B 의 핵심 요구. "다시 하지 않는다" 를 구현한다.

**크기: L**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 6.1 | `.lfproj` 저장·열기 (`TECHNICAL.md` 3.1) | L |
| 6.2 | 자동 저장 — 일반 변경은 디바운스 2초, 번역은 완료·일시정지·취소·오류 중단 시 저장 + `Ctrl+S` 명시 저장 | M |
| 6.3 | `registry.db` — 최근 프로젝트 목록 | S |
| 6.4 | S0 시작 화면 | M |
| 6.5 | 입력 파일 존재·해시 재검사 + 변경/삭제 배너 | M |
| 6.6 | 스키마 버전 관리 + 마이그레이션 골격 + 백업 (`TECHNICAL.md` 3.5) | M |
| 6.7 | 충돌 감지 — 같은 ns + 같은 key + 다른 원문 (경고만) | M |
| 6.8 | JAR 체크박스 ↔ namespace 일괄 연동 | S |
| 6.9 | 파일 메뉴 전체 + 단축키 (`EXPERIENCE.md` S6 · 8절) | M |
| 6.10 | 프로젝트 닫기 · 번역 중 종료 확인 대화상자 (`EXPERIENCE.md` S9) | M |
| 6.11 | 크래시 복원 — 진행 중이던 배치를 `wait` 로 되돌림 | S |
| 6.12 | 첫 유효 JAR/ZIP 파일명에서 프로젝트 이름 생성·이름 편집 + 첫 저장 위치 선택 (`문서\LangForge Projects\` 기본) | M |

### 완료 조건

```text
AC-8.1 ~ AC-8.5   다중 모드와 충돌 (AC-8.6 은 1.0)
AC-10.1 ~ AC-10.9 프로젝트 저장 전체

[ ] 앱을 껐다 켜면 번역 상태·사용자 수정·namespace 선택·원본 예외가 100% 복원된다
[ ] 모드 3개를 추가하고 재실행하면 새 키만 대기 상태다
[ ] 프로젝트 파일에 API 키가 없다
[ ] 입력 파일을 삭제한 뒤 열면 배너로 알리고 해당 namespace 를 제외한다
[ ] 두 파일이 같은 namespace 의 같은 key 에 다른 원문을 가지면 충돌로 감지된다
[ ] 번역 중 창을 닫으려 하면 확인 대화상자가 뜨고, 완료된 항목은 저장된다
```

### 테스트 게이트

```text
단위    충돌 판별 로직
인프라  저장 → 열기 왕복 · 해시 변경 감지 · 마이그레이션 롤백
위젯    S0 · 확인 대화상자 · 파일 메뉴
통합    IT-5 (저장 → 재시작 → 복원) · IT-6 (JAR 추가 → 새 키만 대기)
```

---

## Phase 7 — MVP 마감

> 기능을 더하지 않는다. **`PRODUCT.md` 7절의 성공 기준을 실제로 통과시킨다.**

**크기: M**

### 작업

| # | 작업 | 크기 |
|---|---|---|
| 7.1 | 반응형 패널 접힘 (1024px · 768px 단계) (`DESIGN.md` 6.2) | M |
| 7.2 | 접근성 구현 (`TECHNICAL.md` 15절) — 시맨틱·포커스·모션 감소·텍스트 배율 | M |
| 7.3 | 디자인 검수 (`DESIGN.md` 14절 체크리스트) 전 화면 통과 | M |
| 7.4 | 성능 실측 및 예산 미달 항목 수정 (`TECHNICAL.md` 10.1) | L |
| 7.5 | 앱 아이콘 제작 및 적용 (`DESIGN.md` 12.1) | M |
| 7.6 | **검증용 실제 단일 모드 확정** — 사용자가 제공할 후보를 기록하고 Example Mode 3개와 함께 기능 검증 입력으로 고정 | S |
| 7.7 | 실제 단일 모드 + Example Mode 를 포함한 코퍼스 테스트 C-1 ~ C-8 작성 및 통과 | M |
| 7.8 | 실제 Minecraft 3개 버전(1.20.1 / 1.21.1 / 1.21.4)에서 U1 ~ U6 확인 | M |
| 7.9 | `README.md` · `THIRD_PARTY_LICENSES.md` 작성 | M |
| 7.10 | 포터블 ZIP 빌드 및 깨끗한 Windows 에서 실행 확인 | S |

### 완료 조건 — MVP 게이트

```text
기술 기준 (PRODUCT.md 7.1)
[ ] T2   namespace 탐색 누락 0건
[ ] T3   key 손실 0건
[ ] T4   key 변형 0건
[ ] T5   변수 멀티셋 불일치가 출력에 포함 0건
[ ] T6   기존 번역 손실 0건
[ ] T7   부분 실패 격리 — 나머지 100% 완주
[ ] T8   크래시·무한 대기 0건
[ ] T9   키 10,000개 30분 이내
[ ] T10  UI 프레임 드랍 없음
[ ] T11  API 키 노출 0건
[ ] T12  재실행 시 새 키만 번역 대기

실사용 기준 (PRODUCT.md 7.2)
[ ] U1   리소스팩이 게임 목록에 정상 표시
[ ] U2   인게임 텍스트가 한국어로 표시
[ ] U3   변수 포함 문자열이 게임에서 정상 동작
[ ] U4   § 색상 코드가 색으로 렌더링
[ ] U5   게임 로그에 리소스팩 오류 0건
[ ] U6   3개 버전에서 U1~U5 통과

전체 수용 조건
[ ] AC-1 ~ AC-12 의 MVP 범위 항목 전부 통과
```

**이 게이트를 통과해야 MVP 입니다.** 하나라도 실패하면 Phase 7 을 벗어나지 않습니다.

---

## Phase 8 — 번역 엔진 3종 추가 `[1.0]`

**크기: L** · Phase 9~11 과 독립

| # | 작업 | 크기 |
|---|---|---|
| 8.1 | 각 제공자의 현재 엔드포인트·인증 방식 확인 (`TECHNICAL.md` Q5) | S |
| 8.2 | `assets/data/providers.json` 으로 엔드포인트·모델 목록 외부화 | M |
| 8.3 | `DeepLProvider` (Free/Pro 엔드포인트 분기) | M |
| 8.4 | `GoogleProvider` (API Key 방식. 서비스 계정은 보류) | M |
| 8.5 | `PapagoProvider` (NCP 인증) | M |
| 8.6 | 제공자별 `BatchLimits` 실측 및 설정 | M |
| 8.7 | 제공자 전환 시 상태 초기화 규칙 | S |

**완료 조건**

```text
[ ] 4종 모두 연결 테스트가 동작한다
[ ] 4종 모두 오류 분류가 TranslationError 로 정확히 매핑된다
[ ] 제공자를 바꿔도 토큰 보호·검증·병합·출력 로직이 변경되지 않는다 (계획서 §3.3)
[ ] 각 제공자의 키 형식이 SensitiveFilter 로 마스킹된다
[ ] 엔드포인트가 소스가 아닌 데이터 파일에 있다
```

---

## Phase 9 — 캐시와 용어집 `[1.0]`

**크기: L**

| # | 작업 | 크기 |
|---|---|---|
| 9.1 | `cache.db` 스키마 — 캐시 키 8요소 (`계획서 §17.1`) | M |
| 9.2 | 캐시 조회 → `cache` 상태 적용 | M |
| 9.3 | 캐시 종류 분리 (자동/검수완료/사용자수정) | M |
| 9.4 | 캐시 적중률 표시 — **0건일 때 `—`, `NaN%` 금지** | S |
| 9.5 | `glossary.db` — 전역 · 프로젝트 용어집 | M |
| 9.6 | 용어집 적용 (번역 전) + 위반 시 `confirm` 표시 | M |
| 9.7 | S12 용어집 관리 화면 | L |
| 9.8 | `MergePolicy` 에 3·4단계(용어집·캐시) 활성화 | S |

**완료 조건**

```text
[ ] 같은 원문·같은 조건이면 API 를 호출하지 않는다
[ ] 캐시 키 8요소 중 하나라도 다르면 캐시가 적중하지 않는다
[ ] 항목 0개일 때 적중률이 '—' 로 표시된다
[ ] 용어집이 번역기 호출 전에 적용된다
[ ] MergePolicy 6단계 전체가 전수 테스트로 검증된다
```

---

## Phase 10 — 충돌 해결과 환경설정 `[1.0]`

**크기: L**

| # | 작업 | 크기 |
|---|---|---|
| 10.1 | S11 충돌 해결 모달 — 원문·번역 비교, 최종 선택 | L |
| 10.2 | 충돌 우선순위 설정 (`계획서 §21.3` 5단계) | M |
| 10.3 | S10 환경설정 — 일반 탭 (5개 토글) | M |
| 10.4 | S10 — 변수 보호 탭 (패턴 목록 + 멀티셋 예시) | M |
| 10.5 | S10 — 충돌 처리 탭 | S |
| 10.6 | S10 — 언어 프로필 탭 (코드 매핑 표) | M |
| 10.7 | 앱 내 로그 뷰어 | M |

**완료 조건**

```text
AC-8.6  충돌 해결 화면에서 최종 값을 선택할 수 있다

[ ] 자동 덮어쓰기가 여전히 금지된다
[ ] 미해결 충돌이 있으면 출력이 무조건 차단된다
[ ] 환경설정 4개 탭이 모두 동작한다
[ ] 토글 변경이 프로젝트에 저장된다
```

---

## Phase 11 — 출력·언어 확장 `[1.0]`

**크기: M**

| # | 작업 | 크기 |
|---|---|---|
| 11.1 | 대상 언어 6종 선택 UI | M |
| 11.2 | 모드별 개별 리소스팩 출력 | M |
| 11.3 | pack.png 4종 선택 — 기본/사용자 이미지/원본 모드 아이콘/없음 | M |
| 11.4 | pack.png 검증 (PNG · 정사각형 · 크기 · 손상) | S |
| 11.5 | JAR 내부 모드 아이콘 탐색 및 추출 | M |

**완료 조건**

```text
[ ] 출력 형식 4종이 모두 동작한다
[ ] 대상 언어를 바꾸면 출력 파일명·pack.mcmeta description 이 함께 바뀐다
[ ] pack.png 4종 선택이 모두 동작하고, 사용자 이미지가 검증된다
[ ] 원본 모드 아이콘 추출 실패 시 기본 아이콘으로 폴백한다
```

---

## Phase 12 — 1.0 마감 `[1.0]`

**크기: M**

| # | 작업 | 크기 |
|---|---|---|
| 12.1 | `PRODUCT.md` 8절 1.0 완료 기준 전수 확인 | M |
| 12.2 | MVP 기준(T2~T12 · U1~U6) 회귀 확인 | M |
| 12.3 | 골든(스크린샷) 테스트 도입 검토 (`TECHNICAL.md` 11.7) | M |
| 12.4 | 코드 서명 도입 여부 결정 (`TECHNICAL.md` Q7) | S |
| 12.5 | 릴리스 체크리스트 (`TECHNICAL.md` 14.3) 통과 | S |

---

## Phase 13 — 모바일 (Android) `[이후]`

**크기: XL**

목업(`LangForge Mobile`)이 설계 자산으로 존재합니다. 착수 전에 아래를 먼저 해결해야 합니다.

```text
선결 과제
├── Android SAF (Storage Access Framework) 로 파일 접근 — .minecraft 경로가 없음
├── 대용량 JAR 처리 시 메모리 제약 (데스크톱 1.5GB 예산을 못 씀)
├── 백그라운드 전환 시 번역 작업 유지 (Foreground Service 필요 여부)
├── 저장 공간 부족 처리
└── flutter_secure_storage 의 Android Keystore 동작 확인
```

| # | 작업 | 크기 |
|---|---|---|
| 13.1 | 선결 과제 조사 및 결정 | L |
| 13.2 | 하단 탭 4개 구조 (파일·편집·문제·출력) | L |
| 13.3 | Bottom Sheet 3종 (편집·원본 지정·설정) | L |
| 13.4 | 모바일 파일 접근 (SAF) | L |
| 13.5 | 메모리 제약 대응 — 스트리밍 강화, 배치 축소 | L |
| 13.6 | 터치 타깃 44px · 밀도 조정 (`DESIGN.md` 6.3) | M |
| 13.7 | 토스트 알림 | S |

---

## Phase 14 — macOS · Linux `[이후]`

**크기: M**

```text
[ ] flutter_secure_storage 가 macOS Keychain · Linux libsecret 에서 동작
[ ] 파일 선택·드롭이 각 플랫폼에서 동작
[ ] 창 최소 크기 제한이 동작
[ ] 폰트 렌더링이 Windows 와 크게 다르지 않음
[ ] 코퍼스 테스트가 각 플랫폼에서 통과
```

---

## 3. Example Mode 테스트 픽스처

Phase 0.14 에서 만들고, 이후 모든 Phase 의 테스트에 사용합니다.

`dart run "test_fixtures/Example Mode/generate.dart"` 로 세 JAR을 같은 바이트로 다시 생성할 수 있어야 합니다. 외부 압축 도구나 수동 편집은 사용하지 않습니다.

```text
test_fixtures/
└── Example Mode/
    ├── generate.dart                 아래 JAR 3개를 만드는 결정론적 Dart 스크립트
    ├── ExampleMultiNs-1.0.jar      정상 · 여러 namespace
    ├── ExampleLegacy-2.1.jar       원본 언어 없음 · 기존 번역 있음
    └── ExampleBroken-0.9.jar       JSON 문법 오류
```

**저작권 문제가 없습니다.** 직접 만든 파일이므로 저장소에 커밋하고 CI 에서도 실행합니다.

### 3.1 ExampleMultiNs-1.0.jar

파일명과 namespace 가 다르고, 하나의 JAR 에 namespace 가 3개인 경우를 재현합니다.

```text
assets/exalpha/lang/en_us.json      원본 · 기본 케이스
assets/exalpha/lang/ko_kr.json      기존 번역 일부 (병합 테스트용)
assets/exalpha/lang/ja_jp.json      다른 언어 (목록 표시 테스트용)
assets/exbeta/lang/en_us.json       원본만
assets/exgamma/lang/en_us.json      원본
assets/exgamma/lang/ko_kr.json      기존 번역
META-INF/MANIFEST.MF                실제 JAR 구조 재현
```

`en_us.json` 에 넣을 항목 — **모든 토큰 형태를 최소 1회씩 포함합니다.**

| key | 값 | 검증 목적 |
|---|---|---|
| `block.exalpha.oak_hedge` | `Oak Hedge` | 기본 |
| `item.exalpha.ancient_tome` | `Ancient Tome` | 기본 |
| `gui.exalpha.settings` | `Settings` | 짧은 UI 문자열 |
| `tooltip.exalpha.damage` | `Deals %1$.1f damage.` | 위치 지정 + 정밀도 |
| `death.exalpha.escape` | `%1$s died whilst trying to escape %2$s` | 위치 지정 2개 |
| `chat.exalpha.hit` | `%s hit %s for %d damage` | 일반 printf 3개, 종류 혼합 |
| `msg.exalpha.count` | `%02d items` | 폭 지정 |
| `msg.exalpha.percent` | `Progress: 50%% complete` | 이스케이프 퍼센트 |
| `msg.exalpha.newline` | `Line one\nLine two` | 줄바꿈 이스케이프 |
| `msg.exalpha.quote` | `He said \"hello\"` | 따옴표 이스케이프 |
| `msg.exalpha.backslash` | `Path: C:\\mods` | 역슬래시 이스케이프 |
| `msg.exalpha.color` | `§aReady§r` | 단일 서식 코드 |
| `msg.exalpha.hex` | `§x§F§F§A§A§0§0Ready to load§r` | **HEX 색상 — 토큰 1개로 인식되어야 함** |
| `msg.exalpha.brace` | `Module: {0} ({1})` | 단일 중괄호 |
| `msg.exalpha.named` | `Welcome, {name}!` | 이름 중괄호 |
| `msg.exalpha.double_brace` | `Welcome, {{name}}!` | 이중 중괄호 — 단일 중괄호보다 먼저 매칭 |
| `msg.exalpha.shell` | `Saved ${player} profile` | 셸 스타일 |
| `msg.exalpha.empty` | `` | 빈 문자열 → `empty` 고정 |
| `msg.exalpha.url` | `https://example.com/docs` | 번역 제외 |
| `msg.exalpha.resource` | `minecraft:stone` | 번역 제외 |
| `msg.exalpha.numeric` | `1.20.1` | 번역 제외 |
| `msg.exalpha.tokenonly` | `%s` | 토큰만 있는 값 |

`ko_kr.json` 에는 위 항목 중 **일부만** 넣어 병합·증분 번역을 테스트합니다. 그중 하나는 의도적으로 토큰 개수를 틀리게 넣어 `confirm` 판정을 확인합니다.

### 3.2 ExampleLegacy-2.1.jar

```text
assets/exlegacy/lang/en_gb.json     en_us 가 없음 → S3 원본 지정 화면 트리거
assets/exlegacy/lang/de_de.json     다른 기존 번역
assets/exlegacyok/lang/en_us.json   같은 JAR 안의 정상 namespace · 오류 격리 확인
```

`exlegacy` 값에는 영국식 철자(`Colour`, `Armour`)를 넣어 원본 언어 선택이 실제로 반영되는지 확인합니다. `exlegacyok` 를 더해 Example Mode 전체가 namespace 6개가 되며, 한 namespace 의 원본 부재가 같은 JAR 안의 정상 namespace 에 영향을 주지 않는지 확인합니다.

### 3.3 ExampleBroken-0.9.jar

```text
assets/exbroken/lang/en_us.json     문법 오류 (마지막 두 항목 사이 쉼표 누락)
```

이 파일 하나로 다음을 검증합니다.

```text
[ ] 오류 위치(줄 번호)가 정확히 표시된다
[ ] 이 namespace 가 대기열·출력에서 제외된다
[ ] 다른 두 JAR 의 처리가 100% 완주한다
```

### 3.4 추가 픽스처 (테스트 실행 중 생성)

저장소에 커밋하지 않고 테스트 코드가 프로그램으로 만듭니다.

```text
경로 탈출 ZIP        assets/../../../etc/passwd 항목 포함
절대 경로 ZIP        /etc/passwd 항목 포함
드라이브 경로 ZIP    C:/Windows/x 항목 포함
압축 폭탄 ZIP        압축률 1000:1 항목 포함
항목 과다 ZIP        200,000 항목
손상 ZIP             중앙 디렉터리 훼손
역슬래시 경로 ZIP    assets\quark\lang\en_us.json
대문자 경로 ZIP      Assets/Quark/Lang/en_us.json
```

악성 픽스처를 저장소에 커밋하면 보안 스캐너가 오탐하고 리뷰가 어렵습니다.

---

## 4. 의존 관계

```text
Phase 0 ──┬─→ Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5 ──→ Phase 6 ──→ Phase 7
          │                                                                              │
          └─→ (디자인 토큰 · Example Mode 픽스처는 모든 Phase 가 사용)                    │
                                                                                          ↓
                                        ┌───────────┬───────────┬───────────┐        MVP 게이트
                                        ↓           ↓           ↓           ↓             │
                                    Phase 8    Phase 9   Phase 10   Phase 11  ←───────────┘
                                        └───────────┴───────────┴───────────┘
                                                        ↓
                                                    Phase 12  →  1.0 게이트
                                                        ↓
                                                Phase 13 · Phase 14
```

**끊으면 안 되는 순서**

```text
Phase 2 → Phase 3    검증 장치 없이 번역을 붙이면 잘못된 결과를 검출할 수 없다
Phase 4 → Phase 5    병합 우선순위가 확정되지 않으면 무엇을 출력할지 정할 수 없다
Phase 5 → Phase 6    출력 형태가 정해져야 프로젝트에 무엇을 저장할지 알 수 있다
Phase 7 통과 → Phase 8+    MVP 게이트를 통과하지 않은 채 기능을 늘리지 않는다
```

**바꿔도 되는 순서**

```text
Phase 8 · 9 · 10 · 11 은 서로 독립. 필요에 따라 순서를 바꾼다.
```

---

## 5. Phase 완료 판정 절차

모든 Phase 에 동일하게 적용합니다.

```text
1. 해당 Phase 의 작업 항목이 전부 구현되었는가
2. 완료 조건의 AC 번호가 전부 통과하는가
3. 테스트 게이트의 모든 테스트가 통과하는가
4. flutter analyze 무경고 · dart format 통과
5. DESIGN.md 14절 검수 체크리스트가 새로 만든 화면에 대해 통과하는가
6. 새로 만든 코드에 하드코딩된 색·크기·간격이 없는가
7. 새로 만든 코드가 도메인 계층 순수성을 깨지 않았는가
8. 이전 Phase 의 완료 조건이 여전히 통과하는가 (회귀 확인)

하나라도 실패하면 Phase 는 완료가 아니다. 다음 Phase 로 넘어가지 않는다.
```

---

## 6. 위험 요약

Phase 를 넘나드는 위험만 모았습니다.

| # | 위험 | 영향 | 대응 | 확인 시점 |
|---|---|---|---|---|
| RK1 | Gemini 가 자리표시자를 보존하지 않음 | 번역 전체가 검증 실패 | Phase 3.13 을 Phase 3 최우선으로. 대체 자리표시자 후보 준비 | Phase 3 시작 |
| RK2 | 실제 모드에 예상 못 한 토큰 형태 존재 | 변수 깨짐 → 게임 오류 | Phase 7 코퍼스 검증에서 발견. 검증 실패로 걸러지므로 게임에는 나가지 않음 | Phase 7 |
| RK3 | 대규모 입력에서 성능 예산 미달 | 사용 불가 | Phase 1 에서 조기 실측. Phase 7 에서 최종 조정 | Phase 1 · 7 |
| RK4 | API 비용이 개발 중 누적 | 비용 | Example Mode 로만 반복 테스트. 대규모 실행은 Phase 7 에서 최소 횟수 | 상시 |
| RK5 | Flutter 데스크톱의 파일 드롭·창 제어 플러그인 불안정 | 기능 실패 | Phase 1 초반에 최소 예제로 검증. 실패 시 대안 플러그인 | Phase 1 초반 |
| RK6 | 폰트 전체 번들로 앱 용량 과다 | 배포 마찰 | Phase 0 첫 빌드에서 실측 | Phase 0 |
| RK7 | 벤더 API 스펙 변경 (엔드포인트·모델명) | 번역 실패 | 엔드포인트·모델을 데이터 파일로 외부화 (Phase 8.2). MVP 는 Gemini 하나만 노출 | Phase 8 |
| RK8 | 스키마 변경으로 기존 프로젝트 파일 손상 | 데이터 손실 | Phase 6.6 마이그레이션 골격 + 백업. 실패 시 롤백 | Phase 6 |

---

## 7. 열린 질문

| # | 질문 | 결정 시점 |
|---|---|---|
| Q2 | Phase 8~11 의 실제 진행 순서 | MVP 게이트 통과 후 |
| Q3 | Phase 13(모바일) 을 실제로 진행할 것인가 | 1.0 출시 후 사용자 반응 확인 |
| Q4 | 골든(스크린샷) 테스트를 1.0 에 넣을 것인가 | Phase 12 |
