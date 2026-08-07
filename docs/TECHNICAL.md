# TECHNICAL.md — LangForge

> 이 문서는 **어떻게 안전하게 구현할 것인가**를 정의합니다.
> 무엇을 만드는지는 `PRODUCT.md`, 흐름과 수용 조건은 `EXPERIENCE.md`, 시각 설계는 `DESIGN.md`, 순서는 `ROADMAP.md` 를 참조하세요.

- 문서 버전: 1.0
- 최종 수정: 2026-08-08
- 범위: **MVP (Windows 데스크톱)**. 1.0 및 모바일 항목은 `[1.0]` · `[모바일]` 로 표시
- 라이선스: **MIT**

---

## 1. 기술 스택

### 1.1 확정 스택

| 영역 | 선택 | 버전 | 근거 |
|---|---|---|---|
| 프레임워크 | Flutter | Dart SDK `^3.12.2` | 기존 프로젝트 유지. 데스크톱 → 모바일 확장 경로 확보 |
| 상태 관리 | `flutter_riverpod` | `^3.3.2` | 비동기 파이프라인이 앱의 핵심. `AsyncValue` 와 자동 폐기가 이 도메인과 맞음 |
| 코드 생성 | `riverpod_annotation` + `riverpod_generator` | `^4.0.3` / `^4.0.4` | 프로바이더 보일러플레이트 제거 |
| 로컬 DB | `drift` + `drift_flutter` | `^2.34.3` / `^0.3.1` | 항목 수만 개에 대한 인덱스·페이지네이션·타입 안전 쿼리 |
| DB 코드 생성 | `drift_dev` | `^2.34.0` | |
| 보안 저장소 | `flutter_secure_storage` | `^10.3.1` | Windows Credential Manager 추상화. 모바일 확장 시 그대로 사용 |
| 압축 처리 | `archive` | `^4.0.9` | 스트리밍 ZIP 읽기 지원 |
| HTTP | `dio` | `^5.11.0` | 인터셉터·취소 토큰·재시도 제어 |
| 파일 선택 | `file_picker` | `^11.0.3` | JAR/ZIP 다중 선택 + 폴더 선택 |
| 드래그 앤 드롭 | `desktop_drop` | `^0.7.1` | 데스크톱 드롭 대상 |
| 창 제어 | `window_manager` | `^0.5.2` | 최소 크기 제한, 종료 가로채기 |
| 아이콘 | `lucide_icons_flutter` | `^3.1.15` | `DESIGN.md` 8절 |
| 경로 | `path` / `path_provider` | `^1.9.1` / `^2.1.6` | |
| 해시 | `crypto` | `^3.0.7` | SHA-256 |
| 식별자 | `uuid` | `^4.6.0` | 행 id (uuid v4). 3.2 의 모든 테이블 기본 키 |
| 유니코드 정규화 | `unorm_dart` | `^0.3.2` | 5.5 후처리의 NFC 단계. Dart 표준에 정규화가 없음 |
| 불변 모델 | `freezed_annotation` + `json_serializable` | `^3.1.0` / `^6.14.1` | 생성기 `freezed` 는 아래 주석 참조 |
| 로깅 | `logging` | `^1.3.0` | |
| 링크 열기 | `url_launcher` | `^6.3.2` | API 키 발급 페이지 |
| 앱 정보 | `package_info_plus` | `^9.0.1` | 버전 표시, 보고서 헤더 |
| 정적 분석 | `flutter_lints` | `^6.0.0` | |
| 코드 생성 실행기 | `build_runner` | `^2.15.1` | |
| 테스트 목 | `mocktail` | `^1.0.5` | |

**버전 상한을 만드는 제약** (2026-08-07 실측. 갱신 시 재확인)

```text
file_picker 11.0.3 이 win32 ^5.9 를 고정한다.
  → flutter_secure_storage 11.x · package_info_plus 10.x 는 win32 ^6 을 요구하므로 함께 쓸 수 없다.
  → file_picker 12 는 아직 beta 다. MVP 는 secure_storage 10.3.1 · package_info_plus 9.0.1 로 간다.

drift_dev 2.34.x 는 analyzer ^12 를, freezed 3.2.5 는 analyzer >=9 <11 을 요구한다.
  → 생성기 freezed 는 아직 넣지 않는다. freezed_annotation 만 선언해 두고,
     실제 모델을 만드는 Phase 2 에서 그 시점의 호환 조합을 다시 고른다.

build_runner 2.15.2 이상은 analyzer 가 meta ^1.18.3 을 끌어오는데
  Flutter SDK 가 meta 1.18.0 을 고정한다. → 2.15.1 이 상한이다.
```

**`unorm_dart` 를 쓰는 이유**

```text
Dart 표준 라이브러리에 유니코드 정규화가 없다. dart:core · intl · characters
어디에도 NFC 구현이 없어서 5.5 의 5단계를 자체 구현하거나 패키지를 쓰는 수밖에 없다.

unorm_dart 0.3.2 는 Unicode 17.0 데이터를 반영하고 Dart 3.9 를 지원한다.
순수 Dart 이고 전이 의존성이 없다. 1.2 의 '미갱신 패키지 배제' 기준에 걸리지 않는다.

domain 은 외부 패키지를 import 하지 않으므로(2.1) 이 패키지를 직접 쓰지 않는다.
  domain/normalize/text_normalizer.dart          TextNormalizer 인터페이스
  infrastructure/normalize/unicode_text_normalizer.dart   unorm_dart 구현
TextPostProcessor 는 인터페이스만 받고, 기본값은 아무것도 하지 않는 구현이다.
```

### 1.2 의도적으로 쓰지 않는 것

| 후보 | 쓰지 않는 이유 |
|---|---|
| `google_generative_ai` | pub.dev 에서 **unlisted** 상태이며 2025-04 이후 갱신 없음. Google 이 표준 Dart SDK 를 사실상 중단함 |
| 벤더별 번역 SDK 전반 | 계획서 §3.3 의 "번역 API 를 바꿔도 파일 처리는 영향받지 않는다" 원칙과 충돌. 4개 SDK 를 쓰면 어댑터 인터페이스가 벤더 모델에 오염됨 |
| `sqlite3_flutter_libs` 직접 의존 | `0.6.0+eol` 로 수명 종료. `drift_flutter` 가 내부에서 처리하므로 직접 선언하지 않음 |
| Firebase 계열 전체 | 서버·계정 없는 로컬 도구 |
| 자동 오류 리포팅 (Sentry 등) | 텔레메트리 미수집 정책 |
| `golden_toolkit` | 2023-02 이후 미갱신. 골든 테스트가 필요해지면 `alchemist` 또는 Flutter 내장 `matchesGoldenFile` 사용 |

**번역 어댑터는 4종 모두 `dio` 기반 직접 REST 호출로 구현합니다.** 인터페이스가 대칭이 되고, 벤더가 SDK 를 중단해도 영향받지 않습니다.

---

## 2. 아키텍처

### 2.1 레이어

```text
┌──────────────────────────────────────────────────────────┐
│  presentation                                            │
│  화면 · 위젯 · 디자인 시스템                              │
│  Riverpod 을 통해서만 아래 계층에 접근                     │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│  application                                             │
│  유스케이스 · 오케스트레이션 · 상태 프로바이더             │
│  ProjectController · ScanController · TranslationRunner   │
│  ExportController                                        │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│  domain                                                  │
│  순수 Dart. Flutter · IO · 패키지 의존 없음               │
│  엔티티 · 값 객체 · 정책 · 검증 규칙                       │
│  TokenProtector · MultisetValidator · MergePolicy         │
│  LanguageCodeNormalizer · ResourcePathParser              │
└───────────────────────┬──────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│  infrastructure                                          │
│  Drift DB · 파일 시스템 · 압축 · HTTP · 보안 저장소        │
│  Isolate 워커 · 번역 어댑터 구현                          │
└──────────────────────────────────────────────────────────┘
```

**의존 방향은 위에서 아래로만 흐릅니다.** `domain` 은 다른 어떤 계층도 참조하지 않습니다. 이것이 `domain` 을 순수 단위 테스트로 100% 검증 가능하게 만드는 핵심입니다.

### 2.2 디렉터리

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                    루트 위젯 · 라우팅
│   ├── theme/                      DESIGN.md 토큰 (ThemeExtension)
│   └── bootstrap.dart              초기화 · 에러 존 · 로거 설정
│
├── domain/                         순수 Dart. import 'dart:io' 금지
│   ├── model/
│   │   ├── project.dart
│   │   ├── input_file.dart
│   │   ├── namespace_unit.dart
│   │   ├── language_file.dart
│   │   ├── translation_entry.dart
│   │   ├── entry_status.dart
│   │   ├── validation_result.dart
│   │   ├── conflict.dart
│   │   └── language_profile.dart
│   ├── protection/
│   │   ├── token_protector.dart    토큰 치환 · 복원
│   │   ├── token_pattern.dart      정규식 정의
│   │   └── multiset.dart           멀티셋 비교
│   ├── policy/
│   │   ├── merge_policy.dart       병합 우선순위
│   │   ├── exclusion_policy.dart   번역 제외 규칙
│   │   └── export_gate.dart        출력 차단 판정
│   ├── normalize/
│   │   ├── language_code.dart      ko-KR → ko_kr
│   │   ├── resource_path.dart      assets/*/lang/*.json 파싱
│   │   ├── text_normalizer.dart    NFC 인터페이스 (구현은 infrastructure)
│   │   └── text_post_processor.dart  5.5 후처리
│   └── validation/
│       ├── json_precheck.dart
│       ├── entry_validator.dart
│       └── export_validator.dart
│
├── application/
│   ├── project/
│   ├── scan/
│   ├── translation/
│   ├── export/
│   └── settings/
│
├── infrastructure/
│   ├── db/
│   │   ├── app_database.dart       Drift 정의 (프로젝트 · glossary_terms)
│   │   ├── cache_database.dart     전역 cache.db               [1.0]
│   │   ├── glossary_database.dart  전역 glossary.db            [1.0]
│   │   ├── registry_database.dart
│   │   ├── tables/
│   │   ├── daos/
│   │   └── migrations/
│   ├── archive/
│   │   ├── archive_reader.dart
│   │   ├── directory_reader.dart
│   │   └── archive_guard.dart      zip slip · zip bomb 방어
│   ├── isolate/
│   │   ├── worker_pool.dart
│   │   ├── scan_worker.dart
│   │   └── messages.dart
│   ├── translation/
│   │   ├── translation_provider.dart      인터페이스
│   │   ├── gemini_provider.dart           MVP
│   │   ├── deepl_provider.dart            [1.0]
│   │   ├── google_provider.dart           [1.0]
│   │   ├── papago_provider.dart           [1.0]
│   │   └── provider_registry.dart
│   ├── normalize/
│   │   └── unicode_text_normalizer.dart   unorm_dart 기반 NFC
│   ├── security/
│   │   ├── credential_store.dart
│   │   └── sensitive_filter.dart          로그 마스킹
│   ├── export/
│   │   ├── pack_icon_loader.dart           기본/사용자 pack.png
│   │   ├── json_exporter.dart
│   │   ├── resource_pack_exporter.dart
│   │   ├── zip_exporter.dart
│   │   ├── pack_meta_builder.dart
│   │   └── report_exporter.dart
│   └── logging/
│       └── file_logger.dart
│
└── presentation/
    ├── start/                      S0
    ├── empty/                      S1
    ├── editor/                     S2 · S3 · S4
    │   ├── explorer/               S2-A
    │   ├── entries/                S2-B
    │   └── settings_panel/         S2-C
    ├── precheck/                   S5
    ├── common/                     LfButton · LfStatusChip 등
    └── shell/                      상단 바 · 상태 바 · 배너 · 확인 대화상자

assets/
├── fonts/
├── icons/
├── pack/
└── data/
    ├── mc_versions.json
    └── language_profiles.json

test/
├── domain/                         순수 단위 테스트
├── infrastructure/
├── widget/
└── corpus/                         @Tags(['corpus']) — 로컬 전용

integration_test/
```

### 2.3 모듈 책임

| 모듈 | 책임 | 하지 않는 것 |
|---|---|---|
| `ArchiveReader` | 압축 항목 열거·추출 | 경로 의미 해석, JSON 파싱 |
| `ArchiveGuard` | 경로 탈출·압축 폭탄·크기 검사 | 추출 |
| `ResourcePathParser` | `assets/{ns}/lang/{code}.json` 파싱 | 파일 읽기 |
| `LanguageCodeNormalizer` | 언어 코드 정규화 | 언어 프로필 조회 |
| `JsonPrecheck` | 문법·구조·중복 검사 | 오류 복구, 파일 수정 |
| `TokenProtector` | 토큰 치환·복원 | 검증 판정 |
| `MultisetValidator` | 토큰 멀티셋 비교 | 치환·복원 |
| `MergePolicy` | 우선순위에 따른 최종 값 결정 | 저장 |
| `ExistingTranslationClassifier` | 입력 파일의 기존 번역을 7.2 표로 분류 | 번역, 저장 |
| `TextPostProcessor` | 5.5 의 2~6단계 정리 | 토큰 판정, 검증 |
| `TextNormalizer` | 유니코드 NFC 정규화 | 그 외 문자열 가공 |
| `TranslationProvider` | 문자열 목록 → 번역된 문자열 목록 | 토큰 보호, 검증, 병합, 상태 관리 |
| `TranslationRunner` | 대기열·동시성·재시도·일시정지 | 번역 자체, 파일 IO |
| `ExportGate` | 출력 차단 여부 판정 | 파일 쓰기 |
| `ZipExporter` | ZIP 구조 생성 | 어떤 항목을 넣을지 결정 |
| `CredentialStore` | 키 저장·조회·삭제 | 키 검증 |
| `SensitiveFilter` | 로그·보고서에서 민감값 제거 | 로그 기록 |

각 모듈은 하나의 책임만 가집니다. 계획서 §28 의 모듈 분리 원칙을 그대로 따릅니다.

---

## 3. 데이터 모델

### 3.1 저장 위치

```text
%APPDATA%\LangForge\
├── registry.db                     최근 프로젝트 목록
├── settings.json                   UI 설정 · 기본 언어 · 기본 엔진
├── cache.db                        전역 번역 캐시            [1.0]
├── glossary.db                     전역 용어집               [1.0]
└── logs/
    ├── langforge.log
    ├── langforge.1.log
    └── ...                         최대 5개 회전

사용자 지정 위치 (첫 저장 대화상자의 기본 진입 위치: 문서\LangForge Projects\)
└── MyPack.lfproj                   프로젝트 1개 = SQLite 파일 1개

Windows Credential Manager
└── LangForge/{providerId}/{fieldId}   API 인증 정보
```

**프로젝트 파일은 단일 SQLite 파일(`.lfproj`)입니다.** 복사·백업·이동이 파일 하나로 끝납니다. 원본 JAR 사본은 넣지 않고 경로와 해시만 저장합니다.

첫 저장은 항상 위치 선택 대화상자를 엽니다. `문서\LangForge Projects\` 는 사용자가 위치를 확정한 뒤에만 필요 시 생성하며, 선택 없이 폴더를 미리 만들지 않습니다. 첫 번째로 추가된 유효한 JAR/ZIP의 확장자를 뺀 파일명을 `ProjectMeta.name` 으로 사용하고 이후 이름 편집을 허용합니다.

### 3.2 Drift 스키마 (프로젝트 DB)

```dart
// meta ─ 프로젝트 자체 설정. 항상 1행.
class ProjectMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get schemaVersion => text()();
  TextColumn get appVersion => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get sourceLangCode => text().withDefault(const Constant('en_us'))();
  TextColumn get targetLangCode => text().withDefault(const Constant('ko_kr'))();
  TextColumn get providerId => text().nullable()();
  TextColumn get modelId => text().nullable()();
  TextColumn get outputFormat => text().withDefault(const Constant('pack_zip'))();
  TextColumn get mcVersion => text().withDefault(const Constant('1.20.1'))();
  TextColumn get packIconMode => text().withDefault(const Constant('default'))();
  TextColumn get packIconPath => text().nullable()();
  TextColumn get conflictPriority => text().withDefault(const Constant('manual'))();
  TextColumn get togglesJson => text().withDefault(const Constant('{}'))();

  @override Set<Column> get primaryKey => {id};
}

// input_files ─ 사용자가 추가한 JAR · ZIP · 폴더
class InputFiles extends Table {
  TextColumn get id => text()();                    // uuid v4
  TextColumn get originalName => text()();
  TextColumn get absolutePath => text()();
  TextColumn get kind => text()();                  // jar | zip | directory
  IntColumn  get sizeBytes => integer()();
  TextColumn get sha256 => text()();
  DateTimeColumn get addedAt => dateTime()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get scanState => text()();             // pending | ok | rejected | missing | changed
  TextColumn get rejectReason => text().nullable()();

  @override Set<Column> get primaryKey => {id};
}

// namespaces ─ assets/{name}/lang 하나
class Namespaces extends Table {
  TextColumn get id => text()();
  TextColumn get inputFileId => text().references(InputFiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();                  // quark, zeta, emi
  TextColumn get state => text()();                 // ok | no_source | json_error | conflicted | excluded | done
  TextColumn get sourceOverride => text().nullable()();
  BoolColumn get excluded => boolean().withDefault(const Constant(false))();
  BoolColumn get selected => boolean().withDefault(const Constant(true))();
  IntColumn  get keyCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  IntColumn  get errorLine => integer().nullable()();

  @override Set<Column> get primaryKey => {id};
}

// language_files ─ namespace 안에서 발견된 언어 파일
class LanguageFiles extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceId => text().references(Namespaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get rawCode => text()();               // 파일명 그대로 (en_US)
  TextColumn get code => text()();                  // 정규화 결과 (en_us)
  TextColumn get entryPath => text()();             // assets/quark/lang/en_us.json
  IntColumn  get keyCount => integer()();
  TextColumn get role => text()();                  // source | existing_target | other

  @override Set<Column> get primaryKey => {id};
}

// entries ─ 번역 항목. 최대 규모 테이블 (수만 행)
class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceId => text().references(Namespaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get keyCategory => text().nullable()(); // block | item | gui | tooltip | ...
  IntColumn  get keyOrder => integer()();            // 원본 JSON 의 key 순서 보존

  TextColumn get sourceText => text()();
  TextColumn get existingTranslation => text().nullable()();
  TextColumn get newTranslation => text().nullable()();
  TextColumn get userTranslation => text().nullable()();

  TextColumn get status => text()();                 // EntryStatus
  TextColumn get providerId => text().nullable()();
  TextColumn get modelId => text().nullable()();
  BoolColumn get userEdited => boolean().withDefault(const Constant(false))();
  TextColumn get validationJson => text().nullable()();
  TextColumn get warningsJson => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
}

// conflicts ─ 같은 namespace + 같은 key + 다른 원문
class Conflicts extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceName => text()();
  TextColumn get key => text()();
  TextColumn get participantsJson => text()();       // [{inputFileId, sourceText, translation}]
  TextColumn get resolvedEntryId => text().nullable()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();

  @override Set<Column> get primaryKey => {id};
}

// export_records ─ 출력 이력
class ExportRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get format => text()();
  TextColumn get outputPath => text()();
  IntColumn  get namespaceCount => integer()();
  IntColumn  get entryCount => integer()();
  TextColumn get reportPath => text().nullable()();

  @override Set<Column> get primaryKey => {id};
}

// glossary_terms ─ 프로젝트 용어집                          [1.0]
// 전역 glossary.db 와 동일 컬럼. 같은 (sourceTerm, 언어쌍, namespace) 충돌 시
// 프로젝트 행이 전역을 덮는다. 7.5절 참조.
class GlossaryTerms extends Table {
  TextColumn get id => text()();
  TextColumn get sourceTerm => text()();
  TextColumn get targetTerm => text()();
  TextColumn get sourceLang => text()();              // 정규화 내부 코드 (en_us)
  TextColumn get targetLang => text()();
  TextColumn get namespace => text().nullable()();    // null = 전체
  BoolColumn get caseSensitive => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override Set<Column> get primaryKey => {id};
}
```

### 3.2a Drift 스키마 (전역 DB) `[1.0]`

`%APPDATA%\LangForge\cache.db` 와 `glossary.db`. 프로젝트와 수명이 분리된다.

```dart
// cache.db ─ 전역 번역 캐시. 키 8요소는 7.5절.
enum CacheKind { auto, reviewed, userEdited }

class CacheEntries extends Table {
  // ── 캐시 키 8요소 (복합 유니크. kind 는 키에 포함하지 않음) ──
  TextColumn get sourceHash => text()();             // SHA-256(원문, 치환 전)
  TextColumn get sourceLangCode => text()();
  TextColumn get targetLangCode => text()();
  TextColumn get providerId => text()();
  TextColumn get modelId => text()();                // 없으면 ""
  TextColumn get glossaryFingerprint => text()();    // 적용 대상 용어만의 SHA-256
  TextColumn get protectorVersion => text()();
  TextColumn get postProcessorVersion => text()();

  // ── 값 ──
  TextColumn get kind => text()();                   // CacheKind wire name
  TextColumn get translation => text()();
  TextColumn get sourceText => text()();             // 디버그용. 키에는 쓰지 않음
  DateTimeColumn get updatedAt => dateTime()();

  // 같은 8요소에 kind 가 여러 개일 수 있다 (auto · reviewed · userEdited).
  @override Set<Column> get primaryKey => {
    sourceHash, sourceLangCode, targetLangCode, providerId, modelId,
    glossaryFingerprint, protectorVersion, postProcessorVersion, kind,
  };
}

// glossary.db ─ 전역 용어집. 프로젝트 GlossaryTerms 와 동일 컬럼.
class GlossaryTerms extends Table { /* 3.2 와 동일 */ }
```

```sql
-- cache.db
CREATE UNIQUE INDEX idx_cache_key8 ON cache_entries(
  source_hash, source_lang_code, target_lang_code, provider_id, model_id,
  glossary_fingerprint, protector_version, post_processor_version, kind
);
CREATE INDEX idx_cache_lookup ON cache_entries(
  source_hash, source_lang_code, target_lang_code, provider_id, model_id,
  glossary_fingerprint, protector_version, post_processor_version
);

-- glossary.db · 프로젝트 glossary_terms
CREATE INDEX idx_glossary_lang ON glossary_terms(source_lang, target_lang);
CREATE INDEX idx_glossary_ns   ON glossary_terms(namespace);
```

### 3.3 인덱스

수만 행에서 필터·검색이 즉시 반응해야 합니다.

```sql
CREATE UNIQUE INDEX idx_entries_ns_key   ON entries(namespace_id, key);
CREATE        INDEX idx_entries_status   ON entries(namespace_id, status);
CREATE        INDEX idx_entries_order    ON entries(namespace_id, key_order);
CREATE        INDEX idx_entries_edited   ON entries(user_edited) WHERE user_edited = 1;
CREATE        INDEX idx_ns_input         ON namespaces(input_file_id);
CREATE        INDEX idx_ns_name          ON namespaces(name);
CREATE        INDEX idx_langfile_ns      ON language_files(namespace_id);
CREATE UNIQUE INDEX idx_input_hash       ON input_files(sha256);
```

**검색은 `LIKE` 로 시작합니다.** 실측에서 부족하면 FTS5 가상 테이블(`key`, `source_text`)을 추가합니다. 조기 최적화하지 않습니다.

### 3.4 상태 열거형

```dart
enum EntryStatus {
  wait,       // 대기
  running,    // 번역 중
  done,       // 새 번역
  kept,       // 기존 번역 유지
  cache,      // 캐시 재사용            [1.0]
  invalid,    // 검증 실패
  fallback,   // 원문 유지
  confirm,    // 확인 필요
  empty,      // 빈 문자열 유지
}

enum NamespaceState { ok, noSource, jsonError, conflicted, excluded, done }
enum ScanState { pending, ok, rejected, missing, changed }

// 충돌 우선순위 (10.2 · 10.5). ProjectMeta.conflictPriority 에 wire name 으로 저장.
enum ConflictPriority {
  manual,              // 항상 수동 선택. 기본값
  preferFirstAdded,    // 먼저 추가된 JAR 의 원문
  preferLastAdded,     // 나중에 추가된 JAR 의 원문
  preferLongerSource,  // 원문이 더 긴 쪽
  preferShorterSource, // 원문이 더 짧은 쪽
}
```

`manual` 외 네 단계는 **미리선택만** 합니다. 충돌 목록을 열었을 때 후보 하나가 이미 선택된 상태로 보이는 것이 전부이고, `Conflicts.resolved` 는 사용자가 S11 에서 확인 버튼을 누른 뒤에만 `true` 가 됩니다. 미해결 충돌이 남아 있으면 출력은 계속 차단됩니다 (AC-8.5 · 8.6).

동점 처리: `preferLongerSource` · `preferShorterSource` 는 길이(Dart `String.length`, UTF-16 코드 단위)가 같으면 `preferFirstAdded` 로 떨어집니다. `preferFirstAdded` · `preferLastAdded` 의 순서 기준은 `InputFiles.addedAt` 이며, 같으면 `InputFiles.id` 사전순입니다. 미리선택은 결정론적이어야 합니다.

**`ProjectMeta.togglesJson` 키 (10.3)**

```jsonc
{
  "autoSave": true,          // 자동 저장
  "verboseLog": false,       // 상세 로그 (FINE). 앱 내 로그 뷰어와 연동
  "notifyOnComplete": true,  // 번역 완료 시 소리·알림
  "keepOnRescan": true,      // 재탐색 시 기존 번역 유지 — AC-10.7
  "allowSkipChecks": false   // 출력 전 검사 건너뛰기 허용 — E3
}
```

키가 없으면 위 기본값을 씁니다. 알 수 없는 키는 읽을 때 무시하되 다시 쓸 때 보존합니다 — 구버전 앱이 신버전 프로젝트의 설정을 지우지 않게 합니다.

DB 에는 문자열로 저장합니다. 정수 인덱스는 열거형 순서가 바뀌면 데이터가 깨집니다.

`NamespaceState.done` 은 하위 항목이 모두 번역 처리를 마친 경우입니다. 즉 `wait`·`running`·`invalid`·승인 전 `confirm` 항목이 하나도 없고, 모든 항목이 `done`·`kept`·`cache`·`fallback`·`empty` 중 하나일 때 전이합니다. 재탐색으로 새 `wait` 항목이 생기면 `ok` 로 돌아가며 기존 완료 항목의 상태는 바꾸지 않습니다.

### 3.5 마이그레이션

```text
schemaVersion 을 ProjectMeta 에 기록한다.
Drift 의 스키마 버전과 함께 이중으로 관리한다.

앱 버전 < 프로젝트 스키마 버전
  → 열기를 거부하고 "더 새 버전의 LangForge 로 만든 프로젝트입니다" 안내

앱 버전 > 프로젝트 스키마 버전
  → 열기 전에 백업본(.lfproj.bak)을 만들고 마이그레이션 실행
  → 마이그레이션 실패 시 백업본으로 롤백하고 열기 거부

MVP 는 v1 하나만 존재하지만 이 골격은 처음부터 넣는다.
```

### 3.6 정적 데이터

프로그램 로직에서 분리하여 JSON 자산으로 관리합니다. 계획서 §24.2 의 요구입니다.

**`assets/data/mc_versions.json`**

```json
[
  { "version": "1.21.4", "packFormat": 46, "minFormat": 46, "maxFormat": 46 },
  { "version": "1.21.3", "packFormat": 42, "minFormat": 42, "maxFormat": 42 },
  { "version": "1.21.2", "packFormat": 42, "minFormat": 42, "maxFormat": 42 },
  { "version": "1.21.1", "packFormat": 34, "minFormat": 34, "maxFormat": 34 },
  { "version": "1.21",   "packFormat": 34, "minFormat": 34, "maxFormat": 34 },
  { "version": "1.20.6", "packFormat": 32, "minFormat": 32, "maxFormat": 32 },
  { "version": "1.20.4", "packFormat": 22, "minFormat": 22, "maxFormat": 22 },
  { "version": "1.20.2", "packFormat": 18, "minFormat": 18, "maxFormat": 18 },
  { "version": "1.20.1", "packFormat": 15, "minFormat": 15, "maxFormat": 15 },
  { "version": "1.19.4", "packFormat": 13, "minFormat": 13, "maxFormat": 13 },
  { "version": "1.19.2", "packFormat":  9, "minFormat":  9, "maxFormat":  9 },
  { "version": "1.18.2", "packFormat":  8, "minFormat":  8, "maxFormat":  8 }
]
```

`1.21.x` 처럼 묶지 않고 정확한 버전만 나열합니다. 새 Minecraft 버전이 나오면 이 파일만 갱신합니다.

**`assets/data/language_profiles.json`**

```json
[
  {
    "displayName": "한국어",
    "mc": "ko_kr",
    "outputFile": "ko_kr.json",
    "codes": { "google": "ko", "papago": "ko", "deepl": "KO", "gemini": "Korean" },
    "aliases": ["ko-KR", "KO_KR", "Korean", "한국어", "ko"]
  }
]
```

`aliases` 가 언어 코드 정규화의 입력이 됩니다.

수록 언어는 6종입니다 — `ko_kr` · `en_us` · `en_gb` · `ja_jp` · `de_de` · `fr_fr`. 대상 언어 선택 UI (ROADMAP 11.1) 는 이 파일을 그대로 읽습니다. 언어를 늘리려면 이 파일에 항목을 추가하면 되고, 코드 변경은 필요 없습니다.

---

## 4. 처리 파이프라인

### 4.1 전체 흐름

```text
입력 추가
   ↓  [Isolate 풀]
안전 검사 (확장자 · 크기 · 해시 · 손상 · 중복)
   ↓  [Isolate 풀]
압축 항목 열거 → assets/*/lang/*.json 필터
   ↓  [Isolate 풀]
namespace · 언어 파일 목록 생성
   ↓  [Isolate 풀]
원본 언어 파일 JSON 사전 검사 + 파싱
   ↓  [Isolate 풀]
기존 대상 언어 파일 파싱 (있으면)
   ↓  [메인]
Entry 생성 + 병합 우선순위 적용 → DB 일괄 삽입
   ↓  [메인]
충돌 감지 (같은 ns + 같은 key + 다른 원문)
   ↓  ─────── 사용자가 번역 시작 ───────
전처리 (제외 규칙 · 토큰 보호 · 배치 구성)
   ↓  [메인 · 비동기 IO]
번역 API 호출 (동시성 제한 + 재시도)
   ↓  [메인]
후처리 (토큰 복원 · 공백 정리 · 정규화)
   ↓  [메인]
검증 (멀티셋 · 빈 값 · 제어 문자)
   ↓  [메인]
DB 갱신 → UI 스트림
   ↓  ─────── 사용자가 내보내기 ───────
출력 전 검사 (집계 · 차단 판정)
   ↓  [Isolate]
JSON 재구성 → 파일 · 리소스팩 · ZIP 생성
   ↓  [Isolate]
보고서 생성
```

### 4.2 Isolate 워커 풀

```dart
class WorkerPool {
  // 코어 수와 4 중 작은 값. IO 바운드가 섞여 있어 과다 생성은 역효과.
  static int get size => math.min(Platform.numberOfProcessors, 4);
}
```

| 규칙 | 내용 |
|---|---|
| UI 스레드 금지 작업 | ZIP 해제, JSON 파싱, SHA-256 계산, ZIP 생성 |
| 전달 방식 | 파일 경로와 원시 결과만 주고받음. Drift 객체·위젯 참조를 넘기지 않음 |
| 진행 보고 | `SendPort` 로 스트리밍. 최소 100ms 간격으로 스로틀 |
| 취소 | 취소 토큰을 주기적으로 확인. 워커를 강제 종료하지 않음 |
| 오류 | 워커 예외는 결과 객체로 감싸 반환. 워커를 죽이지 않음 |
| DB 쓰기 | 메인 isolate 에서만. 워커는 순수 결과만 반환 |

**DB 쓰기는 배치로 처리합니다.** 48,000행을 한 행씩 넣으면 수 분이 걸립니다.

```dart
await db.batch((b) => b.insertAll(db.entries, chunk));  // chunk = 1000행
```

### 4.3 압축 처리와 스트리밍

```dart
// 전체를 메모리에 올리지 않는다.
final input = InputFileStream(jarPath);
final archive = ZipDecoder().decodeStream(input);
for (final file in archive.files) {
  if (!file.isFile) continue;
  if (!ResourcePathParser.isLangResource(file.name)) continue;
  guard.check(file);                    // 4.4절
  final bytes = file.readBytes();       // 필요한 항목만 실제로 읽음
  // ...
}
await input.close();
```

`assets/*/lang/*.json` 이 아닌 항목은 **읽지 않습니다.** 200MB JAR 에서 실제로 읽는 건 보통 수십 KB 입니다.

### 4.4 압축 안전 검사

```dart
class ArchiveLimits {
  static const maxInputFileBytes    = 512 * 1024 * 1024;  // 512 MB
  static const maxEntryBytes        =  64 * 1024 * 1024;  //  64 MB
  static const maxTotalInflated     = 2 * 1024 * 1024 * 1024; // 2 GB
  static const maxCompressionRatio  = 200;                // 200:1
  static const maxEntryCount        = 100000;
  static const maxLangJsonBytes     =  32 * 1024 * 1024;  //  32 MB
  static const maxValueLength       = 8192;               // 단일 value 문자
}
```

**경로 탈출 방어**

```dart
bool isSafeEntryPath(String raw) {
  // 1. 역슬래시를 슬래시로 정규화 (Windows 로 만든 아카이브 대응)
  final unified = raw.replaceAll('\\', '/');
  // 2. 절대 경로 거부
  if (unified.startsWith('/')) return false;
  // 3. 드라이브 문자 거부 (C:/...)
  if (RegExp(r'^[A-Za-z]:').hasMatch(unified)) return false;
  // 4. UNC 거부
  if (unified.startsWith('//')) return false;
  // 5. 세그먼트 단위로 .. 거부 (문자열 contains 로는 부족)
  for (final seg in unified.split('/')) {
    if (seg == '..') return false;
  }
  // 6. NUL 및 제어 문자 거부
  if (unified.codeUnits.any((c) => c < 0x20)) return false;
  return true;
}
```

`contains('..')` 만으로는 부족합니다. `foo..bar` 는 안전하고 `a/../../etc` 는 위험합니다. 세그먼트 단위로 검사합니다.

**압축 폭탄 방어**

```text
항목별   uncompressedSize > maxEntryBytes            → 거부
항목별   uncompressedSize / compressedSize > 200     → 거부
누적     합계 > maxTotalInflated                     → 파일 전체 거부
개수     entryCount > maxEntryCount                  → 파일 전체 거부

헤더의 uncompressedSize 를 신뢰하지 않고 실제 읽은 바이트도 누적 검사한다.
```

### 4.5 리소스 경로 파싱

```dart
// assets/{namespace}/lang/{code}.json  — 이 형태만 인정
final _langPath = RegExp(
  r'^assets/([a-z0-9._-]+)/lang/([A-Za-z0-9_.-]+)\.json$',
);

// 대소문자를 구분하지 않는 파일 시스템에서 만든 아카이브 대응:
// 경로를 소문자로 정규화한 뒤 매칭하되, 실제 추출은 원본 경로로 한다.
```

| 규칙 | 내용 |
|---|---|
| 깊이 | 정확히 4단계. `assets/a/b/lang/x.json` 은 대상 아님 |
| namespace 문자 | Minecraft 규칙에 따라 `[a-z0-9._-]`. 대문자가 있으면 경고하되 처리는 계속 |
| 확장자 | `.json` 만. `.lang` (1.12 이하) 은 지원 범위 밖 |
| 중복 경로 | 같은 아카이브에 같은 경로가 두 번 있으면 첫 번째만 사용하고 경고 |

### 4.6 언어 코드 정규화

```text
입력                정규화
ko-KR          →    ko_kr
KO_KR          →    ko_kr
Korean         →    ko_kr
한국어          →    ko_kr
ko             →    ko_kr    (별칭 테이블 경유)

절차
1. 트림 · 소문자화
2. 구분자 통일 (- . 공백 → _)
3. language_profiles.json 의 aliases 에서 정확히 일치하는 항목 탐색
4. 없으면 xx_yy 형태 검사 후 그대로 사용
5. 그것도 아니면 '알 수 없는 언어 코드' 로 표시하되 파일은 목록에 남김

출력 파일명은 항상 프로필의 outputFile 값을 쓴다. 입력 파일명을 재사용하지 않는다.
```

---

## 5. 변수 및 서식 코드 보호

이 앱에서 **가장 중요한 로직**입니다. 여기가 틀리면 게임이 깨집니다.

### 5.1 토큰 패턴

```dart
/// 순서가 의미를 가진다. 위에서부터 시도하며, 긴 것이 먼저 와야 한다.
final tokenPattern = RegExp(
  // 1. 이스케이프된 퍼센트. %s 보다 먼저.
  r'%%'
  // 2. HEX 색상. §x§F§F§A§A§0§0 — 단일 § 코드보다 먼저.
  r'|§x(?:§[0-9a-fA-F]){6}'
  // 3. 단일 서식 코드. §0-§f, §k-§o, §r
  r'|§[0-9a-fk-orA-FK-OR]'
  // 4. 위치 지정 printf. %1$s, %2$d, %1$.2f — 일반 printf 보다 먼저.
  r'|%\d+\$[-#+ 0,(]*[\d.]*[sdfn]'
  // 5. 일반 printf. %s, %d, %f, %n, %02d
  r'|%[-#+ 0,(]*[\d.]*[sdfn]'
  // 6. 셸 스타일 템플릿. ${player}
  r'|\$\{[A-Za-z0-9_.]+\}'
  // 7. 이중 중괄호. {{name}} — 단일 중괄호보다 먼저.
  r'|\{\{[A-Za-z0-9_.]+\}\}'
  // 8. 단일 중괄호. {0}, {name}
  r'|\{[A-Za-z0-9_.]+\}'
  // 9. JSON 이스케이프 시퀀스 (원본 문자열의 리터럴 두 문자)
  r'|\\[nrt"\\]',
);
```

**순서가 틀리면 생기는 일**

```text
§x 를 § 뒤에 두면
  §x§F§F§A§A§0§0  →  §x + §F + §F + §F + §A + §A + §0 + §0  (7개 토큰으로 쪼개짐)
  → 번역기가 순서를 바꾸면 색상 코드가 무너진다

%1$s 를 %s 뒤에 두면
  %1$s  →  %1 은 매칭 안 되고, $s 만 남음
  → 위치 지정 인자가 깨진다

%% 를 %s 뒤에 두면
  %%  →  % + % 로 각각 처리되거나 %s 로 오인
```

### 5.2 치환과 복원

```dart
class ProtectedText {
  final String masked;              // 토큰이 자리표시자로 바뀐 문자열
  final List<String> tokens;        // 원래 토큰 (등장 순서)
}

/// 자리표시자는 어떤 번역기도 건드리지 않을 형태여야 한다.
/// 조건: ① 번역 대상 언어에 없는 문자 ② 단어 경계가 명확 ③ 번역기가 삭제하지 않음
String _placeholder(int i) => '\u{2063}LF$i\u{2063}';  // INVISIBLE SEPARATOR 로 감쌈
```

| 자리표시자 후보 | 문제 |
|---|---|
| `__0__` | 번역기가 밑줄을 제거하거나 공백을 넣음 |
| `{0}` | 원래 토큰과 충돌 |
| `<0>` | 일부 엔진이 HTML 태그로 해석 |
| `⁣LF0⁣` (U+2063 감싸기) | **채택.** 보이지 않고, 번역 대상 문자가 아니며, 대부분의 엔진이 보존 |

**복원 시 반드시 재검증합니다.** 엔진이 자리표시자를 변형했을 수 있습니다.

```text
복원 절차
1. 자리표시자를 원래 토큰으로 되돌린다
2. 남은 자리표시자가 있으면 → 검증 실패
3. 원문과 번역문의 토큰 멀티셋을 비교한다
4. 불일치하면 → 검증 실패, 번역 값을 저장하지 않음
```

### 5.3 멀티셋 비교

존재 여부가 아니라 **종류와 개수**를 비교합니다.

```dart
Map<String, int> bagOf(String s) {
  final bag = <String, int>{};
  for (final m in tokenPattern.allMatches(s)) {
    bag.update(m.group(0)!, (v) => v + 1, ifAbsent: () => 1);
  }
  return bag;
}

bool multisetEquals(Map<String, int> a, Map<String, int> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}
```

**판정 예시**

| 원문 | 번역문 | 결과 |
|---|---|---|
| `%s hit %s` (`%s`×2) | `%s이 %s를 때림` (`%s`×2) | 통과 |
| `%s hit %s` (`%s`×2) | `%s이 %d를 때림` (`%s`×1, `%d`×1) | **실패** |
| `%1$s died` | `%1$s님이 사망` | 통과 |
| `%1$s died %2$s` | `%1$s님이 사망` (`%2$s` 누락) | **실패** |
| `§aReady§r` | `§a준비§r` | 통과 |
| `§aReady§r` | `준비` | **실패** |

### 5.4 번역 제외 규칙

API 로 보낼 필요가 없는 값입니다. 설정으로 켜고 끌 수 있습니다.

```dart
final _excludePatterns = <String, RegExp>{
  'url':        RegExp(r'^https?://\S+$'),
  'resource':   RegExp(r'^[a-z0-9_.-]+:[a-z0-9/_.-]+$'),   // minecraft:stone
  'path':       RegExp(r'^[A-Za-z]:[\\/]|^/[\w/.-]+$'),
  'command':    RegExp(r'^/\w+'),
  'uuid':       RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'),
  'numeric':    RegExp(r'^[\d\s.,+\-%]+$'),
};

/// 별도 판정: 토큰을 제거하면 아무것도 남지 않는 값
bool isTokenOnly(String s) => s.replaceAll(tokenPattern, '').trim().isEmpty;
```

빈 문자열은 항상 제외하고 `empty` 상태로 고정합니다.

### 5.5 후처리

```text
1. 자리표시자 → 원래 토큰 복원
2. 연속 공백 정리 (단, 원문에 연속 공백이 있으면 유지)
3. 앞뒤 공백 제거 (원문에 있으면 유지)
4. 번역기가 붙인 불필요한 따옴표 제거 ("번역결과" → 번역결과)
5. Unicode NFC 정규화
6. 제어 문자 제거 (원문에 같은 문자가 있으면 유지)
7. 용어집 위반 검출 (자동 치환 없음)                   [1.0]

원문 의미를 확장하지 않는다. key 는 어떤 단계에서도 건드리지 않는다.
2~6 은 `TextPostProcessor.process()` 하나에서 이 순서대로 실행된다.
3 이 4 보다 먼저다. `  "번역"  ` 처럼 여백과 따옴표가 겹치면 여백을 먼저 걷어내야
따옴표가 문자열 양 끝으로 온다.

**7단계 — 용어집 위반 검출 `[1.0]`**

```text
자동 치환하지 않는다. 한국어 조사·어미를 깨뜨리기 쉽다.
검출만 하고, 위반이면 항목 상태를 confirm 으로 두어 사용자가 편집기에서 고친다.

위반 조건 (둘 다 참일 때만)
  원문에 sourceTerm 포함  AND  결과에 targetTerm 없음

부분 일치 사전 치환(번역 전)도 금지. 번역 전 API 생략은 원문 완전 일치만 (7.5절).
```

**6단계의 판정 기준**

```text
제거 대상   C0 (U+0000–U+001F) 과 C1 (U+007F–U+009F)
예외        탭 · 개행 · 캐리지 리턴은 정상 문자로 본다
예외        원문에 같은 코드포인트가 있으면 모드 제작자가 의도한 것이므로 유지한다

보호 토큰은 이 범위에 들어오지 않는다.
§ 는 U+00A7 이고, 
 은 역슬래시와 n 두 글자다.
```

**5단계는 주입받는다**

```text
Dart 표준에 정규화가 없고 domain 은 외부 패키지를 쓰지 않으므로(2.1)
TextPostProcessor 는 TextNormalizer 인터페이스만 받는다.
기본값은 아무것도 하지 않는 구현이라 domain 단위 테스트에 배선이 필요 없다.
TranslationRunner 가 UnicodeTextNormalizer 를 주입한다.
```
```

---

## 6. 번역 서비스

### 6.1 어댑터 인터페이스

```dart
abstract interface class TranslationProvider {
  String get id;                     // 'gemini' | 'deepl' | 'google' | 'papago'
  String get displayName;
  List<AuthField> get authFields;    // UI 가 이걸 보고 폼을 그린다
  List<String> get models;           // 모델 개념이 없으면 빈 목록

  /// 인증 정보 유효성만 확인. 최소 비용 요청.
  Future<void> verify(AuthValues auth);

  /// 문자열 목록 → 번역된 문자열 목록. 길이와 순서를 보존해야 한다.
  /// key 는 이 인터페이스에 들어오지 않는다.
  Future<List<String>> translate(TranslationRequest request);

  /// 이 제공자의 배치 크기 상한
  BatchLimits get limits;
}

class TranslationRequest {
  final List<String> texts;          // 이미 토큰이 보호된 상태
  final String sourceCode;           // 제공자별 언어 코드
  final String targetCode;
  final String? model;
  final AuthValues auth;
  final CancellationToken cancel;
}

class BatchLimits {
  final int maxTextsPerRequest;
  final int maxCharsPerRequest;
  final int maxConcurrentRequests;
  final Duration requestTimeout;
}
```

**`key` 는 이 인터페이스를 통과하지 않습니다.** 타입 시스템으로 계획서 §2.4 를 강제합니다.

### 6.2 제공자별 설정

| 제공자 | 인증 필드 | 엔드포인트 | 인증 전달 |
|---|---|---|---|
| **Gemini** (MVP) | API Key, 모델 | `POST {baseUrl}/models/{model}:generateContent` (`baseUrl` = `https://generativelanguage.googleapis.com/v1beta`) | `x-goog-api-key` 헤더 |
| DeepL **[1.0]** | API Key | Free: `POST https://api-free.deepl.com/v2/translate` · Pro: `POST https://api.deepl.com/v2/translate`. 키 접미사 `:fx` 이면 Free | `Authorization: DeepL-Auth-Key {key}` |
| Google Cloud Translation **[1.0]** | API Key (서비스 계정 JSON 은 보류) | `POST https://translation.googleapis.com/language/translate/v2` (Basic / v2) | `x-goog-api-key` 헤더 |
| Papago **[1.0]** | Client ID, Client Secret | `POST https://papago.apigw.ntruss.com/nmt/v1/translation` (NCP Papago NMT) | `X-NCP-APIGW-API-KEY-ID` / `X-NCP-APIGW-API-KEY` |

**오류 매핑 보충 (Phase 8)**

| HTTP | 분류 |
|---|---|
| 401 · 403 | `AuthError` |
| 429 | `RateLimited` (`Retry-After` 있으면 우선) |
| 413 | `PayloadTooLarge` |
| 456 (DeepL 할당량) | `QuotaExhausted` |
| 5xx | `ServerError` |

**API 키를 URL 쿼리 파라미터로 보내지 않습니다.** 항상 헤더로 보냅니다. 쿼리 파라미터는 프록시 로그·에러 메시지·리다이렉트에 남습니다.

**모델 목록과 엔드포인트를 소스에 하드코딩하지 않습니다.** 벤더가 자주 바꿉니다. `assets/data/providers.json` 으로 분리하고 앱 갱신 없이 교체 가능하게 합니다.

MVP 의 Gemini 모델 셀렉트는 아래 두 항목을 제공합니다. 기본값은 목록의 첫 항목입니다.

```text
gemini-3.6-flash         기본 · 품질 우선
gemini-3.5-flash-lite    대안 · 처리량·비용 우선
```

MVP REST API 버전은 공식 문서에서 두 모델의 `generateContent` 예시가 제공되는 `v1beta` 로 고정합니다. Phase 3 착수 시 `providers.json` 의 모델 가용성과 엔드포인트를 다시 확인하되, 검증 없이 자동 변경하지 않습니다.

### 6.3 Gemini 어댑터 (MVP)

LLM 이므로 프롬프트 설계가 결과 품질을 좌우합니다.

```text
요구사항
├── 여러 문자열을 한 번에 번역하되 순서와 개수를 정확히 보존해야 함
├── 자리표시자(⁣LF0⁣)를 그대로 남겨야 함
├── 설명·주석·따옴표를 덧붙이지 않아야 함
└── 응답이 파싱 가능한 구조여야 함

접근
├── responseMimeType: application/json + responseSchema 로 구조 강제
├── 입력을 인덱스 배열로 전달, 출력도 인덱스 배열로 요구
├── 개수가 다르면 즉시 실패 처리하고 배치를 절반으로 나눠 재시도
└── temperature 를 낮게 (0.1~0.3) 설정하여 일관성 확보
```

`responseSchema` 의 정확한 JSON 필드 구조는 Phase 3.4 구현 시 요청/응답 개수 검증과 배치 분할 전략을 함께 실측하여 확정합니다. 그 전에도 "문자열 배열의 순서와 개수를 보존한다"는 외부 계약은 바뀌지 않습니다.

```dart
// 시스템 지시 (요지)
const _instruction = '''
You translate Minecraft mod UI strings from {source} to {target}.

Rules:
- Return exactly the same number of items, in the same order.
- Preserve every ⁣LF<number>⁣ placeholder exactly as it appears. Do not translate,
  reorder relative to surrounding words when grammatically avoidable, or remove them.
- Do not add quotes, explanations, notes, or trailing punctuation that is not in the source.
- Keep the register short and UI-appropriate. These are item names, tooltips, and messages.
- Translate every item into {target}. Never return the whole input array unchanged.
- Only an individual proper noun or mod name may be left unchanged — never most or all items.
''';

// user 파트에는 번역 지시를 명시한 뒤 JSON 배열을 붙인다.
// 배열만 보내면 모델이 입력을 통째로 되돌리는 원문 에코가 관찰됐다.
```

**LLM 번역은 항상 검증을 통과해야 합니다.** 프롬프트로 지시했다고 신뢰하지 않고, 5.3절·7.3절의 검증으로 기계적으로 확인합니다. `finishReason`/`promptFeedback.blockReason` 이상도 `InvalidResponse` 로 승격합니다.

### 6.4 대기열과 동시성

```dart
class TranslationRunner {
  static const _maxConcurrent = 4;       // 제공자 limits 로 덮어씀
  static const _batchSize = 25;          // 제공자 limits 로 덮어씀 (Q2 임시값)

  // 상태: idle | running | paused | cancelling
}
```

| 항목 | 규칙 |
|---|---|
| 배치 구성 | 같은 namespace 의 항목을 모아 문맥 일관성 확보. 문자 수 상한도 함께 적용 |
| 동시 요청 | 제공자별 상한. 기본 4 |
| 일시정지 | 진행 중 배치는 완료시키고 새 배치를 시작하지 않음 |
| 취소 | `CancellationToken` 전파. 진행 중 요청은 abort. 완료 항목은 유지하고 진행 중이던 배치만 `wait` 로 되돌린 뒤 저장 |
| 진행 보고 | 배치 완료 시마다 메모리 상태 갱신 + 스트림 방출. 프로젝트 DB 저장은 전체 완료·일시정지·취소·오류 중단 시 수행 |
| 부분 실패 | 배치 안의 일부만 실패해도 나머지의 검증 통과 결과는 메모리 상태에 반영하고 다음 저장 트리거에서 보존 |
| 개수 불일치 | 요청 N개 → 응답 M개(M≠N) 이면 배치를 절반으로 분할해 재시도. 1개까지 내려가도 실패하면 해당 항목만 실패 처리 |

### 6.5 오류 분류와 재시도

```dart
sealed class TranslationError {}

// 재시도한다
final class RateLimited     extends TranslationError { final Duration? retryAfter; }
final class ServerError     extends TranslationError { final int statusCode; }   // 5xx
final class NetworkError    extends TranslationError {}
final class TimeoutError    extends TranslationError {}

// 재시도하지 않는다
final class AuthError       extends TranslationError {}   // 401 · 403
final class QuotaExhausted  extends TranslationError {}   // 결제·할당량 소진
final class PayloadTooLarge extends TranslationError {}   // 413 → 배치 분할로 대응
final class InvalidResponse extends TranslationError {}
final class Cancelled       extends TranslationError {}
```

**백오프**

```dart
Duration backoff(int attempt) {
  final base = Duration(milliseconds: 500 * math.pow(2, attempt).toInt());
  final capped = base > const Duration(seconds: 30) ? const Duration(seconds: 30) : base;
  // 지터: 동시 요청이 같은 시점에 몰리는 것을 방지
  final jitter = Random().nextInt(capped.inMilliseconds ~/ 4 + 1);
  return capped + Duration(milliseconds: jitter);
}

const maxAttempts = 5;   // 무한 재시도하지 않는다
```

`RateLimited` 에 `Retry-After` 헤더가 있으면 그 값을 우선합니다.

| 오류 | 대기열 영향 |
|---|---|
| `AuthError` | **전체 중단.** 키가 틀렸으면 나머지도 다 실패함 |
| `QuotaExhausted` | **전체 중단.** 배너로 안내 |
| `NetworkError` 연속 3회 | **자동 일시정지.** 재개는 사용자가 |
| 나머지 | 재시도 상한 초과 또는 영구 오류가 난 항목을 `invalid` 로 전환하고 번역 값은 저장하지 않음. 대기열은 계속 진행 |

API 호출 실패도 최종 항목 상태는 별도 오류 열거형을 만들지 않고 `EntryStatus.invalid`(`검증 실패`)를 사용합니다. 구체 원인은 검증/오류 상세 필드와 배너에 보존하여 토큰 불일치와 구분합니다.

---

## 7. 병합과 검증

### 7.1 병합 우선순위

```dart
String resolveFinal(TranslationEntry e) {
  if (e.userTranslation != null)      return e.userTranslation;      // 1
  if (e.existingTranslation != null)  return e.existingTranslation;  // 2
  if (e.glossaryTranslation != null)  return e.glossaryTranslation;  // 3  [1.0]
  if (e.reviewedCacheTranslation != null)                            // 4  [1.0]
    return e.reviewedCacheTranslation;  // CacheKind.reviewed | userEdited 만
  if (e.newTranslation != null)       return e.newTranslation;       // 5
  return e.sourceText;                                               // 6 원문 유지
}
```

| 단계 | 후보 | 비고 |
|---|---|---|
| 3 | 용어집 (전역∪프로젝트, 프로젝트 우선) | 원문 **완전 일치**로 채운 값. 부분 일치 금지 |
| 4 | 검수된 번역 캐시 | `CacheKind.reviewed` · `userEdited` 만. `auto` 금지 |
| 5 | 새 자동 번역 | 제공자 응답 **또는** `CacheKind.auto` 적중 (`status = cache`, `newTranslation` 채움) |

`auto` 캐시가 4단계에 오면 기존 번역(2단계)을 이기지 못하는 보장이 깨집니다. `auto` 적중은 5단계 자리에 넣고 `status = cache` 로 표시합니다.

**기존 번역 전체를 자동 번역으로 덮어쓰지 않습니다.** 이 함수는 순수 함수로 만들어 단위 테스트로 전수 검증합니다. 후보 5필드(user · existing · glossary · reviewedCache · new) × 없음/빈/값 = 243 조합.

### 7.2 기존 번역 분류

입력 파일에 있던 대상 언어 값은 그대로 신뢰하지 않고 분류합니다.

| 분류 | 판정 | 처리 |
|---|---|---|
| 정상 번역 | 값이 있고 원문과 다르며 토큰이 일치 | `kept` |
| 원문과 동일 | 값 == 원문 | `kept` (의도적일 수 있음). 경고 표시 |
| 빈 문자열 | 값이 `""` | 원문도 비었으면 `empty`, 아니면 `wait` |
| 오래된 key | 원본에 없는 key | 출력에서 제외. 보고서에 기록 |
| 변수 불일치 | 토큰 멀티셋이 원문과 다름 | `confirm` (사용자 확인 필요) |
| JSON 오류 | 대상 파일 자체가 깨짐 | 기존 번역 무시하고 전부 `wait`. 경고 |

### 7.3 검증 항목

```text
항목 단위
├── 보호 토큰 멀티셋 일치
├── 남은 자리표시자 없음
├── 빈 번역 아님 (원문이 비었을 때 제외) → invalid, 값 미저장
├── 비정상 제어 문자 없음 → invalid, 값 미저장
├── 길이가 비정상적으로 크지 않음 (원문의 10배 초과) → invalid, 값 미저장
├── 배치(|batch| > 1) 원문 에코율 ≥ 90% → 배치 실패로 분할 재시도
├── 부분 에코 → 에코 항목만 재배치 1회 후 단건 재시도
└── 단건(|batch| == 1) 원문 에코 → fallback(원문 유지). done 으로 저장하지 않음

파일 단위 (출력 직전)
├── JSON 문법 유효
├── UTF-8 인코딩
├── 원본 key 개수 == 출력 key 개수
├── key 목록 완전 일치 (집합 비교)
├── key 순서 보존
├── 중복 key 없음
├── 파일명이 대상 언어 프로필의 outputFile 과 일치
└── 경로가 assets/{ns}/lang/{file} 형태
```

이미 `done` 으로 저장된 원문 에코(`newTranslation == sourceText`)는 번역 시작 시 `wait` 로 되돌린다. 범위는 **대기열이 실제로 다시 보낼 수 있는 네임스페이스로 한정**한다 — 제외·미선택 네임스페이스까지 되돌리면 값만 지운 채 영구히 `대기` 로 남는다.

러너가 확정한 `fallback`(`sourceEcho`) 은 `실패 항목 다시 시도` 일 때만 `wait` 로 되돌린다. 매 실행마다 쓸어담으면 번역 불가 문자열에 반복 과금된다. 사용자가 직접 지정한 원문 유지(`userEdited`)와 제외 값의 `fallback` 은 어느 경우에도 건드리지 않는다.

배치 에코로 분할 재시도할 때 하위 배치는 `rebatch` 단계를 물려받는다. `initial` 로 되돌리면 이진 분할 트리가 전개되어 요청 수가 배로 늘어난다(전량 에코 100키 기준 196회 → 112회).

### 7.4 출력 차단 판정

```dart
sealed class ExportVerdict {}
final class Allowed extends ExportVerdict { final ExportSummary summary; }
final class Blocked extends ExportVerdict { final List<BlockReason> reasons; }

enum BlockReason {
  jsonError,          // 무조건 차단
  unresolvedConflict, // 무조건 차단
  corruptTargetFile,  // 무조건 차단
  translationRunning, // 무조건 차단
  noNamespaceSelected,// 무조건 차단
  validationFailed,   // 정책에 따름 (기본: 차단)
  pendingEntries,     // 정책에 따름 (기본: 원문 유지 후 출력)
}
```

앞의 5개는 사용자가 무시할 수 없습니다. 뒤의 2개만 정책 선택이 가능합니다.

### 7.5 캐시와 용어집 `[1.0]`

#### 캐시 키 8요소

하나라도 다르면 미적중. 키에는 원문 raw 를 넣지 않고 해시만 쓴다.

| # | 요소 | 계산 |
|---|---|---|
| 1 | `sourceHash` | `SHA-256(원문)` — 토큰 치환 **전** raw. `sourceText` 컬럼은 디버그용 |
| 2 | `sourceLangCode` | 정규화 내부 코드 (`en_us`). `ProviderLanguageCode` 적용 전 |
| 3 | `targetLangCode` | 동일 |
| 4 | `providerId` | `gemini` · `deepl` · `google` · `papago` |
| 5 | `modelId` | 없으면 `""`. 엔진 옵션은 `TranslationRequest` 의 model/auth 뿐 |
| 6 | `glossaryFingerprint` | 아래 지문 규칙 |
| 7 | `protectorVersion` | 토큰 치환 규칙 버전 상수 (`TokenProtector.version`) |
| 8 | `postProcessorVersion` | §5.5 1~6단계 규칙 버전 상수 (`TextPostProcessor.version`) |

**8번이 namespace 가 아닌 이유.** 캐시 가치는 모드 간 재사용이다. namespace 를 키에 넣으면 "Copper Ingot" 이 모드 A에서만 적중하고 전역 캐시가 무력화된다. 모드별 용어 차이는 6번(`glossaryFingerprint`)이 namespace 스코프 용어집으로 흡수한다. 후처리 규칙이 바뀌면 저장 결과가 낡으므로 8번은 `postProcessorVersion` 이다.

**glossaryFingerprint**

```text
1. 전역 용어집 ∪ 프로젝트 용어집 (같은 term·언어쌍·스코프면 프로젝트 승)
2. 현재 언어쌍에 해당하는 행만
3. 항목에 적용 가능한 스코프만 (namespace 일치 또는 namespace == null)
4. (sourceTerm, targetTerm, namespace, caseSensitive) 로 정렬
5. 정규화 문자열을 SHA-256
```

전체 용어집 해시로 계산하지 않는다. 무관한 용어 하나가 바뀌어도 캐시가 전멸하기 때문이다.

#### CacheKind 와 조회·쓰기

```dart
enum CacheKind { auto, reviewed, userEdited }
```

| 종류 | API 스킵 | MergePolicy | 쓰기 시점 |
|---|---|---|---|
| `auto` | ✓ | 5단계 (`newTranslation` + `status=cache`) | `done` 확정 시 |
| `reviewed` | ✓ | 4단계 | 편집기 `승인` (`approveConfirm`) 시 |
| `userEdited` | ✓ | 4단계 | 사용자 직접 수정 저장 시 |

용어집 이중 소스: 번역 시 `glossaryExact` 로 저장된 값은 **스냅샷**으로 MergePolicy 3단계에 넣고, 용어집을 나중에 고쳐도 출력과 편집기가 갈라지지 않는다. `wait` 등 미저장 행만 용어집 **라이브** 완전일치를 쓴다.

같은 8요소에 여러 kind 가 있으면 조회 우선순위는 `userEdited` > `reviewed` > `auto`.
`invalid` 결과는 캐시에 쓰지 않는다 (AGENTS 2.1).

#### 용어집 적용

```text
저장
├── 전역  %APPDATA%\LangForge\glossary.db
└── 프로젝트  .lfproj → glossary_terms
    충돌 (sourceTerm, 언어쌍, namespace) → 프로젝트가 전역을 덮음

번역 전 API 생략
└── trim 후 원문 전체 == sourceTerm (caseSensitive 플래그 존중)
    → API 호출 없음. glossaryTranslation 채움. status = done.
    부분 일치는 번역 전 치환하지 않는다.

번역 후 (§5.5 7단계)
└── 원문에 sourceTerm 포함 AND 결과에 targetTerm 없음 → confirm
    자동 치환 없음.
```

#### 버전 상수

```dart
// 규칙이 바뀌면 숫자를 올린다. 캐시 키가 갈라져 구 결과가 자동 무효화된다.
abstract final class TokenProtector {
  static const version = '1';
}
abstract final class TextPostProcessor {
  static const version = '1';
}
```

#### 적중률 표시

대상 항목 0개이면 `—`. `NaN%` · `Infinity` · 빈 문자열 금지 (AGENTS 5.3).

---

## 8. 출력

### 8.1 형식별 구조

```text
namespace별 JSON
output/
├── quark/ko_kr.json
├── zeta/ko_kr.json
└── burnt/ko_kr.json

전체 경로 보존 JSON
output/
└── assets/
    ├── quark/lang/ko_kr.json
    ├── zeta/lang/ko_kr.json
    └── burnt/lang/ko_kr.json

폴더형 리소스팩
LangForge_Translation_Pack/
├── pack.mcmeta
├── pack.png
└── assets/
    ├── quark/lang/ko_kr.json
    └── ...

통합 ZIP 리소스팩
KO_Translation_Pack.zip
├── pack.mcmeta          ← ZIP 최상단. 팩 이름 폴더가 있으면 안 됨
├── pack.png
└── assets/
    └── ...

모드별 개별 리소스팩  [1.0]
output/
├── Quark_ko_kr_Pack.zip
├── Burnt_ko_kr_Pack.zip
└── ...
```

### 8.2 ZIP 구조 검증

가장 흔한 실패 원인입니다. 출력 후 **직접 열어서 확인합니다.**

```dart
Future<void> verifyPackZip(String zipPath) async {
  final archive = ZipDecoder().decodeStream(InputFileStream(zipPath));
  final names = archive.files.where((f) => f.isFile).map((f) => f.name).toList();

  // pack.mcmeta 가 정확히 최상단에 있어야 한다
  if (!names.contains('pack.mcmeta')) {
    throw ExportError('pack.mcmeta 가 ZIP 최상단에 없습니다');
  }
  // 팩 이름 폴더가 한 겹 더 있는 실수 감지
  if (names.any((n) => n.endsWith('/pack.mcmeta') && n != 'pack.mcmeta')) {
    throw ExportError('pack.mcmeta 가 하위 폴더에 있습니다');
  }
  // 경로 구분자는 항상 '/'
  if (names.any((n) => n.contains('\\'))) {
    throw ExportError('ZIP 경로에 역슬래시가 포함되었습니다');
  }
}
```

Windows 에서 만들면 경로 구분자가 `\` 가 되기 쉽습니다. ZIP 명세는 `/` 를 요구하고 Minecraft 는 `\` 를 인식하지 못합니다.

### 8.3 JSON 출력 규칙

| 항목 | 규칙 |
|---|---|
| 인코딩 | UTF-8, BOM 없음 |
| key 순서 | 원본 순서 보존 (`keyOrder` 컬럼) |
| 구조 | Minecraft `lang/*.json` 표준인 최상위 평탄 Object만 지원. 중첩 Object/Array 값은 `unsupported structure` 로 사전 검사 실패 처리하고 해당 namespace를 격리 |
| 들여쓰기 | 2칸 |
| 줄 끝 | `\n` (CRLF 아님) |
| 마지막 줄 | 개행 하나 |
| 이스케이프 | Dart `jsonEncode` 기본. 한글을 `\uXXXX` 로 바꾸지 않음 |
| 빈 값 | `""` 그대로 유지. key 를 삭제하지 않음 |

### 8.4 pack.mcmeta

```json
{
  "pack": {
    "pack_format": 15,
    "description": "한국어 번역 리소스팩 · LangForge"
  }
}
```

`pack_format` 은 `mc_versions.json` 에서 조회합니다. 코드에 상수로 넣지 않습니다.

### 8.4b pack.png

```text
기본 아이콘   assets/pack/pack.png  — 128x128 RGBA PNG
생성          tool/generate_pack_icon.dart 로 결정론적 생성. 산출물을 커밋한다
색            DESIGN.md 2절 토큰 (#161616 배경 · #4FC0A1 포인트)

packIconMode (3.2)
├── default   번들 아이콘
├── custom    사용자가 고른 PNG. 읽기 실패 시 번들 아이콘으로 대체한다
│             검증: PNG · 정사각형 · 64x64 이상 1024x1024 이하 · 손상 없음
├── mod       JAR 내부 아이콘 추출 → 정사각형 크롭 → 128x128 리사이즈
│             탐색 순서: pack.png, icon.png, logo.png, META-INF/mods.toml 의
│             logoFile, fabric.mod.json 의 icon.
│             여러 JAR 이면 첫 번째로 성공한 것을 쓴다.
│             실패 시 default 로 폴백한다
└── none      pack.png 없이 출력. Minecraft 는 아이콘 없는 팩도 받아들인다

아이콘은 장식이다. 아이콘 문제로 출력 전체를 실패시키지 않는다.
```

### 8.5 원자적 쓰기

```text
출력 실패 시 부분 생성 파일을 남기지 않는다.

1. 임시 디렉터리에 전체를 생성한다
2. 8.2절의 검증을 통과시킨다
3. 최종 경로로 이동(rename)한다
4. 어느 단계에서든 실패하면 임시 디렉터리를 통째로 삭제한다

같은 경로에 파일이 있으면 사용자 확인을 받고,
덮어쓸 때도 기존 파일을 먼저 .bak 으로 옮긴 뒤 이동한다.
```

### 8.6 보고서

`Translation_Report.md` 를 출력물과 함께 생성합니다.

```markdown
# LangForge 번역 보고서

생성: 2026-08-07 14:32 · LangForge 0.1.0

## 프로젝트
이름 · 원본 언어 · 대상 언어 · 번역 제공자 · 모델

## 입력 파일
| 파일명 | 크기 | SHA-256 (앞 12자) | namespace | 상태 |

## namespace
| namespace | 원본 | 전체 키 | 새 번역 | 기존 유지 | 원문 유지 | 실패 |

## 통계
전체 · 상태별 집계 · 캐시 적중률

## 오류
| namespace | 파일 | 줄 | 메시지 |

## 경고
| namespace | key | 내용 |

## 충돌
| namespace | key | 참여 파일 | 해결 |

## 원문 유지 항목
| namespace | key | 원문 | 사유 |

## 출력 파일
| 경로 | 크기 | 키 수 |
```

**보고서에 API 키·인증 헤더·사용자 홈 경로 전체가 들어가지 않습니다.** `SensitiveFilter` 를 통과시킵니다.

---

## 9. 보안

### 9.1 위협 모델

| 위협 | 대응 |
|---|---|
| 악의적 JAR 의 경로 탈출 (zip slip) | 4.4절 세그먼트 단위 검사. 어떤 항목도 대상 디렉터리 밖에 쓰지 않음 |
| 압축 폭탄 | 4.4절 크기·비율·개수 상한 |
| 악의적 JSON 으로 메모리 고갈 | 파일 크기·값 길이 상한. 스트리밍 파싱 |
| API 키 유출 (파일) | OS 보안 저장소. 프로젝트 파일·로그·보고서에 미기록 |
| API 키 유출 (화면) | 항상 마스킹. 표시 토글 없음 |
| API 키 유출 (네트워크) | 헤더로만 전달. URL 쿼리 미사용. HTTPS 강제 |
| API 키 유출 (오류 메시지) | `SensitiveFilter` 로 예외 메시지·스택 필터링 |
| 원본 파일 훼손 | 입력 파일을 **읽기 전용**으로만 연다. 쓰기 핸들을 열지 않음 |
| 사용자 데이터 유출 | 번역 API 외 외부 통신 없음. 텔레메트리 없음 |
| 의존성 공급망 | `pubspec.lock` 커밋. CI 에서 비밀값 스캔 |

### 9.2 자격 증명 저장

```dart
class CredentialStore {
  static const _storage = FlutterSecureStorage(
    wOptions: WindowsOptions(),   // Credential Manager
    aOptions: AndroidOptions(encryptedSharedPreferences: true),  // [모바일]
  );

  static String _key(String providerId, String fieldId) =>
      'LangForge/$providerId/$fieldId';

  Future<void> write(String providerId, String fieldId, String value);
  Future<String?> read(String providerId, String fieldId);
  Future<void> deleteProvider(String providerId);
  Future<void> deleteAll();
}
```

| 규칙 | 내용 |
|---|---|
| 저장 위치 | Windows Credential Manager (`flutter_secure_storage` 경유) |
| 프로젝트 파일 | 키를 **저장하지 않음.** `providerId` 만 기록 |
| 내보내기 | 프로젝트 파일을 남에게 줘도 키가 따라가지 않음 |
| 메모리 | 요청 직전에 읽고, 요청 후 참조를 해제. 전역 캐시하지 않음 |
| 접근 실패 | 세션 한정 메모리 보관으로 대체. 배너로 "앱을 닫으면 다시 입력해야 합니다" 안내 |
| 삭제 | 설정에서 제공자별로 삭제 가능 |

### 9.3 민감 정보 필터

```dart
class SensitiveFilter {
  static final _patterns = <RegExp>[
    RegExp(r'AIza[0-9A-Za-z_-]{35}'),                    // Google/Gemini
    RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}:fx'), // DeepL
    RegExp(r'(?i)(api[_-]?key|secret|token|authorization)\s*[:=]\s*\S+'),
    RegExp(r'(?i)DeepL-Auth-Key\s+\S+'),
    RegExp(r'(?i)X-NCP-APIGW-API-KEY\S*\s*[:=]\s*\S+'),
  ];

  static String scrub(String input) {
    var out = input;
    for (final p in _patterns) out = out.replaceAll(p, '[REDACTED]');
    return _shortenHomePath(out);
  }

  // C:\Users\kingh\... → %USERPROFILE%\...
  static String _shortenHomePath(String s);
}
```

**모든 로그 기록과 보고서 생성이 이 함수를 통과합니다.** 예외 메시지, 스택 트레이스, HTTP 오류 본문도 포함합니다.

### 9.4 네트워크 정책

```text
HTTPS 만 허용. http:// 요청은 코드 수준에서 거부한다.
인증서 검증을 우회하는 코드를 넣지 않는다 (badCertificateCallback 금지).
번역 API 와 사용자가 명시적으로 여는 링크(url_launcher) 외에 외부 통신이 없다.
업데이트 확인·사용 통계·오류 리포팅 없음.
```

### 9.5 파일 시스템 정책

```text
입력 파일은 읽기 전용으로만 연다.
출력은 사용자가 선택한 경로 아래에만 쓴다.
임시 파일은 OS 임시 디렉터리에 만들고 작업 종료 시 삭제한다 (비정상 종료 대비 시작 시 정리).
관리자 권한을 요구하지 않는다.
심볼릭 링크를 따라가지 않는다.
```

---

## 10. 성능

### 10.1 예산

`EXPERIENCE.md` AC-12 와 `PRODUCT.md` T9·T10 을 만족해야 합니다.

| 항목 | 목표 | 측정 |
|---|---|---|
| 앱 시작 → 첫 화면 | 1.5초 이내 | 콜드 스타트 |
| JAR 180개 탐색 완료 | 60초 이내 | 실제 모드팩 |
| 키 48,000개 DB 삽입 | 20초 이내 | 배치 삽입 |
| namespace 전환 → 목록 표시 | 100ms 이내 | 인덱스 조회 |
| 검색 입력 → 결과 반영 | 150ms 이내 | 디바운스 포함 |
| 목록 스크롤 | 60fps 유지 | 프레임 타이밍 |
| 번역 자체 처리 (API 대기 제외) | 키 10,000개당 5분 이내 | |
| 출력 (ZIP 생성) | 키 48,000개 30초 이내 | |
| 메모리 최대 | 1.5GB 이내 | 180 JAR 처리 중 |

### 10.2 기법

| 기법 | 적용 위치 |
|---|---|
| 가상 스크롤 | 항목 목록, 탐색기 트리 (`ListView.builder`) |
| 지연 로딩 | namespace 를 클릭할 때 해당 항목만 조회 |
| 페이지네이션 | 목록 조회 시 `LIMIT` / `OFFSET`. 한 번에 200행 |
| 인덱스 | 3.3절 |
| 배치 삽입 | 1,000행 단위 트랜잭션 |
| 스트리밍 압축 읽기 | 필요한 항목만 실제로 읽음 |
| Isolate 분리 | 모든 무거운 작업 |
| 진행 스로틀 | 진행 보고를 100ms 간격으로 제한 |
| 디바운스 | 검색 입력 250ms. 파일 추가/제거·사용자 수정·설정 변경의 자동 저장 2초 |
| 번역 저장 | 배치마다 저장하지 않음. 전체 완료 또는 일시정지·취소·오류 중단 시 1회 저장 |
| `const` 위젯 | 디자인 시스템 위젯 전반 |
| `RepaintBoundary` | 목록 행 |

### 10.3 하지 않는 최적화

```text
FTS5 전문 검색      LIKE 로 시작. 실측에서 느리면 그때 추가.
캐싱 레이어         Drift 가 이미 SQLite 캐시를 활용. 별도 메모리 캐시는 일관성 위험만 늘림.
가상 트리 (탐색기)  namespace 는 수백 개 수준. 항목 목록만 가상화하면 충분.
```

측정 없이 최적화하지 않습니다. 10.1의 예산을 넘길 때만 손댑니다.

---

## 11. 테스트

### 11.1 전략

```text
      ┌──────────────┐
      │ integration  │  소수. 입력→출력 전체 경로
      ├──────────────┤
      │   widget     │  화면 단위 동작
      ├──────────────┤
      │              │
      │     unit     │  대부분. domain 계층 100%
      │              │
      └──────────────┘

      ┌──────────────┐
      │    corpus    │  로컬 전용. 실제 모드팩 회귀 검증
      └──────────────┘
```

### 11.2 단위 테스트 (domain 계층)

`domain` 은 순수 Dart 이므로 파일·네트워크 없이 전부 테스트합니다. **커버리지 목표 90% 이상.**

| 대상 | 필수 케이스 |
|---|---|
| `TokenPattern` | 5.1절의 9개 분기 각각. 순서 의존 케이스(`§x` HEX, `%1$s`, `%%`) 명시적 검증 |
| `TokenProtector` | 치환→복원 왕복이 원문과 동일. 자리표시자 잔존 감지 |
| `MultisetValidator` | 5.3절 판정 예시 전부 + 개수 불일치 + 순서만 다른 경우(통과해야 함) |
| `LanguageCodeNormalizer` | `ko-KR` `KO_KR` `Korean` `한국어` `ko` → `ko_kr`. 알 수 없는 코드 처리 |
| `ResourcePathParser` | 정상 경로, 깊이 초과, 확장자 불일치, 대문자 namespace, 역슬래시 |
| `MergePolicy` | 6단계 우선순위. 후보 5필드(user · existing · glossary · reviewedCache · new) × 없음/빈/값 = 243 케이스. `auto` 캐시는 4단계가 아니라 5단계(`newTranslation`)임을 별도 검증 |
| `ExistingTranslationClassifier` | 7.2 표의 6행 각각 + 오래된 key 추출 |
| `TextPostProcessor` | 따옴표·연속 공백·앞뒤 공백·제어 문자·NFC. 각 단계가 원문에 있으면 유지하는지 |
| `ExclusionPolicy` | URL·리소스경로·명령어·UUID·숫자·토큰전용·빈문자열 |
| `JsonPrecheck` | 문법 오류, 최상위 배열, 중첩 Object/Array와 비문자열 value, 중복 key, 빈 key, 제어 문자, 비정상 길이 |
| `ExportGate` | 무조건 차단 5종 + 정책 차단 2종의 조합 |
| `PackMetaBuilder` | 12개 버전 각각의 `pack_format` |
| `isSafeEntryPath` | `../`, `a/../b`, `/abs`, `C:/x`, `//unc`, `foo..bar`(안전), NUL |

### 11.3 인프라 테스트

| 대상 | 방법 |
|---|---|
| `ArchiveGuard` | 테스트 중 프로그램으로 생성한 악성 ZIP (경로 탈출·폭탄) |
| `ArchiveReader` | 프로그램으로 생성한 정상 ZIP |
| Drift DAO | 인메모리 SQLite (`NativeDatabase.memory()`) |
| `TranslationProvider` | `dio` 어댑터를 목으로 교체. 실제 API 호출 없음 |
| 오류 분류 | HTTP 401·403·413·429·500·타임아웃 각각에 대한 `TranslationError` 매핑 |
| 백오프 | 시도 횟수별 대기 시간 상한 확인 |
| `SensitiveFilter` | 각 제공자 키 형식이 `[REDACTED]` 로 치환되는지 |
| `ZipExporter` | 생성 후 8.2절 검증 함수로 재확인 |
| `CredentialStore` | 목으로 교체. 실제 Credential Manager 는 통합 테스트에서만 |

**악성 ZIP 은 저장소에 커밋하지 않고 테스트 실행 중에 만듭니다.** 바이너리 픽스처를 커밋하면 리뷰가 불가능하고 보안 스캐너가 오탐합니다.

### 11.4 위젯 테스트

| 화면 | 검증 |
|---|---|
| S0 시작 | 최근 목록 렌더링, 빈 상태, 경고 표시 |
| S1 빈 화면 | 드롭 영역, 드래그 오버 상태, 버튼 동작 |
| S2-A 탐색기 | 트리 계층, 체크박스 연동(JAR↔namespace), 상태 점 |
| S2-B 목록 | 상태 칩, 변수 칩, 필터, 검색, 인라인 편집 |
| S2-C 설정 | 인증 필드 동적 렌더링, 마스킹, 연결 상태 칩 |
| S3 원본 지정 | 선택지 렌더링, 선택 후 전환 |
| S4 JSON 오류 | 경로·줄 번호 표시 |
| S5 출력 전 검사 | 집계 표, 정책 라디오, 차단/통과 판정문, 버튼 라벨 변화 |
| 실행 중 잠금 | `EXPERIENCE.md` 6.4 표의 각 컨트롤 상태 |
| 배너 | 성공 자동 소멸, 오류 유지, 중복 교체 |

### 11.5 통합 테스트

```text
IT-1  파일 추가 → 탐색 → 목록 표시            (API 호출 없음)
IT-2  목 제공자로 번역 실행 → 상태 전이 확인
IT-3  검증 실패 발생 → 출력 차단 확인
IT-4  정책 변경 → 원문 유지 출력 성공
IT-5  프로젝트 저장 → 앱 재시작 → 상태 복원
IT-6  JAR 추가 → 새 키만 대기 상태
IT-7  JSON 오류 JAR 포함 → 나머지 정상 완주
IT-8  일시정지 → 재개 → 완주
```

번역 제공자는 목으로 교체합니다. **CI 에서 실제 API 를 호출하지 않습니다.**

### 11.6 코퍼스 테스트 (로컬 전용)

실제 모드 JAR 은 저작권 문제로 저장소에 넣지 않습니다.

```dart
@Tags(['corpus'])
library;

// 실행: dart test -t corpus
// 환경변수 LANGFORGE_CORPUS_DIR 에 실제 모드팩 mods 폴더 경로를 지정
```

| 항목 | 검증 |
|---|---|
| C-1 | 탐색된 namespace 개수 == 수동 확인 개수 |
| C-2 | 원본 key 집합 == 출력 key 집합 (전 namespace) |
| C-3 | 모든 출력 key 가 원본과 문자 단위 동일 |
| C-4 | 검증 통과 항목의 토큰 멀티셋이 원문과 동일 |
| C-5 | JSON 오류 JAR 이 있어도 나머지 100% 완주 |
| C-6 | 생성된 ZIP 이 8.2절 검증 통과 |
| C-7 | 산출물 전체에 API 키 문자열 0건 |
| C-8 | 처리 시간이 10.1 예산 이내 |

**이 테스트는 CI 에서 돌지 않습니다.** 릴리스 전에 로컬에서 수동 실행하고 결과를 릴리스 체크리스트에 기록합니다. CI 가 코퍼스 회귀를 잡지 못하는 것은 알려진 공백이며, 릴리스 게이트로 보완합니다.

### 11.7 골든(스크린샷) 테스트

**도입하지 않습니다** (Phase 12 결정 · ROADMAP Q4).

`golden_toolkit` 은 2023년 이후 갱신이 없어 후보에서 제외했고, 남은 후보인 `alchemist` 도 1.0 에는 넣지 않습니다.

```text
근거
├── 화면 회귀는 위젯 테스트가 이미 값으로 검증한다 (레이아웃 붕괴 · 패널 접힘 · 2.0배 텍스트)
├── 스크린샷은 Windows 폰트 렌더링 차이에 민감해서 CI 에서 거짓 실패를 만들기 쉽다
└── 1인 개발에서 골든 갱신 비용이 검출하는 결함보다 크다

재검토 조건
└── 기여자가 늘어 UI 변경을 리뷰로 걸러야 할 때
```

---

## 12. CI

### 12.1 파이프라인

```yaml
# .github/workflows/ci.yml (요지)
on: [push, pull_request]

jobs:
  verify:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter test --exclude-tags corpus
      - name: Secret scan
        run: # gitleaks 또는 동등 도구
```

| 단계 | 실패 시 |
|---|---|
| `dart format` 검사 | PR 차단 |
| `flutter analyze --fatal-infos` | PR 차단 |
| 코드 생성 후 diff 없음 | PR 차단 (생성 결과를 커밋했는지 확인) |
| 단위 + 위젯 테스트 | PR 차단 |
| 비밀값 스캔 | PR 차단 |

**빌드 산출물 업로드와 릴리스는 자동화하지 않습니다.** 수동으로 만들어 GitHub Releases 에 올립니다.

### 12.2 분석 설정

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore   # freezed
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - prefer_final_locals
    - unawaited_futures
    - avoid_slow_async_io
    - only_throw_errors
    - use_build_context_synchronously
```

---

## 13. 로깅

### 13.1 구성

```text
%APPDATA%\LangForge\logs\
├── langforge.log       현재
├── langforge.1.log     직전
└── ... 최대 5개, 각 5MB

앱 내 로그 뷰어에서 최근 항목을 보고 파일 위치를 열 수 있다.
```

| 수준 | 용도 |
|---|---|
| `SEVERE` | 처리하지 못한 예외, 데이터 손실 위험 |
| `WARNING` | 입력 거부, 검증 실패, API 재시도 |
| `INFO` | 파일 추가, 탐색 완료, 번역 시작/완료, 출력 완료 |
| `FINE` | 배치 단위 진행 (기본 비활성. 설정에서 켬) |

### 13.2 기록하지 않는 것

```text
API Key · Client Secret · 서비스 계정 비밀키
Authorization 헤더 전체
번역 요청 본문 전체 (FINE 에서도 길이와 개수만)
사용자 홈 경로의 사용자명 부분  →  %USERPROFILE% 로 치환
```

모든 기록이 `SensitiveFilter.scrub()` 를 통과합니다.

### 13.3 사용자 로그 (앱 내)

기술 로그와 별개로, 사용자가 이해할 수 있는 작업 이력을 보여줍니다.

```text
14:02  입력 파일 180개 추가
14:02  namespace 214개 · 언어 파일 397개 발견
14:03  JSON 검사 — 정상 213 · 오류 1 (example)
14:05  번역 시작 — Gemini · 대기 48,312건
14:31  번역 완료 — 성공 48,309 · 검증 실패 3
14:33  출력 완료 — KO_Translation_Pack.zip
```

---

## 14. 배포

### 14.1 형태

| 항목 | 내용 |
|---|---|
| 배포 형태 | **포터블 ZIP.** 압축을 풀고 `langforge.exe` 실행 |
| 채널 | GitHub Releases |
| 서명 | 없음 (MVP). Windows SmartScreen 경고가 뜰 수 있음을 README 에 안내 |
| 자동 업데이트 | 없음 |
| 설치 관리자 | 없음 |

포터블을 선택한 이유: 코드 서명 인증서 비용이 없고, 설치 관리자가 없으면 사이드로딩 마찰이 줄며, 사용자가 폴더째 지우면 완전히 제거됩니다.

### 14.2 빌드

```powershell
flutter build windows --release
powershell -ExecutionPolicy Bypass -File tool/package_portable.ps1
```

`tool/package_portable.ps1` 이 아래 ZIP 을 만듭니다. 스크립트는 `pubspec.yaml` 의 `version` 과
`lib/app_version.dart` 의 `appVersion` 이 다르면 포장하지 않고 실패합니다 — 보고서에 찍히는
버전과 배포본 버전이 갈라지는 것을 막습니다.

ZIP 에 포함할 것:

```text
LangForge-{version}-windows-x64.zip
├── langforge.exe
├── flutter_windows.dll
├── (플러그인 DLL 들)
├── data/
│   ├── flutter_assets/
│   └── icudtl.dat
├── LICENSE                 MIT
├── THIRD_PARTY_LICENSES.md 의존성 및 폰트 라이선스 고지
└── README.txt              실행 방법 · SmartScreen 안내 · API 키 발급 안내
```

### 14.3 릴리스 체크리스트

```text
[ ] 버전 번호를 pubspec.yaml 과 태그에 반영
[ ] flutter analyze 무경고
[ ] 전체 테스트 통과 (corpus 제외)
[ ] 코퍼스 테스트 로컬 실행 통과 (C-1 ~ C-8)
[ ] 실제 Minecraft 3개 버전에서 출력 팩 적용 확인 (U1 ~ U5)
[ ] 산출물 전체에 API 키 문자열 0건 확인
[ ] THIRD_PARTY_LICENSES.md 갱신
[ ] 릴리스 노트 작성
[ ] 포터블 ZIP 을 깨끗한 Windows 에서 실행 확인 (Flutter SDK 없는 환경)
```

### 14.4 데이터 호환성

```text
프로젝트 파일(.lfproj) 은 상위 호환을 보장하지 않는다.
  더 새 버전으로 만든 프로젝트는 구버전에서 열 수 없다 (거부).
마이그레이션은 항상 백업본을 먼저 만든다.
릴리스 노트에 스키마 변경 여부를 명시한다.
```

---

## 15. 접근성 구현

`DESIGN.md` 14절의 기준을 코드로 강제합니다.

| 항목 | 구현 |
|---|---|
| 시맨틱 | 모든 대화형 위젯에 `Semantics(label:)`. 아이콘 버튼은 `tooltip` 필수 |
| 상태 알림 | 번역 상태 변경 시 `SemanticsService.announce()` |
| 포커스 순서 | `FocusTraversalGroup` 으로 패널별 논리 순서 지정 |
| 포커스 표시 | 모든 커스텀 위젯에 `Focus` + 시각 표시. 기본 제거 금지 |
| 모달 포커스 | `FocusScope` 로 트랩. 닫을 때 `previousFocus` 복원 |
| 클릭 영역 | 시각 크기와 무관하게 `MaterialTapTargetSize` 상당의 최소 영역 보장 |
| 모션 감소 | `MediaQuery.disableAnimationsOf(context)` 확인 후 애니메이션 생략 |
| 텍스트 배율 | `MediaQuery.textScalerOf` 를 존중. 레이아웃이 깨지지 않는지 위젯 테스트에서 2.0배까지 확인 |
| 대비 | `DESIGN.md` 2.3 · 3절의 보정값 사용. 하드코딩 금지 |

---

## 16. 열린 질문

| # | 질문 | 결정 시점 |
|---|---|---|
| Q1 | 자리표시자 `⁣LF0⁣` (U+2063) 를 각 엔진이 실제로 보존하는지 — 프로브 골격 `tool/probe_placeholder.dart`. 실키 `--live` 결과로 아래 표를 채운다. 실패 엔진은 대체 형태(`placeholderStyle`) 탐색 | Phase 8 (실측 대기) |

**Q1 실측 표** (`dart run tool/probe_placeholder.dart --live` 후 갱신)

| Provider | unit (U+2063) 통과율 | 비고 |
|---|---|---|
| gemini | — (미실측) | |
| deepl | — (미실측) | 실패 시 `tag_handling:xml` + `<lf i="n"/>` 후보 |
| google | — (미실측) | 실패 시 `format:html` + `<span translate="no">` 후보 |
| papago | — (미실측) | 실패 시 변수 포함 문자열 미지원으로 제외 검토 |
| Q2 | Gemini 배치 크기 최적값. 원문 에코 재발 완화로 임시 25 적용. 응답 품질·속도·개수 불일치율·에코율을 실측해 재조정 | Phase 3 |
| Q3 | 검색이 `LIKE` 로 충분한지, FTS5 가 필요한지 | Phase 1 실측 후 |
| Q4 | Isolate 풀 크기 4 가 적절한지 (IO 바운드 비중에 따라 다름) | Phase 1 실측 후 |
| Q5 | ~~DeepL·Google·Papago 의 현재 엔드포인트와 인증 방식~~ → Phase 8.1 에서 확정. 아래 6.2절·`providers.json` 참조 | ✅ Phase 8 |
| Q7 | ~~코드 서명 인증서를 도입할 것인가 (SmartScreen 경고 제거)~~ → **도입하지 않음.** 무료 MIT 로컬 도구에 연간 인증서 비용을 얹지 않는다. 14.1 대로 서명 없는 포터블 ZIP 을 배포하고 SmartScreen 안내를 README 에 유지한다 | ✅ Phase 12 |
| Q8 | `.lfproj` 를 SQLite 그대로 둘지, 압축 컨테이너로 감쌀지 | Phase 6 |
