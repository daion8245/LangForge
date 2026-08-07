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

3. **Gemini AI 번역 엔진 연동 (`v1beta` REST API)**
   - Google Gemini REST API 기반 자동 번역 연동.
   - `x-goog-api-key` HTTP 헤더 전송 (URL 쿼리 전달 불가 규격 준수).
   - 지수 백오프 + 지터(Jitter) 재시도 및 401/429 오류 응답 분리 처리.
   - `FlutterSecureStorage` (Windows Credential Manager) 기반 자격 증명 보안 암호화 저장.

4. **대조 편집기 & 6단계 병합 우선순위 (`MergePolicy`)**
   - 사용자가 직접 수정한 번역(`userTranslation`)은 어떤 자동 번역 실행 시에도 절대 덮어쓰지 않음.
   - S2-B1 대조 편집기 뷰에서 인라인 셀 직접 편집 및 즉시 상태 반영.

5. **Minecraft 리소스팩 내보내기 (`ResourcePackExporter`)**
   - 통합 ZIP 리소스팩(`KO_Translation_Pack.zip`), 폴더형 리소스팩, 경로 보존 JSON, namespace별 개별 JSON 지원.
   - Minecraft 1.18.2 ~ 1.21.4 (12개 버전) `pack_format` 자동 매핑.
   - ZIP 최상단 `pack.mcmeta` 포맷 및 `/` 경로 구분자 엄격 검증 (`ZipVerifier`).
   - 원자적 쓰기(Atomic Write) 적용으로 실패 시 롤백 및 `.bak` 백업 보장.

6. **프로젝트 저장 & 시작 화면 S0 (`.lfproj`)**
   - 단일 SQLite `.lfproj` 데이터베이스로 전체 작업 상태 저장 및 복원.
   - 최근 프로젝트 10개 목록 관리 (`registry.db`) 및 비정상 종료 시 자동 크래시 복원.

---

## 🛠 아키텍처 (Architecture)

```text
lib/
├── app/                  # 앱 테마 및 엔트리포인트 (Theme Tokens: colors, radii, spacing, typography)
├── application/          # 비즈니스 유스케이스 & 상태 관리 (ScanController, ProjectController, TranslationRunner)
├── domain/               # 순수 Dart 규칙 & 검증 알고리즘 (TokenProtector, Multiset, MergePolicy, ExclusionPolicy)
├── infrastructure/       # 외부 시스템 연동 (Drift SQLite, Gemini Provider, Archive, Isolate Worker Pool)
└── presentation/         # Flutter UI 계층 (S0 Start, S1 Empty, S2 Editor, S5 Export Modal, Common Widgets)
```

---

## 💻 실행 및 빌드 방법 (Getting Started)

### 사전 요구사항
- Flutter SDK (v3.19.0 이상)
- Dart SDK (v3.3.0 이상)

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 코드 생성기 실행 (Drift / Riverpod)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 디버그 실행
```bash
flutter run -d windows
```

### 4. Windows 릴리스 포터블 빌드
```bash
flutter build windows --release
```

---

## 📜 라이선스 (License)

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.  
Third-party licenses are documented in [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).
