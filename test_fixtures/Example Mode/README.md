# Example Mode

LangForge의 입력·탐색·JSON 격리·토큰 보호·기존 번역 병합을 반복 검증하는 자체 제작 테스트 픽스처입니다.

```powershell
dart run "test_fixtures/Example Mode/generate.dart"
```

위 명령은 같은 폴더에 다음 JAR을 결정론적으로 다시 만듭니다.

- `ExampleMultiNs-1.0.jar`: 정상 입력, namespace 3개, 모든 보호 토큰과 일부 기존 번역
- `ExampleLegacy-2.1.jar`: 원본 언어가 없는 namespace 1개와 정상 namespace 1개
- `ExampleBroken-0.9.jar`: 의도적인 JSON 문법 오류 namespace 1개

세 JAR에는 총 namespace 6개가 있습니다. 전부 직접 만든 데이터이므로 외부 모드의 코드나 번역문을 포함하지 않습니다.
