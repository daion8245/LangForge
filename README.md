# LangForge — Minecraft 모드 번역 & 리소스팩 내보내기 도구

![LangForge Banner](assets/pack/pack.png)

**LangForge**는 Minecraft 모드 JAR 및 리소스팩의 언어 파일(`assets/{namespace}/lang/{code}.json`)을 자동으로 탐색·번역하고, 게임에 즉시 적용 가능한 리소스팩(`KO_Translation_Pack.zip`)으로 내보내는 로컬 데스크톱 어플리케이션입니다.

---

## 🚀 주요 기능 (Features)

1. **자동 파일 탐색 & 안전성 (Isolate & ArchiveGuard)**
   - 대규모 모드팩(180개 이상의 JAR, 48,000개 이상의 키)을 비동기 워커 풀로 고속 파싱.
   - Zip Slip 경로 탈출 및 압축 폭탄(Zip Bomb) 방지 안전 검사.

2. **변수 & 포맷팅 제어 코드 100% 보호 (`TokenProtector`)**
   - `%s`, `%1$s`, `§a`, `§x§F§F...`, `{name}`, `{{name}}` 등의 포맷 코드를 U+2063 보이지 않는 단위 표식으로 치환하여 번역 API 전송.
   - `MultisetValidator` 기반 후검증으로 변수 변형/누락 시 100% 차단 및 재시도.

3. **번역 엔진 4종 (Gemini · DeepL · Google · Papago)**
   - 엔진마다 인증 필드가 다르게 렌더링되고, `연결 테스트` 로 키를 실제 호출해 검증.
   - API 키는 항상 HTTP 헤더로 전송 (URL 쿼리 전달 없음).
   - 지수 백오프 + 지터(Jitter) 재시도 및 401/429 오류 응답 분리 처리.
   - `FlutterSecureStorage` (Windows Credential Manager) 기반 자격 증명 보안 암호화 저장.
   - 엔드포인트·모델 목록은 소스가 아닌 `assets/data/providers.json` 에 있음.

4. **대조 편집기 & 6단계 병합 우선순위 (`MergePolicy`)**
   - 사용자가 직접 수정한 번역(`userTranslation`)은 어떤 자동 번역 실행 시에도 절대 덮어쓰지 않음.
   - S2-B1 대조 편집기 뷰에서 인라인 셀 직접 편집 및 즉시 상태 반영.

5. **Minecraft 리소스팩 내보내기 (`ResourcePackExporter`)**
   - 통합 ZIP 리소스팩(`KO_Translation_Pack.zip`), 폴더형 리소스팩, 경로 보존 JSON, namespace별 개별 JSON, 모드별 개별 리소스팩 지원.
   - `pack.png` 를 기본 아이콘 · 사용자 이미지 · 원본 모드 아이콘 · 없음 중에서 선택.
   - `Translation_Report.md` 에 통계 · 오류 · 경고 · 충돌 · 원문 유지 항목 · 출력 파일 목록 기록.
   - Minecraft 1.18.2 ~ 1.21.4 (12개 버전) `pack_format` 자동 매핑.
   - ZIP 최상단 `pack.mcmeta` 포맷 및 `/` 경로 구분자 엄격 검증 (`ZipVerifier`).
   - 원자적 쓰기(Atomic Write) 적용으로 실패 시 롤백 및 `.bak` 백업 보장.

6. **프로젝트 저장 & 시작 화면 S0 (`.lfproj`)**
   - 단일 SQLite `.lfproj` 데이터베이스로 전체 작업 상태 저장 및 복원.
   - 최근 프로젝트 10개 목록 관리 (`registry.db`) 및 비정상 종료 시 자동 크래시 복원.

7. **캐시 · 용어집 · 충돌 해결**
   - 같은 원문·같은 조건이면 API 를 호출하지 않는 번역 캐시. 적중률 표시 (항목 0개면 `—`).
   - 전역 · 프로젝트 용어집을 번역기 호출 **전에** 적용.
   - 같은 namespace 의 같은 key 에 원문이 다르면 충돌로 감지하고, 원문을 나란히 비교해 사용자가 최종 값을 선택. 미해결 충돌이 있으면 출력이 차단됨.

8. **환경설정 4개 탭 · 대상 언어 6종**
   - 일반 · 변수 보호 · 충돌 처리 · 언어 프로필 탭.
   - 대상 언어를 6종 중에서 선택하면 출력 파일명과 `pack.mcmeta` 설명이 함께 바뀜.
   - 앱 내 로그 뷰어 제공.

---

## 🛠 아키텍처 (Architecture)

```text
lib/
├── app/                  # 앱 테마 및 엔트리포인트 (Theme Tokens: colors, radii, sizes, spacing, typography)
├── application/          # 비즈니스 유스케이스 & 상태 관리 (ScanController, ProjectSession, TranslationRunner)
├── domain/               # 순수 Dart 규칙 & 검증 알고리즘 (TokenProtector, Multiset, MergePolicy, ExclusionPolicy)
├── infrastructure/       # 외부 시스템 연동 (Drift SQLite, Gemini Provider, Archive, Isolate Worker Pool)
└── presentation/         # Flutter UI 계층 (S0 Start, S1 Empty, S2 Editor, S5 Export Modal, Common Widgets)
```

---

## 💻 실행 및 빌드 방법 (Getting Started)

### 사전 요구사항

- Flutter SDK (Dart SDK `^3.12.2` 를 포함하는 버전)
- Visual Studio 2022 — **Desktop development with C++** 워크로드
  - 개별 구성 요소에서 **최신 v143 빌드 도구용 C++ ATL** 을 함께 설치해야 합니다.
    `flutter_secure_storage_windows` 가 `atlstr.h` 를 필요로 하며, 없으면 빌드가
    `error C1083` 로 실패합니다.

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 코드 생성기 실행 (Drift / Riverpod)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. 디버그 실행
```bash
flutter run -d windows
```

### 4. 테스트
```bash
flutter test --exclude-tags corpus     # CI 가 실행하는 범위
flutter test test/corpus --tags corpus # 실제 모드 코퍼스 (로컬 전용)
```

코퍼스 테스트는 실제 모드 JAR 을 사용합니다. 저작권 때문에 저장소에 포함하지 않으므로
`test_fixtures/corpus/` 에 직접 넣거나 `LANGFORGE_CORPUS_DIR` 환경 변수로 폴더를 지정하세요.

### 5. Windows 릴리스 포터블 빌드
```bash
flutter build windows --release
```

`build/windows/x64/runner/Release/` 폴더를 통째로 압축하면 포터블 배포본이 됩니다.

---

## 📦 설치 및 사용 (For Users)

### 설치

설치 관리자가 없습니다. ZIP 을 풀고 `langforge.exe` 를 실행하면 됩니다. 폴더를 지우면
완전히 제거됩니다.

> **SmartScreen 경고**
> 코드 서명 인증서를 사용하지 않으므로 처음 실행할 때 Windows SmartScreen 이
> "Windows의 PC 보호" 경고를 표시할 수 있습니다. **추가 정보 → 실행** 을 눌러 진행하세요.

### API 키 발급

번역에는 본인의 API 키가 필요합니다 (BYOK). 앱이 키를 대신 제공하지 않습니다.
엔진 4종 중 하나만 있으면 됩니다.

| 엔진 | 키 발급 |
|---|---|
| Google Gemini | <https://aistudio.google.com/app/apikey> |
| DeepL | <https://www.deepl.com/your-account/keys> |
| Google Cloud Translation | <https://console.cloud.google.com/apis/credentials> |
| Papago | <https://console.ncloud.com/naver-service/application> (Client ID · Client Secret 2개) |

1. 위 표에서 쓸 엔진의 키를 발급합니다.
2. 앱 우측 **작업 및 엔진 설정** 패널에서 엔진을 고르고 인증 필드에 붙여 넣습니다.
3. `연결 테스트` 로 키가 유효한지 확인합니다.

키는 Windows 자격 증명 관리자에 저장되며 프로젝트 파일·로그·보고서 어디에도 기록되지
않습니다. 프로젝트 파일을 남에게 주어도 키는 따라가지 않습니다.

### 저장되는 위치

```text
%APPDATA%\LangForge\registry.db     최근 프로젝트 목록
%APPDATA%\LangForge\logs\           로그 (최대 5개 회전)
사용자가 지정한 위치\<이름>.lfproj      프로젝트 (SQLite 파일 1개)
Windows 자격 증명 관리자              API 키
```

이 도구는 번역 API 외의 어떤 서버와도 통신하지 않습니다. 텔레메트리·사용 통계·자동 오류
리포팅이 없습니다.

---

## 📜 라이선스 (License)

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.  
Third-party licenses are documented in [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).
