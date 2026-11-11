param([string]$FlutterSdk = 'C:\flutter')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$buildRoot = Join-Path $env:TEMP ('healthmate-release-' + [guid]::NewGuid().ToString('N'))
$dartTool = Join-Path $FlutterSdk 'bin\cache\dart-sdk\bin\dart.exe'
$flutterTool = Join-Path $FlutterSdk 'bin\cache\flutter_tools.snapshot'
if (!(Test-Path -LiteralPath $dartTool) -or !(Test-Path -LiteralPath $flutterTool)) {
    throw 'Pass -FlutterSdk with the path to an installed Flutter SDK.'
}
New-Item -ItemType Directory -Path $buildRoot | Out-Null
foreach ($item in @('lib', 'android', 'pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', '.metadata')) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $item) -Destination $buildRoot -Recurse -Force
}
Push-Location -LiteralPath $buildRoot
try {
    & $dartTool $flutterTool pub get
    if ($LASTEXITCODE -ne 0) { throw 'Flutter package resolution failed.' }
    & $dartTool $flutterTool build apk --release
    if ($LASTEXITCODE -ne 0) { throw "Build failed. Diagnostic files remain at $buildRoot" }
    $output = Join-Path $projectRoot 'build\app\outputs\flutter-apk\app-release.apk'
    New-Item -ItemType Directory -Path (Split-Path -Parent $output) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $buildRoot 'build\app\outputs\flutter-apk\app-release.apk') -Destination $output -Force
    Write-Output "APK saved to $output"
    Get-FileHash -LiteralPath $output -Algorithm SHA256
} finally {
    Pop-Location
}
# Temporary build files are kept for diagnostics; remove them manually if no longer needed.
