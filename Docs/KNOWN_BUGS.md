# Known Bugs And Setup Issues

## Current Windows Machine

- `swift` is not currently available in PowerShell on this Windows desktop, so `swift test` and `swift run GameSim` cannot run here yet.
- `git` is not currently available in PowerShell on this Windows desktop, so local status checks and branch workflows need Git for Windows or a fixed PATH.
- `python.exe` is present but not runnable from this PowerShell environment, so Python repository scripts need another machine or PATH/permission repair before direct execution here.
- Direct PowerShell script execution is disabled on this Windows desktop. Use `powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1` for one-time setup checks.

## Architecture

- The iOS app target still has app-local gameplay definitions in files such as `LevelData.swift`, `LaneManager.swift`, `LevelDifficultyConfig.swift`, `TrafficPatternGenerator.swift`, and `TrafficSafetyAnalyzer.swift`.
- `GameCore` now mirrors the safest pure rules and includes collision, scoring, and progression helpers, but the iOS app has not yet been wired to import `GameCore`.
- `GameSim` is a deterministic balance approximation. It does not reproduce SpriteKit physics, touch feel, visual occlusion, haptics, or audio.
- Level 1 is now Los Angeles `Sunset Merge` with the 42-second starter exit target. Mac should validate whether this feels right in real play.

## Validation

- iOS build validation still requires Mac/Xcode.
- Simulator balance should be compared against real Mac/iPhone playtest notes before changing live level tuning.
- Mac should validate the updated Sunset Merge timing, HUD visibility around exit prompts, and whether first-time players can react naturally.
