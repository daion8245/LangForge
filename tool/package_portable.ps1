# Packages the release build into the portable ZIP of TECHNICAL.md 14.2.
#
#   flutter build windows --release
#   powershell -ExecutionPolicy Bypass -File tool/package_portable.ps1
#
# Produces build/LangForge-{version}-windows-x64.zip

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$release = Join-Path $root 'build\windows\x64\runner\Release'

if (-not (Test-Path $release)) {
    throw "릴리스 빌드를 찾을 수 없습니다: $release`n먼저 flutter build windows --release 를 실행하세요."
}

# Single source of the version — lib/app_version.dart must match pubspec.yaml.
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Encoding utf8
$versionLine = $pubspec | Where-Object { $_ -match '^version:\s*(.+)$' } | Select-Object -First 1
if (-not ($versionLine -match '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)')) {
    throw 'pubspec.yaml 에서 version 을 읽지 못했습니다.'
}
$version = $Matches[1]

$codeVersion = Get-Content (Join-Path $root 'lib\app_version.dart') -Encoding utf8 |
    Where-Object { $_ -match "appVersion\s*=\s*'([^']+)'" } |
    Select-Object -First 1
if (-not ($codeVersion -match "'([^']+)'")) {
    throw 'lib/app_version.dart 에서 appVersion 을 읽지 못했습니다.'
}
if ($Matches[1] -ne $version) {
    throw "버전 불일치: pubspec.yaml $version vs lib/app_version.dart $($Matches[1])"
}

$stage = Join-Path $root "build\portable\LangForge-$version-windows-x64"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage -Force | Out-Null

Copy-Item (Join-Path $release '*') $stage -Recurse -Force
Copy-Item (Join-Path $root 'LICENSE') $stage -Force
Copy-Item (Join-Path $root 'THIRD_PARTY_LICENSES.md') $stage -Force

$readme = @"
LangForge $version — Minecraft 모드 번역 도구

[실행]
  langforge.exe 를 실행하세요. 설치 관리자가 없습니다.
  폴더째 지우면 완전히 제거됩니다.

[SmartScreen 경고]
  코드 서명 인증서를 쓰지 않으므로 첫 실행 때 Windows SmartScreen 이
  "Windows의 PC 보호" 경고를 띄울 수 있습니다.
  [추가 정보] → [실행] 을 눌러 진행하세요.

[API 키 (BYOK)]
  번역에는 본인의 API 키가 필요합니다. 앱이 키를 대신 제공하지 않습니다.
  엔진 4종 중 하나만 있으면 됩니다.

    Google Gemini              https://aistudio.google.com/app/apikey
    DeepL                      https://www.deepl.com/your-account/keys
    Google Cloud Translation   https://console.cloud.google.com/apis/credentials
    Papago                     https://console.ncloud.com/naver-service/application

  키는 Windows 자격 증명 관리자에 저장되며 프로젝트 파일·로그·보고서
  어디에도 기록되지 않습니다.

[통신]
  번역 API 외의 어떤 서버와도 통신하지 않습니다.
  텔레메트리·사용 통계·자동 오류 리포팅이 없습니다.

[라이선스]
  MIT — LICENSE 참조. third-party 고지는 THIRD_PARTY_LICENSES.md 참조.
"@
# UTF-8 with BOM so Windows Notepad does not mangle the Korean text.
Set-Content -Path (Join-Path $stage 'README.txt') -Value $readme -Encoding utf8

$zip = Join-Path $root "build\LangForge-$version-windows-x64.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip

$sizeMb = [math]::Round((Get-Item $zip).Length / 1MB, 1)
Write-Output "포터블 ZIP 생성: $zip ($sizeMb MB)"
