# MOBILE.md — LangForge Android

> Phase 13 (모바일) 의 선결 과제 조사 결과와 결정 사항입니다.
> 화면 구성은 `DESIGN.md` 6.3 · 목업 `resources/LangForge Mobile (standalone).html`,
> 흐름은 `EXPERIENCE.md`, 공통 구현 규칙은 `TECHNICAL.md` 를 따릅니다.

- 문서 버전: 1.0
- 최종 수정: 2026-08-08
- 범위: **Android 만**. iOS 는 이 문서의 대상이 아닙니다
- 기준 목업: `resources/LangForge Mobile (standalone).html` (390 × 844)

---

## 1. Phase 13.1 — 선결 과제 조사 및 결정

`ROADMAP.md` Phase 13 이 착수 조건으로 건 5개 과제입니다. 각 항목은
**조사 → 결정 → 근거 → 구현 위치** 순으로 적습니다.

### 1.1 파일 접근 — Android SAF

```text
문제
  데스크톱은 `.minecraft/mods` 라는 알려진 절대 경로가 있고, dart:io 로 바로 읽는다.
  Android 에는 그런 경로가 없다. Android 10(API 29) 부터 Scoped Storage 가 강제되어
  앱은 자기 샌드박스 밖의 파일을 경로로 열 수 없다. 사용자가 고른 것만
  content:// URI 로 접근할 수 있다.
```

**결정 — 입력은 `file_picker` 의 캐시 복사본 경로를 쓴다. 새 SAF 플러그인을 붙이지 않는다.**

`file_picker` 11.x 는 Android 에서 `pickFiles` 로 고른 파일을 **앱 캐시 디렉터리로
복사한 뒤 실제 경로를 돌려줍니다**(공식 문서: "Since 2.0.0, all picked files are
cached"). 즉 `PlatformFile.path` 는 Android 에서도 dart:io 로 열리는 진짜 경로입니다.

```text
그래서
  ScanController.addFiles(List<String> paths) 를 포함한 탐색 파이프라인 전체가
  플랫폼 분기 없이 그대로 동작한다. 아카이브 리더·아이솔레이트·해시 계산이
  content:// 를 몰라도 된다. 이것이 별도 SAF 플러그인을 도입하지 않는 이유다.

대가
  JAR 한 벌이 캐시에 복사되므로 저장 공간을 두 배로 쓴다. 1.5절에서 처리한다.
```

**결정 — 폴더 추가(`mods` 폴더 통째로)는 Android 에서 제공하지 않는다.**

`FilePicker.getDirectoryPath()` 는 Android 에서 `content://…/tree/…` 를 돌려줍니다.
이것은 경로가 아니라 URI 이고 `Directory(...)` 로 열리지 않습니다. 폴더를 지원하려면
SAF 트리를 재귀 순회하는 별도 계층(`DirectoryReader` 의 두 번째 구현)이 필요한데,
얻는 것에 비해 표면적이 큽니다. 모바일에서는 **다중 파일 선택**(`allowMultiple: true`)
으로 대체합니다 — 사용자는 파일 선택기에서 `mods` 폴더에 들어가 전체 선택할 수 있습니다.

**결정 — 출력은 `ACTION_CREATE_DOCUMENT` 단일 파일 저장만 지원한다.**

`FilePicker.saveFile(bytes: …)` 가 Android 에서 `ACTION_CREATE_DOCUMENT` 를 띄우고
바이트를 직접 씁니다. 따라서 모바일에서 고를 수 있는 출력 형식은
**통합 리소스팩 ZIP 하나**로 제한합니다. 나머지 3종(namespace별 JSON · 전체 경로 보존
JSON · 모드별 개별 리소스팩)은 여러 파일을 디렉터리에 쓰므로 SAF 트리 쓰기가
필요합니다. UI 에서 비활성으로 두고 사유를 표시합니다.

| | 데스크톱 | Android |
|---|---|---|
| 파일 추가 | 파일 선택 + 폴더 선택 + 드래그 앤 드롭 | 파일 다중 선택만 |
| 프로젝트 열기 | `.lfproj` 경로 | `.lfproj` 캐시 복사본 경로 |
| 프로젝트 저장 | 임의 경로 | 앱 문서 디렉터리 (`path_provider`) |
| 내보내기 | 디렉터리 선택 → 4종 형식 | 파일 저장 → 통합 ZIP 만 |

구현: `lib/infrastructure/platform/file_access.dart`

---

### 1.2 대용량 JAR 메모리 제약

```text
문제
  데스크톱 예산은 1.5GB (TECHNICAL.md). Android 는 기기별 힙 상한이 있고
  저사양 기기는 프로세스당 192MB 수준이다. 상한을 넘으면 OOM 킬이며
  잡을 수 있는 예외가 아니다.
```

**결정 — 플랫폼별 예산 프로필을 하나의 상수 묶음으로 두고, 한도를 낮춘다.**

| 항목 | 데스크톱 | Android | 이유 |
|---|---|---|---|
| 입력 파일 상한 | 512 MB | 128 MB | 힙에 올리는 단위가 아카이브 1개 |
| 아카이브 항목 상한 | 64 MB | 16 MB | lang JSON 은 실제로 수 MB 를 넘지 않음 |
| 누적 팽창 상한 | 2 GB | 384 MB | zip bomb 방어선을 힙 안쪽으로 |
| lang JSON 상한 | 32 MB | 8 MB | 상동 |
| 탐색 동시성 | min(CPU, 4) | 2 | 아이솔레이트마다 아카이브 버퍼를 든다 |
| 엔트리 페이지 | 200행 | 100행 | 리스트가 드는 행 수 |
| 번역 동시 요청 | 제공자 한도 | min(제공자 한도, 2) | 응답 버퍼 + 재시도 큐 |
| DB flush 청크 | 1000행 | 300행 | 트랜잭션 버퍼 |

한도를 넘긴 파일은 **거부 사유와 함께 목록에 남깁니다**. 조용히 빠지지 않습니다
(`TECHNICAL.md` 의 거부 규칙 그대로).

구현: `lib/infrastructure/platform/memory_budget.dart`

---

### 1.3 백그라운드 전환 시 번역 작업 유지

```text
문제
  Android 는 백그라운드 앱의 프로세스를 언제든 죽인다. 3분짜리 번역 중에
  홈 버튼을 누르면 큐가 통째로 사라질 수 있다.
```

**결정 — Foreground Service 를 도입하지 않는다. 대신 생명주기 이벤트에서
일시정지 + 체크포인트 저장을 한다.**

근거:

```text
Foreground Service 를 쓰면
  ├── 상시 알림이 필요하고 (Android 13+ POST_NOTIFICATIONS 권한)
  ├── FOREGROUND_SERVICE_DATA_SYNC 권한과 Play 정책 심사 대상이 되고
  └── 번역 러너를 Dart 아이솔레이트에서 플랫폼 서비스로 옮겨야 한다 — XL 급 재작업

그런데 이 앱의 작업은 이미 재개 가능하다
  ├── 완료된 항목은 DB 에 있고, 상태(done/kept/cache)로 남는다
  ├── 큐는 status = wait 인 행의 집합일 뿐이다 (TranslationRunner)
  └── 즉 프로세스가 죽어도 "이어서 시작" 하면 남은 wait 만 다시 돈다
```

따라서 `AppLifecycleState.paused` 에서:

1. 실행 중이면 `TranslationController.pause()` — 인플라이트 응답까지만 받는다
2. `saveTranslationCheckpoint()` 로 저장 (이미 pause 경로에 있음)
3. 복귀(`resumed`) 시 자동 재개하지 않는다. 사용자가 버튼을 눌러 재개한다

자동 재개하지 않는 이유: 모바일 데이터·과금이 걸린 API 호출이므로 사용자가 모르는
사이에 다시 도는 것이 더 나쁩니다.

구현: `lib/presentation/mobile/mobile_shell.dart` 의 `WidgetsBindingObserver`

---

### 1.4 저장 공간 부족 처리

```text
문제
  파일 선택마다 JAR 복사본이 캐시에 쌓인다(1.1). 200MB 모드팩을 두어 번 넣으면
  캐시만 수백 MB 다. 저장 공간이 차면 DB 쓰기가 SqliteException 으로 실패한다.
```

**결정 세 가지**

1. **탐색이 끝나면 캐시를 즉시 비운다.** 탐색은 JAR 을 한 번 읽어 DB 로 옮기는
   작업이고, 그 뒤에는 원본이 필요 없습니다. `FilePicker.clearTemporaryFiles()` 를
   `addFiles` 완료 직후에 호출합니다.
   - 대가: 재탐색(rescan)이 Android 에서는 동작하지 않습니다. 원본이 없기 때문입니다.
     모바일 UI 에는 재탐색 버튼을 두지 않고, 파일을 다시 고르게 합니다.
2. **선택 시점에 크기를 먼저 본다.** Dart 에는 여유 공간을 묻는 API 가 없고,
   그것만을 위해 플러그인을 하나 더 붙이지 않기로 했습니다. 대신 `PlatformFile.size`
   를 보고 **개별 파일 상한(128MB)** 과 **한 번에 가져오는 합계 상한(256MB)** 을
   선택 단계에서 강제합니다. 넘긴 파일은 사유와 함께 목록에 남고, 나머지는 진행합니다.
3. **DB 쓰기 실패는 저장 공간 문구로 바꿔 보여준다.** 원문 SQLite 오류를 그대로
   띄우면 사용자가 할 수 있는 일이 없습니다.

구현: `lib/infrastructure/platform/file_access.dart`

---

### 1.5 `flutter_secure_storage` 의 Android Keystore 동작

```text
조사
  flutter_secure_storage 10.x 는 Android 에서 EncryptedSharedPreferences 를 쓰고,
  키는 AndroidKeyStore 에 둔다. minSdk 23 이상이면 하드웨어 키스토어를 쓴다.
```

**결정 — 기존 `CredentialStore` 를 그대로 쓴다. 다만 실패 폴백 경로가 이미 있어야 한다.**

`EngineSettings.usesSessionOnlyStorage` 가 이미 "OS 자격 증명 저장소가 키를
거부했다"는 상태를 들고 있고(AC-11.4), 그 경우 세션 메모리에만 둡니다. Android 에서
Keystore 가 실패하는 실제 사례는 다음과 같고, 모두 이 경로로 흡수됩니다:

```text
├── 기기 백업/복원 후 Keystore 키가 무효화됨 → 읽기 실패 → 재입력 요구
├── 사용자가 화면 잠금을 해제하면서 키가 폐기됨 → 동일
└── 커스텀 ROM 에서 하드웨어 키스토어 미지원 → 소프트웨어 폴백, 동작함
```

추가로 필요한 것: `android/app/build.gradle.kts` 의 `minSdk` 를 **23** 으로 명시.
Flutter 기본값(`flutter.minSdkVersion`)은 21 이며, 21~22 에서는
`EncryptedSharedPreferences` 를 못 씁니다.

---

## 2. 화면 구조 (13.2 · 13.3 · 13.6 · 13.7)

목업에서 실측한 값입니다. `DESIGN.md` 0.4 에 따라 **HTML 이 우선**하고, 이 표가
Flutter 구현의 기준입니다.

### 2.1 뼈대

```text
┌─────────────────────────┐
│ 헤더 (아이콘·제목·부제·⚙) │  54
├─────────────────────────┤
│ 진행 바                  │   3
├─────────────────────────┤
│                         │
│  탭 내용 (스크롤)         │  가변
│                         │
├─────────────────────────┤
│ 실행 바 (편집 탭에서만)    │  64  = 10 + 44 + 10
├─────────────────────────┤
│  파일  편집  문제  출력   │  66
└─────────────────────────┘
```

| 요소 | 값 | 목업 근거 |
|---|---|---|
| 헤더 높이 | 54 | `height:54px` |
| 헤더 좌우 패딩 | 18 | `padding:0 18px` |
| 앱 마크 | 22 × 22, 반경 6 | `width:22px;height:22px;border-radius:6px` |
| 헤더 설정 버튼 | 32 × 32, 반경 9 | `width:32px;height:32px;border-radius:9px` |
| 진행 바 | 높이 3, 트랙 `#222` | `height:3px;background:#222` |
| 하단 탭 | 높이 66 | `height:66px` |
| 탭 배지 | 최소폭 20, 높이 20, 반경 10 | `min-width:20px;height:20px;border-radius:10px` |
| 실행 버튼 | 높이 44, 반경 11 | `height:44px;border-radius:11px` |
| 일시정지 버튼 | 84 × 44 | `width:84px;height:44px` |

### 2.2 밀도 (13.6)

| 항목 | 데스크톱 | 모바일 | 근거 |
|---|---|---|---|
| 최소 클릭 영역 | 24 | **44** | `DESIGN.md` 6.3 |
| 체크박스 | 15 | **19** | `width:19px;height:19px;border-radius:5px` |
| 토글 트랙 | 36 × 20 | **40 × 23** | `width:40px;height:23px` |
| 토글 손잡이 | 16 | **19** | `width:19px;height:19px` |
| 라디오 | 16 | 16 | `width:16px;height:16px` |
| 옵션 행 | — | 반경 12 · 패딩 14 | `border-radius:12px;padding:14px` |
| 카드 반경 | 9 | **13** | `border-radius:13px` |
| 입력 높이 | 30 | **48** (인증 필드 44) | `height:48px` / `height:44px` |
| 리스트 행 패딩 | 6/10 | **14 / 16** | `padding:14px 16px` |

### 2.3 Bottom Sheet 3종 (13.3)

| 시트 | 높이 | 목업 근거 |
|---|---|---|
| 편집 | 내용에 맞춤 | `bottom:0` + 자동 |
| 원본 지정 | 내용에 맞춤 | 상동 |
| 설정 | `top:96` 고정, 내부 스크롤 | `top:96px` |

공통: 배경 `#1E1E1E`(= `bgBar`), 상단 테두리 `#333`(= `borderControl`),
상단 반경 22, 패딩 `10 18 26`, 손잡이 38 × 4 반경 3, 스크림 `rgba(8,8,8,.68)`.

### 2.4 토스트 (13.7)

```text
좌우 16 · 하단 104 (하단 탭 66 + 여유 38)
패딩 13 15 · 반경 13 · 배경 #252525 · 테두리 #383838
아이콘 22 × 22 반경 7 — 성공 ✓ accent / 실패 ! danger
제목 12.5px w600 · 본문 11.5px 색 #9A9A9A
닫기 버튼 24 × 24 반경 7
```

---

## 3. 테스트 범위와 알려진 공백

지금 있는 것:

```text
test/infrastructure/memory_budget_test.dart    플랫폼 예산 · ArchiveLimits (1.2)
test/application/mobile_ui_controller_test.dart 탭·시트·토스트 상태 (13.2·13.3·13.7)
test/domain/export_gate_aggregate_test.dart     집계 게이트가 행 기반 게이트와 동일한 판정을 내는지
test/widget/mobile_controls_test.dart           44px 클릭 영역 · 하단 탭 · 배지 접근성 (13.6)
```

**공백 — 셸 전체 위젯 테스트가 없습니다.**

모바일 탭·시트는 파라미터가 아니라 프로바이더에서 데이터를 읽으므로, 이들을 한꺼번에
검증하려면 실제 `AppDatabase` 위에 `MobileShell` 을 띄워야 합니다. 시도했으나 두 가지에
막혔습니다:

```text
├── pumpAndSettle 이 끝나지 않는다 — 셸이 항상 무언가를 대기 중(drift watch)이라
│   프레임이 비는 시점이 없다
└── 테스트가 끝나도 Timer 가 남고(!timersPending), tearDown 의 db.close() 가
    8분간 반환하지 않는다 — ProjectSessionController 가 자기 인메모리 DB 를
    컨테이너 폐기 시점까지 들고 있기 때문
```

이것은 모바일 코드의 결함이 아니라 **테스트 하니스의 공백**입니다. 세션/자동 저장 타이머를
가짜 시계 아래에서 돌릴 수 있는 하니스(`test/support/` 확장)가 먼저 필요하고, 그건 데스크톱
테스트에도 똑같이 쓰이므로 Phase 13 이 아니라 별도 작업으로 다뤄야 합니다.

---

## 4. 남은 것 / 하지 않기로 한 것

```text
[ 하지 않음 ] Foreground Service          — 1.3
[ 하지 않음 ] SAF 트리 재귀 순회 (폴더 추가)  — 1.1
[ 하지 않음 ] 모바일 재탐색                 — 1.4
[ 하지 않음 ] 모바일 용어집 편집 화면        — 데스크톱 전용으로 유지
[ 하지 않음 ] 모바일 충돌 해결 화면          — 문제 탭에서 데스크톱으로 안내
[ 남음 ]     셸 전체 위젯 테스트             — 3절
[ 이후 ]     Phase 14 에서 iOS 대응 여부 결정
```
