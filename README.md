# Traffic Getaway

Canonical local project for the Traffic Getaway chase prototype.

## Project

- Xcode project: `Traffic Getaway.xcodeproj`
- Scheme: `Traffic Getaway`
- Current branch: `main`

## Local Verification

```sh
xcodebuild -project "Traffic Getaway.xcodeproj" -scheme "Traffic Getaway" -configuration Debug -destination generic/platform=iOS\ Simulator build
xcodebuild -project "Traffic Getaway.xcodeproj" -scheme "Traffic Getaway" -configuration Release -destination generic/platform=iOS\ Simulator build
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

