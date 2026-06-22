# Traffic Getaway

Canonical local project for the Traffic Getaway chase prototype.

## Project

- iOS app project: `Traffic Getaway.xcodeproj`
- iOS scheme: `Traffic Getaway`
- Pure Swift rules package: `GameCore`
- Headless simulator package: `GameSim`
- Asset pipeline folders: `Assets/Source` and `Assets/Processed`

## Current Architecture

Traffic Getaway now uses the setup described in `AGENTS.md`:

- `GameCore` contains pure Swift gameplay rules and deterministic simulation logic.
- `GameSim` runs balance simulations from the command line.
- `Traffic Getaway` remains the iOS SpriteKit app for rendering, touch, haptics, audio, menus, StoreKit, and App Store validation.

The iOS app has not yet been wired to import `GameCore`; that should happen gradually after Mac/Xcode validation.

## Windows Desktop Workflow

Windows is for editing, code review, docs, asset processing, pure Swift logic, and balance simulations after Swift is installed.

Run the handoff check:

```powershell
.\Tools\windows\check_pc_handoff.ps1
```

If PowerShell blocks local scripts on this machine:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1
```

After Swift is installed, run tests and a smoke simulation:

```powershell
.\Tools\windows\check_pc_handoff.ps1 -RunSwiftChecks
```

Run a full Level 1 simulation:

```powershell
cd GameSim
swift run GameSim --level ny_01 --vehicle starter_compact --runs 10000 --seed 12345
```

The same Level 1 command also accepts a readable level alias:

```powershell
cd GameSim
swift run GameSim --level brooklyn_warmup --vehicle starter_compact --runs 10000 --seed 12345
```

## Mac Validation Workflow

Mac is for Xcode, iOS Simulator, physical iPhone feel, haptics, audio, signing, archives, TestFlight, and App Store work.

```sh
Tools/mac/verify_on_mac.sh
```

For a direct Xcode build:

```sh
xcodebuild -project "Traffic Getaway.xcodeproj" -scheme "Traffic Getaway" -configuration Debug -destination generic/platform=iOS\ Simulator build
```

## Session Docs

Start future work here:

- `AGENTS.md`
- `Docs/DESIGN.md`
- `Docs/BALANCE_TARGETS.md`
- `Docs/KNOWN_BUGS.md`
- `Docs/CODEX_HANDOFF.md`

## GitHub And CI

The repo includes `.github/workflows/ios-simulator-build.yml`, so GitHub can run a macOS simulator build check after pushes once the project is hosted there.
