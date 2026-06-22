# Traffic Getaway Windows Development Handoff

Traffic Getaway is an iPhone SpriteKit game with a pure Swift simulation layer. This Windows desktop is the right machine for editing, code review, documentation, pure Swift rules, deterministic simulations, balance reports, and asset processing. iOS builds, simulator runs, code signing, archives, TestFlight, touch feel, haptics, and audio validation still require macOS with Xcode.

## What Makes This Viable

1. Use GitHub or another Git remote as the source of truth.
2. Keep gameplay rules moving toward `GameCore`.
3. Use `GameSim` for repeatable balance checks.
4. Keep SpriteKit/iOS validation on the Mac.
5. Update `Docs/CODEX_HANDOFF.md` after meaningful sessions.

## Recommended PC Setup

- Git for Windows
- Swift for Windows or another supported Swift toolchain on PATH
- Visual Studio Code
- Swift language extension for VS Code, optional
- PowerShell 7, optional
- 7-Zip or Windows built-in zip support

## Recommended Folder Layout On Windows

Use a simple path without cloud sync complications:

```text
C:\Dev\TrafficGetaway
```

Avoid editing the project directly inside OneDrive, Dropbox, or iCloud folders unless you already trust that sync setup. Xcode project files are plain text, but cloud sync conflicts can corrupt them.

## Daily Windows Workflow

1. Pull latest changes from GitHub.
2. Read `AGENTS.md` and `Docs/CODEX_HANDOFF.md`.
3. Edit Swift, docs, data, balancing values, and simulator logic.
4. Run `Tools\windows\check_pc_handoff.ps1`.
5. If Swift is installed, run `Tools\windows\check_pc_handoff.ps1 -RunSwiftChecks`.
6. Run focused `GameSim` commands for balance work.
7. Commit and push changes.
8. On the Mac, pull and run `Tools/mac/verify_on_mac.sh`.
9. Record Mac/iPhone findings in `Docs/PLAYTEST_NOTES.md` and `Docs/CODEX_HANDOFF.md`.

If PowerShell blocks local scripts, run the same check with a one-time execution policy bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1
```

## What You Can Safely Edit On Windows

- `GameCore/**`
- `GameSim/**`
- `Assets/Source/**`
- `Assets/Processed/**`
- `Docs/**`
- `Tools/**`
- `Traffic Getaway/*.swift`
- `Traffic Getaway/Info.plist`
- `Traffic Getaway.xcodeproj/project.pbxproj`, carefully
- `README.md`
- `WINDOWS_DEVELOPMENT.md`

## What To Avoid On Windows

- Do not try to build, archive, sign, or TestFlight-upload the iOS app from Windows.
- Do not create a Visual Studio iOS project replacement.
- Do not rename the `.xcodeproj` package unless every reference is updated.
- Do not edit binary build products.
- Do not commit `DerivedData`, `.xcarchive`, `.ipa`, `xcuserdata`, or `.DS_Store`.
- Do not convert Swift or Xcode project line endings to CRLF.

## GameCore Commands

```powershell
cd GameCore
swift test
```

## GameSim Commands

List known levels and vehicles:

```powershell
cd GameSim
swift run GameSim --list
```

Run the Level 1 starter car simulation:

```powershell
cd GameSim
swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345
```

Readable level names are supported:

```powershell
cd GameSim
swift run GameSim --level sunset_merge --vehicle starter_compact --runs 10000 --seed 12345
```

Compare every vehicle on Level 1:

```powershell
cd GameSim
swift run GameSim --level la_01 --vehicle all --runs 10000 --seed 12345
```

Run the pure traffic reachability stress report:

```powershell
cd GameSim
swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --traffic-stress
```

## Mac Handoff

Use the Mac to answer whether the game actually feels good:

- Build in Xcode.
- Run in iOS Simulator.
- Play Level 1 several times.
- Test touch/swipe feel.
- Check haptics and audio.
- Check layout and menus.
- Validate StoreKit/TestFlight/signing when needed.

## Build Options

### Best: Personal Mac As Build Machine

Develop and simulate on Windows, then sync through GitHub and validate on the Mac.

### Good: GitHub Actions With macOS Runner

The project includes `.github/workflows/ios-simulator-build.yml`, which runs the Mac verification script on pushes and pull requests. TestFlight upload still needs App Store Connect API credentials.

### Good: Xcode Cloud

Use Xcode Cloud after the project is in a Git provider connected to App Store Connect.

### Paid Option: Hosted Mac

Use a hosted Mac if Windows will be the only physical workstation.
