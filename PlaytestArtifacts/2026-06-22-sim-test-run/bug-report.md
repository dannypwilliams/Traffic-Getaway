# Traffic Getaway Simulator Test Report

Date: 2026-06-22
Device: iPhone 17 Simulator, iOS 26.5
Branch tested: `final` fast-forwarded to `origin/final` at `15d4f5d`

## Evidence

- Full current-run video: `current-test-run-recording.mp4`
- Stale pre-fetch reference video: `test-run-recording.mp4`
- Screenshots:
  - `current-01-launch-1s.png`
  - `current-02-launch-5s.png`
  - `current-03-tutorial-near-miss.png`
  - `current-04-city-select-la.png`
  - `current-05-gameplay-start.png`
  - `current-06-gameplay-traffic.png`
  - `current-07-hud-overlap.png`
  - `current-08-escaped-active-road.png`
  - `current-09-results.png`
  - `current-10-next-level-start.png`

## Build / Setup Findings

### P0 - Post-merge project file is damaged until the duplicate Xcode object ID is fixed

The updated branch initially failed before compilation:

`xcodebuild: error: Unable to read project 'Traffic Getaway.xcodeproj'. Reason: The project 'Traffic Getaway' is damaged and cannot be opened. Exception: -[PBXShellScriptBuildPhase buildPhase]: unrecognized selector sent to instance`

Root cause: `Traffic Getaway.xcodeproj/project.pbxproj` reused `2A6D0E002C21A00100A00001` for both `ArcadeArt.swift in Sources` and the `Strip Signing Metadata` shell script build phase. I changed the script phase ID to `2A6D9E002C21A00100A00001` locally so the simulator test could proceed.

Impact: release-blocking. A fresh checkout of the current PR will not build in Xcode until this fix is committed.

Evidence: build failure in terminal output, then successful build after the ID fix.

## Runtime Bugs

### P1 - First launch shows a blank black screen for the first second

On clean install launch, the first captured frame is effectively blank aside from system status/home indicators. The tutorial appears by the five-second screenshot, so this is not a permanent hang, but it reads like a broken launch.

Impact: high first-impression risk, especially on first-run.

Evidence:
- `current-01-launch-1s.png`
- `current-02-launch-5s.png`
- `current-test-run-recording.mp4`

Suggested fix: show an immediate branded/loading scene or ensure the first SpriteKit scene draws before launch settles.

### P2 - Tutorial top layout fights the Dynamic Island/notch

The tutorial title and skip button are placed high enough that the Dynamic Island visually competes with the header. The UI remains usable, but the top composition feels cramped on iPhone 17.

Impact: polish/readability issue on modern iPhones.

Evidence:
- `current-02-launch-5s.png`
- `current-03-tutorial-near-miss.png`

Suggested fix: lower the title/prompt group or create a notch-aware tutorial top band.

### P2 - Tutorial exit instruction is unclear for the number of inputs required

At the "Exit right! Take the ramp!" stage, a fast right swipe moved the car partway toward the ramp but did not immediately complete the tutorial. Repeated right-side taps completed it. The instruction implies a single decisive action, but the lane model requires multiple slot moves.

Impact: mild onboarding confusion; a new player may think the ramp did not respond.

Evidence:
- `current-test-run-recording.mp4`

Suggested fix: either move farther on tutorial exit swipes, auto-assist toward the ramp, or change the prompt to "tap right until you reach the ramp."

### P1 - Gameplay HUD text overlaps under pressure

During a near miss, the top HUD squeezed `WANTED`, `NEAR MISS x1 1.2x`, and `LA EXIT 9s` into the same strip. The center text collides visually with the left/right HUD labels and the notch area.

Impact: active gameplay readability bug. The player loses important wanted/exit timing information during a high-attention moment.

Evidence:
- `current-07-hud-overlap.png`
- `current-test-run-recording.mp4`

Suggested fix: reserve separate HUD rows/zones for transient combo text, or move near-miss feedback into the playfield instead of the top status strip.

### P2 - Pursuing police car is clipped at the bottom edge

The police car often sits half off-screen at the bottom of the playfield. It communicates pursuit, but it also looks like a layout/camera clipping artifact and can overlap the home indicator/safe area impression.

Impact: visual polish and threat readability.

Evidence:
- `current-05-gameplay-start.png`
- `current-06-gameplay-traffic.png`
- `current-08-escaped-active-road.png`

Suggested fix: raise the police follow position or fade/scale it when it approaches the bottom safe area.

### P1 - Results screen reward/unlock text overlaps and panel collides with action buttons

After escaping Sunset Merge, the results screen shows several lines of reward/unlock copy overlapping near the bottom of the stats panel. The panel also runs down into the `DOUBLE CASH` button area, with a visible scroll indicator competing with the fixed buttons.

Impact: high polish issue after the first successful run. The reward moment is one of the most important screens and currently looks broken.

Evidence:
- `current-09-results.png`
- `current-test-run-recording.mp4`

Suggested fix: shorten or stack reward lines with fixed vertical slots, reduce stat row spacing, or make the panel/button area a deliberate scroll layout with buttons outside the scroll content.

## Positive Checks

- Current branch, after the local project ID fix, builds successfully for iPhone 17 Simulator.
- Clean first-run tutorial can be completed.
- City Select correctly starts on Los Angeles with `Sunset Merge` unlocked.
- `Sunset Merge` can be completed.
- `Next Level` successfully starts `405 Afterburn`.
- Traffic readability and lane tapping felt basically playable in the first level.

