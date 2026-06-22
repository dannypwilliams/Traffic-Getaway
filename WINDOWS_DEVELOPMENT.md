# Traffic Getaway Windows Development Handoff

Traffic Getaway is an iPhone SpriteKit game. Windows can be a good machine for editing Swift files, reviewing design, writing docs, balancing data, and preparing changes, but iOS builds, simulator runs, code signing, archives, and TestFlight uploads still require macOS with Xcode.

## What Makes This Viable

1. Use Git or a clean zip as the source of truth.
2. Edit the project on Windows with VS Code or another text editor.
3. Do not try to build the iOS app directly on Windows.
4. Send changes back to a Mac build machine for Xcode validation.
5. Keep App Store signing, certificates, and TestFlight upload on the Mac or a macOS CI service.

## Recommended PC Setup

- Git for Windows
- Visual Studio Code
- Swift language extension for VS Code, optional
- PowerShell 7, optional
- 7-Zip or Windows built-in zip support

## Recommended Folder Layout on Windows

Use a simple path without cloud sync complications:

```text
C:\Dev\TrafficGetaway
```

Avoid editing the project directly inside OneDrive, Dropbox, or iCloud folders unless you already trust that sync setup. Xcode project files are plain text, but cloud sync conflicts can corrupt them.

## Daily Windows Workflow

1. Open `C:\Dev\TrafficGetaway` in VS Code.
2. Edit Swift, plist, docs, balancing values, and SpriteKit code.
3. Run `Tools\windows\check_pc_handoff.ps1`.
4. Commit changes locally with Git.
5. Push to GitHub or send the updated folder back to the Mac.
6. On the Mac, run `Tools/mac/verify_on_mac.sh`.
7. Open `Traffic Getaway.xcodeproj` in Xcode for simulator playtesting, archive, and TestFlight.

## What You Can Safely Edit on Windows

- `Traffic Getaway/*.swift`
- `Traffic Getaway/Info.plist`
- `Traffic Getaway.xcodeproj/project.pbxproj`, carefully
- `README.md`
- `WINDOWS_DEVELOPMENT.md`
- `Tools/`

## What To Avoid on Windows

- Do not create a Visual Studio iOS project replacement.
- Do not rename the `.xcodeproj` package unless you also update every reference.
- Do not edit binary build products.
- Do not commit `DerivedData`, `.xcarchive`, `.ipa`, `xcuserdata`, or `.DS_Store`.
- Do not convert line endings to CRLF in Swift or Xcode project files.

## Best Sync Option

A private GitHub repository is the cleanest setup:

```powershell
git clone https://github.com/YOUR_USERNAME/traffic-getaway.git C:\Dev\TrafficGetaway
cd C:\Dev\TrafficGetaway
.\Tools\windows\check_pc_handoff.ps1
```

If you do not want GitHub yet, use the zip package created next to this project. After editing on Windows, zip the folder and move it back to the Mac.

## Build Options

### Best: This Mac As Build Machine

Keep this Mac as the Xcode build/archive machine. Develop on Windows, then sync changes back and build in Xcode.

### Good: GitHub Actions With macOS Runner

Use GitHub for source control and a macOS Actions runner for build checks. This project includes `.github/workflows/ios-simulator-build.yml`, which runs the Mac verification script on pushes and pull requests. TestFlight upload still needs App Store Connect API credentials.

### Good: Xcode Cloud

Use Xcode Cloud after the project is in a Git provider connected to App Store Connect.

### Paid Option: MacStadium Or Cloud Mac

Use a hosted Mac if you want the Windows PC to be your only physical workstation.

## What I Still Need From You Later

To make Windows development fully smooth, I would need one of these:

- A private GitHub repo URL for Traffic Getaway, or permission to create one manually.
- The preferred build path: your Mac, GitHub Actions, Xcode Cloud, or hosted Mac.
- If using CI/TestFlight later: App Store Connect API key, issuer ID, key ID, and signing plan.

For now, the project is prepared for zip/Git handoff and Mac-side verification.
