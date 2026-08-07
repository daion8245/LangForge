# AGENTS.md — LangForge

이 저장소에서 작업하는 AI 에이전트가 지켜야 할 규칙입니다. 코드를 쓰기 전에 읽으세요.

---

## 1. 이 프로젝트가 무엇인가

**LangForge** 는 Minecraft 모드 JAR 과 리소스팩에서 언어 파일(`assets/{namespace}/lang/{code}.json`)을 자동으로 찾아 번역하고, 게임에 바로 적용되는 리소스팩으로 내보내는 **로컬 데스크톱 도구**입니다.

```text
플랫폼      Windows 데스크톱 (MVP). 모바일은 1.0 이후
기술        Flutter + Riverpod + Drift(SQLite)
번역        BYOK. MVP 는 Gemini 1종. 어댑터 인터페이스는 4종 기준
배포        무료 · MIT · GitHub Releases 포터블 ZIP
서버        없음. 텔레메트리 없음. 계정 없음
```

**핵심 처리 흐름**

```text
JAR/ZIP/폴더 입력
  → 안전 검사 (경로 탈출 · 압축 폭탄 · 해시)
  → assets/*/lang/*.json 전체 탐색
  → JSON 사전 검사 (namespace 단위 오류 격리)
  → key/value 분리 — key 는 절대 건드리지 않음
  → 변수·서식 코드를 자리표시자로 치환
  → value 만 번역 API 로 전송
  → 자리표시자 복원 + 멀티셋 검증
  → 기존 번역·사용자 수정 우선 병합
  → 출력 전 검사 (차단 판정)
  → JSON / 리소스팩 / ZIP 출력
```

---

## 2. 절대 규칙

이것들을 깨면 제품이 실패합니다. 성능·편의성·구현 편의보다 항상 우선합니다.

### 2.1 데이터 안전

```text
✗ JSON key 를 변경하지 않는다. 어떤 단계에서도.
✗ key 를 번역 API 요청에 포함하지 않는다. TranslationProvider 인터페이스에 key 타입이 들어가면 안 된다.
✗ 입력 JAR·ZIP 을 수정하지 않는다. 읽기 전용으로만 연다. 쓰기 핸들을 열지 않는다.
✗ 기존 번역과 사용자 수정을 자동 번역으로 덮어쓰지 않는다.
✗ 검증에 실패한 번역 값을 저장하지 않는다.
✗ key 순서를 바꾸지 않는다. 원본 JSON 순서를 keyOrder 로 보존한다.
```

### 2.2 보안

```text
✗ API 키를 로그·프로젝트 파일·보고서·오류 메시지에 남기지 않는다.
✗ API 키를 URL 쿼리 파라미터로 보내지 않는다. 항상 헤더로.
✗ 인증서 검증을 우회하지 않는다 (badCertificateCallback 금지).
✗ http:// 요청을 만들지 않는다. HTTPS 만.
✗ 번역 API 와 사용자가 명시적으로 여는 링크 외에 외부 통신을 추가하지 않는다.
✗ 텔레메트리·사용 통계·자동 오류 리포팅을 추가하지 않는다.
✗ 압축 항목 경로를 세그먼트 단위로 검사하지 않고 추출하지 않는다.
✓ 모든 로그 기록과 보고서 생성은 SensitiveFilter.scrub() 을 통과한다.
```

### 2.3 아키텍처

```text
✗ domain/ 계층에서 dart:io · Flutter · 외부 패키지를 import 하지 않는다.
   domain 은 순수 Dart 다. 이것이 90% 커버리지를 가능하게 한다.
✗ 의존 방향을 역류시키지 않는다.
   presentation → application → domain → (없음)
   infrastructure 는 domain 의 인터페이스를 구현할 뿐 domain 이 infrastructure 를 참조하지 않는다.
✗ UI 스레드에서 ZIP 해제 · JSON 파싱 · SHA-256 계산 · ZIP 생성을 하지 않는다.
✗ 워커 isolate 에서 DB 에 쓰지 않는다. 메인 isolate 에서만 쓴다.
✗ 모듈에 두 가지 책임을 주지 않는다. TECHNICAL.md 2.3 의 책임 표를 지킨다.
```

### 2.4 오류 격리

```text
✓ 하나의 namespace 에서 오류가 나도 다른 namespace 작업은 계속된다.
✓ 배치 안의 일부 항목이 실패해도 나머지는 저장된다.
✓ 재시도는 지수 백오프 + 시도 상한이 있다. 무한 재시도하지 않는다.
✗ 예외를 삼키지 않는다. 반드시 사용자에게 보이거나 로그에 남는다.
✗ catch (e) {} 로 빈 블록을 만들지 않는다.
```

### 2.5 디자인 시스템

```text
✗ 색 · 크기 · 간격 · 반경 · 글꼴을 하드코딩하지 않는다.
   금지  Color(0xFF4FC0A1) · EdgeInsets.all(14) · TextStyle(fontSize: 12.5) · BorderRadius.circular(9)
         SizedBox(height: 46) · Icon(size: 16) · width >= 1300
   허용  context.c.accent · EdgeInsets.all(context.s.space7) · context.t.bodySm · context.r.md
         context.d.topBar · context.d.iconMd · width >= context.d.breakpointWide
   크기 토큰 목록은 DESIGN.md 5.5.
✗ 색만으로 상태를 구분하지 않는다. 항상 텍스트 라벨을 함께 표시한다.
✗ 목록을 ListView(children: [...]) 로 만들지 않는다. 항상 builder 로 가상화한다.
   이 앱은 항목 48,000개를 다룬다.
✓ 아이콘만 있는 버튼에는 툴팁을 붙인다.
```

---

## 3. 작업 절차

### 3.1 시작하기 전에

```text
1. ROADMAP.md 에서 지금이 어느 Phase 인지 확인한다.
2. 그 Phase 의 작업 항목과 완료 조건(AC 번호)을 읽는다.
3. 관련 AC 를 EXPERIENCE.md 7절에서 찾아 정확한 요구를 확인한다.
4. 화면 작업이면 DESIGN.md 의 해당 컴포넌트 명세를 읽는다.
5. 구현 방식이 TECHNICAL.md 에 이미 정해져 있는지 확인한다.
```

**문서에 이미 결정된 것을 다시 결정하지 마세요.** 문서와 다르게 구현해야 할 이유를 발견하면, 코드를 바꾸기 전에 문서를 먼저 고치고 사용자에게 알리세요.

### 3.2 구현할 때

```text
✓ 한 번에 하나의 작업 항목만 한다. Phase 를 통째로 구현하지 않는다.
✓ domain 로직은 테스트를 함께 쓴다. 나중에 몰아 쓰지 않는다.
✓ 새 의존성을 추가하기 전에 TECHNICAL.md 1.2 의 '쓰지 않는 것' 목록을 확인한다.
✓ 새 의존성이 필요하면 사용자에게 이유와 대안을 함께 알린다.
✓ 기존 코드의 패턴을 따른다. 새 패턴을 도입하려면 이유를 설명한다.
```

### 3.3 완료 판정

작업이 끝났다고 말하기 전에 전부 확인하세요.

```text
[ ] 해당 AC 번호의 요구를 실제로 만족하는가
[ ] flutter analyze 무경고
[ ] dart format 통과
[ ] 새로 쓴 domain 코드에 단위 테스트가 있는가
[ ] 기존 테스트가 전부 통과하는가 (회귀)
[ ] 하드코딩된 색·크기·간격이 없는가
[ ] domain 계층에 dart:io / Flutter import 가 없는가
[ ] 로그·오류 메시지에 API 키가 새어나갈 경로가 없는가
```

**테스트를 실행하지 않고 "완료"라고 하지 마세요.**

### 3.4 막혔을 때

```text
✓ 문서에 답이 없으면 사용자에게 묻는다.
✓ 추측으로 결정하고 진행하지 않는다. 특히 2절의 절대 규칙과 관련된 것.
✓ 여러 접근이 가능하면 선택지와 트레이드오프를 제시한다.
✗ 요구사항을 임의로 축소해서 "됐다"고 하지 않는다.
✗ 테스트가 실패하면 테스트를 고쳐서 통과시키지 않는다. 코드를 고친다.
```

---

## 4. 코드 규칙

### 4.1 언어

```text
문서 (docs/*.md)         한국어
UI 에 표시되는 문구        한국어
커밋 메시지               한국어
코드 식별자 (변수·함수·클래스·파일명)   영어
코드 주석                 영어
로그 메시지               영어 (사용자 로그는 한국어)
```

### 4.2 네이밍

```text
파일        snake_case.dart
클래스      PascalCase
변수·함수    lowerCamelCase
상수        lowerCamelCase (SCREAMING_CASE 쓰지 않음)
private     _leadingUnderscore

디자인 시스템 위젯    Lf 접두사 (LfButton · LfStatusChip · LfTreeRow)
Drift 테이블         복수형 PascalCase (Entries · Namespaces · InputFiles)
Riverpod 프로바이더   xxxProvider
```

### 4.3 파일 배치

`TECHNICAL.md` 2.2 의 디렉터리 구조를 따릅니다. 새 파일을 만들기 전에 그 구조에 이미 자리가 있는지 확인하세요.

```text
순수 로직 · 정책 · 검증        →  lib/domain/
유스케이스 · 상태 프로바이더     →  lib/application/
DB · 파일 · 네트워크 · Isolate  →  lib/infrastructure/
화면 · 위젯                    →  lib/presentation/
디자인 토큰                    →  lib/app/theme/
```

### 4.4 주석

```text
✓ 코드가 표현할 수 없는 제약을 설명할 때만 쓴다.
  예: 토큰 정규식의 분기 순서가 왜 중요한지
✗ 코드를 그대로 옮겨 쓰지 않는다.
  금지: // Increment the counter
✗ 변경 이유·작업 이력을 코드에 남기지 않는다.
  금지: // Fixed bug where...  //  Changed from X to Y
✓ 공개 API 에는 dartdoc(///) 을 쓴다.
```

### 4.5 비동기

```text
✓ 모든 Future 에 await 또는 unawaited() 를 명시한다.
✓ 취소 가능한 작업에는 CancellationToken 을 전파한다.
✓ BuildContext 를 await 이후에 쓰지 않는다 (mounted 확인 필수).
✓ 진행 보고는 100ms 이상 간격으로 스로틀한다.
```

### 4.6 상태

```text
✓ Riverpod 프로바이더로만 상태를 공유한다. 전역 변수·싱글턴을 만들지 않는다.
✓ 비동기 상태는 AsyncValue 로 표현한다. isLoading 불리언을 따로 두지 않는다.
✓ 열거형은 DB 에 문자열로 저장한다. 정수 인덱스로 저장하지 않는다
  (열거형 순서가 바뀌면 데이터가 깨진다).
```

---

## 5. 이 프로젝트에서 자주 틀리는 것

과거에 실제로 문제가 됐거나, 구조적으로 틀리기 쉬운 지점입니다.

### 5.1 토큰 정규식의 분기 순서

`lib/domain/protection/token_pattern.dart` 의 분기 순서는 **의미를 가집니다.** 알파벳순이나 보기 좋게 재배열하지 마세요.

```text
%% 를 %s 뒤에 두면           →  %% 가 %s 로 오인된다
§x HEX 를 § 뒤에 두면        →  §x§F§F§A§A§0§0 이 토큰 7개로 쪼개진다
%1$s 를 %s 뒤에 두면          →  위치 지정 인자가 깨진다
{{name}} 을 {name} 뒤에 두면  →  이중 중괄호가 쪼개진다

올바른 순서: %% → §x HEX → § 단일 → %1$s → %s → ${} → {{}} → {} → 이스케이프
```

### 5.2 ZIP 구조

```text
✗ ZIP 안에 팩 이름 폴더가 한 겹 더 있으면 Minecraft 가 인식하지 못한다.
   틀림  Pack.zip/Pack/pack.mcmeta
   맞음  Pack.zip/pack.mcmeta
✗ Windows 에서 만들면 경로 구분자가 \ 가 되기 쉽다. ZIP 은 / 를 요구한다.
✓ 출력 후 반드시 verifyPackZip() 으로 다시 열어서 확인한다.
```

### 5.3 0으로 나누기

```text
✗ 캐시 적중률에 NaN% · Infinity · 빈 문자열을 표시하지 않는다.
✓ 대상 항목이 0개면 '—' 를 표시한다.
   진행률 · 비율 · 평균을 계산하는 모든 곳에 이 규칙이 적용된다.
```

### 5.4 경로 탈출 검사

```text
✗ contains('..') 만으로는 부족하다.
   foo..bar 는 안전한데 거부되고, 인코딩된 형태는 통과할 수 있다.
✓ 세그먼트 단위로 split('/') 해서 '..' 인 세그먼트를 찾는다.
✓ 역슬래시 정규화 · 절대 경로 · 드라이브 문자 · UNC · 제어 문자를 함께 검사한다.
   TECHNICAL.md 4.4 의 isSafeEntryPath 구현을 그대로 쓴다.
```

### 5.5 검증을 신뢰로 대체하기

```text
✗ 프롬프트에 "자리표시자를 보존하라"고 썼으니 보존될 것이라 가정하지 않는다.
✓ LLM 이든 규칙 기반 번역기든, 결과는 항상 멀티셋 검증을 통과해야 한다.
✓ 응답 항목 개수가 요청과 다르면 즉시 실패 처리하고 배치를 분할해 재시도한다.
```

### 5.6 대규모를 잊기

```text
이 앱은 JAR 180개 · namespace 214개 · 키 48,000개를 다룬다.

✗ 항목을 한 행씩 DB 에 insert 하면 수 분이 걸린다. 1,000행 배치로 넣는다.
✗ 전체 목록을 메모리에 올리지 않는다. 페이지네이션으로 200행씩 조회한다.
✗ 200MB JAR 을 통째로 메모리에 올리지 않는다. 스트리밍으로 필요한 항목만 읽는다.
✗ 모든 namespace 를 앱 시작 시 파싱하지 않는다. 클릭할 때 지연 로딩한다.
```

### 5.7 기존 번역을 대기 상태로 되돌리기

```text
✗ 재탐색이나 파일 추가가 기존 번역·사용자 수정을 wait 로 되돌리면 안 된다.
   이게 깨지면 사용자 B 의 핵심 요구가 무너진다 (AC-10.7).
✓ 병합 우선순위(TECHNICAL.md 7.1)를 순수 함수로 유지하고 전수 테스트한다.
```

### 5.8 모드 ID 로 추측하기

```text
✗ 파일명 Quark-4.0-1.20.1.jar 에서 'quark' 를 추출해 namespace 로 쓰지 않는다.
   하나의 JAR 에 namespace 가 여러 개 있고, 파일명과 다를 수 있다.
✓ assets/{namespace}/lang/ 이라는 실제 경로만 본다.
```

---

## 6. 문서 지도

| 질문 | 문서 |
|---|---|
| 이걸 왜 만드는가 / MVP 범위가 어디까지인가 | `docs/PRODUCT.md` |
| 이 화면이 어떻게 동작해야 하는가 / 완료 조건이 뭔가 | `docs/EXPERIENCE.md` |
| 이 색·크기·컴포넌트가 어떻게 생겨야 하는가 | `docs/DESIGN.md` |
| 이걸 어떤 구조·라이브러리로 구현하는가 | `docs/TECHNICAL.md` |
| 지금 무엇을 해야 하는가 / 다음이 뭔가 | `docs/ROADMAP.md` |

**자주 쓰는 참조 지점**

```text
수용 조건 AC-*              EXPERIENCE.md 7절
번역 항목 상태 9종           EXPERIENCE.md 5절 · DESIGN.md 2.4
디자인 토큰                 DESIGN.md 2 · 4 · 5절
컴포넌트 명세               DESIGN.md 7절
디렉터리 구조               TECHNICAL.md 2.2
모듈 책임 표                TECHNICAL.md 2.3
DB 스키마                   TECHNICAL.md 3.2
압축 안전 검사              TECHNICAL.md 4.4
토큰 정규식                 TECHNICAL.md 5.1
병합 우선순위               TECHNICAL.md 7.1
출력 차단 조건              TECHNICAL.md 7.4
성능 예산                   TECHNICAL.md 10.1
현재 Phase 와 완료 조건      ROADMAP.md
테스트 픽스처               ROADMAP.md 3절
```

---

## 7. 문서를 고쳐야 할 때

문서는 코드보다 먼저입니다. 구현 중에 문서가 틀렸거나 부족하다는 걸 발견하면:

```text
1. 코드를 먼저 쓰지 말고 멈춘다.
2. 어느 문서의 어느 절이 문제인지 특정한다.
3. 사용자에게 무엇이 어떻게 달라져야 하는지 알린다.
4. 합의된 내용으로 문서를 고친다.
5. 그다음 코드를 쓴다.

특히 다음은 반드시 문서를 먼저 고친다.
├── MVP 범위 변경 (PRODUCT.md 6절)
├── 수용 조건 변경 (EXPERIENCE.md 7절)
├── 디자인 토큰 추가·변경 (DESIGN.md 2 · 4 · 5절)
├── 새 의존성 추가 (TECHNICAL.md 1.1)
├── 데이터 모델 변경 (TECHNICAL.md 3.2)
└── Phase 순서·완료 조건 변경 (ROADMAP.md)
```

각 문서의 마지막에 있는 **열린 질문** 표는 아직 결정되지 않은 것들입니다. 그 항목을 만나면 임의로 결정하지 말고 사용자에게 확인하세요.
