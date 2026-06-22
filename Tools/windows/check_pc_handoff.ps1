param(
    [switch]$OpenVSCode
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Write-Host "Traffic Getaway PC handoff check" -ForegroundColor Cyan
Write-Host "Project root: $root"

$required = @(
    "Traffic Getaway.xcodeproj\project.pbxproj",
    "Traffic Getaway\GameScene.swift",
    "Traffic Getaway\Info.plist",
    "Traffic Getaway\AppDelegate.swift",
    "Traffic Getaway\SceneDelegate.swift",
    "Traffic Getaway\Assets.xcassets",
    "README.md",
    "WINDOWS_DEVELOPMENT.md"
)

foreach ($path in $required) {
    $fullPath = Join-Path $root $path
    if (-not (Test-Path $fullPath)) {
        throw "Missing required project file: $path"
    }
}

$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    Write-Host "Git found: $($git.Source)" -ForegroundColor Green
    Push-Location $root
    git status --short
    Pop-Location
} else {
    Write-Host "Git was not found. Install Git for Windows for the cleanest workflow." -ForegroundColor Yellow
}

$swiftFiles = Get-ChildItem -Path (Join-Path $root "Traffic Getaway") -Filter "*.swift" -Recurse
Write-Host "Swift files found: $($swiftFiles.Count)" -ForegroundColor Green

$badLineEndings = @()
foreach ($file in $swiftFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    for ($i = 0; $i -lt $bytes.Length - 1; $i++) {
        if ($bytes[$i] -eq 13 -and $bytes[$i + 1] -eq 10) {
            $badLineEndings += $file.FullName
            break
        }
    }
}

if ($badLineEndings.Count -gt 0) {
    Write-Host "Warning: CRLF line endings found in Swift files:" -ForegroundColor Yellow
    $badLineEndings | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "Swift line endings look PC-safe." -ForegroundColor Green
}

if ($OpenVSCode) {
    $code = Get-Command code -ErrorAction SilentlyContinue
    if ($code) {
        & code $root
    } else {
        Write-Host "VS Code command-line launcher was not found." -ForegroundColor Yellow
    }
}

Write-Host "PC handoff check complete. Build and simulator testing still require macOS/Xcode." -ForegroundColor Cyan
