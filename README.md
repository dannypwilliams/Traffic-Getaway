# Traffic Getaway

Canonical local project for the Traffic Getaway chase prototype.

## Project

- Xcode project: `Traffic Getaway.xcodeproj`
- Scheme: `Traffic Getaway`
- Current branch: `main`

## Local Verification

```sh
Tools/mac/verify_on_mac.sh
```

For a direct Xcode build:

```sh
xcodebuild -project "Traffic Getaway.xcodeproj" -scheme "Traffic Getaway" -configuration Debug -destination generic/platform=iOS\ Simulator build
```

## Windows Development

Windows can be used for editing, code review, balancing, and documentation. iOS builds, simulator testing, signing, archiving, and TestFlight upload still require macOS/Xcode.

Start here:

- `WINDOWS_DEVELOPMENT.md`
- `Tools/windows/check_pc_handoff.ps1`
- `Tools/mac/verify_on_mac.sh`

Recommended Windows folder:

```text
C:\Dev\TrafficGetaway
```

On Windows, run:

```powershell
.\Tools\windows\check_pc_handoff.ps1 -OpenVSCode
```

## Xcode Cloud Starting Workflow

- Trigger: push to `main`
- Action: Build and Archive
- Tests: none configured yet
- Distribution: TestFlight Internal Testing after App Store Connect app record and signing are configured

## GitHub Remote

After creating the private GitHub repo:

```sh
git remote add origin https://github.com/YOUR_USERNAME/traffic-getaway.git
git push -u origin main
```

The repo includes `.github/workflows/ios-simulator-build.yml`, so GitHub can run a macOS simulator build check after pushes once the project is hosted there.
