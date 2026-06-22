param(
    [switch]$OpenVSCode,
    [switch]$RunSwiftChecks
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Write-Host "Traffic Getaway PC handoff check" -ForegroundColor Cyan
Write-Host "Project root: $root"

$required = @(
    "AGENTS.md",
    "Docs\DESIGN.md",
    "Docs\BALANCE_TARGETS.md",
    "Docs\KNOWN_BUGS.md",
    "Docs\CODEX_HANDOFF.md",
    "GameCore\Package.swift",
    "GameCore\Sources\GameCore\CollisionModel.swift",
    "GameCore\Sources\GameCore\ProgressionModel.swift",
    "GameCore\Sources\GameCore\ScoringModel.swift",
    "GameCore\Sources\GameCore\GameModels.swift",
    "GameCore\Tests\GameCoreTests\GameCoreTests.swift",
    "GameSim\Package.swift",
    "GameSim\Sources\GameSim\main.swift",
    "Assets\Source",
    "Assets\Processed",
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

$swift = Get-Command swift -ErrorAction SilentlyContinue
if ($swift) {
    Write-Host "Swift found: $($swift.Source)" -ForegroundColor Green
} else {
    Write-Host "Swift was not found. Install Swift or add it to PATH before running GameCore tests or GameSim." -ForegroundColor Yellow
}

$swiftRoots = @("Traffic Getaway", "GameCore", "GameSim", "Tools")
$swiftFiles = @()
foreach ($swiftRoot in $swiftRoots) {
    $fullSwiftRoot = Join-Path $root $swiftRoot
    if (Test-Path $fullSwiftRoot) {
        $swiftFiles += Get-ChildItem -Path $fullSwiftRoot -Filter "*.swift" -Recurse
    }
}
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

if ($RunSwiftChecks) {
    if (-not $swift) {
        throw "Cannot run Swift checks because swift was not found on PATH."
    }

    Write-Host "Running GameCore tests..." -ForegroundColor Cyan
    Push-Location (Join-Path $root "GameCore")
    swift test
    Pop-Location

    Write-Host "Running a quick GameSim smoke test..." -ForegroundColor Cyan
    Push-Location (Join-Path $root "GameSim")
    swift run GameSim --level ny_01 --vehicle starter_compact --runs 100 --seed 12345
    Pop-Location
} else {
    Write-Host "Swift checks skipped. Use -RunSwiftChecks after Swift is installed." -ForegroundColor Yellow
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
