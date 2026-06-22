# Traffic Getaway Mac/iOS Handoff

Date: 2026-06-22 11:26 PDT

## What Changed

- Fixed first-run tutorial top spacing so `QUICK CHASE SCHOOL`, prompt text, and Skip avoid the iPhone 17 Pro Dynamic Island area.
- Added a small shared `UIHelpers.topSafeY` helper for top-of-screen SpriteKit UI placement.
- Moved forced exit-related buddy callouts from the upper read-ahead zone to the lower radio strip so they no longer block traffic, the wanted banner, or exit readability.
- Added this handoff plus playtest notes under `Docs/`.

## Files Modified

- `Traffic Getaway/UIHelpers.swift`
- `Traffic Getaway/TutorialScene.swift`
- `Traffic Getaway/BuddyManager.swift`
- `Docs/PLAYTEST_NOTES.md`
- `Docs/CODEX_HANDOFF.md`
- `Docs/PlaytestScreenshots/` evidence captures

## Tests Run

- `xcodebuild -project "Traffic Getaway.xcodeproj" -scheme "Traffic Getaway" -configuration Debug -destination "generic/platform=iOS Simulator" -derivedDataPath DerivedData-MacPass CODE_SIGNING_ALLOWED=NO build`
- Fresh Simulator uninstall/install/launch on iPhone 17 Pro iOS 26.5.
- Live Simulator UI checks through tutorial, level select, main menu, settings, garage, and bikes tab.

## Simulator Runs Completed

- Fresh install tutorial flow: completed/skip-validated.
- Level 1 / Brooklyn Warmup: 1 focused natural run to primary exit and emergency exit state.
- Main menu, settings, garage, bikes tab, and store-hidden navigation were validated.
- Requested 5 natural Level 1 runs were not fully completed in this pass; keep that as the next Mac validation task.

## Playtest Metrics

- Level 1 exit appeared: yes.
- Exit appearance time: about 38 seconds.
- Exit readability: strong green side band, countdown, sign, arrows, and HUD text.
- Exit reachable: yes, but commit threshold needs further player sampling.
- First 25 seconds: fair, sparse, no heavy-vehicle pressure observed before the intended early safety window ended.
- HUD: compact and readable, close to Dynamic Island but not blocking traffic.
- Buddy: upper-zone exit callout overlap found and fixed.

## Known Issues

- Physical iPhone validation was unavailable because listed iPhones were offline.
- `simctl` screenshot can capture a black launch transition frame even while the live Simulator renders correctly shortly afterward.
- Only one natural Level 1 run was sampled after this Mac pass; balance confidence still needs the requested 5-run sample.
- Bike economy still needs longer validation: first bike is visible at `$550`, but exact time-to-first-bike should be confirmed by simulation and playtest.

## What Should Go Back To Windows

- Run larger Brooklyn Warmup simulations around exit completion rate, missed-exit rate, average cash per successful/failed run, and expected runs-to-first-bike.
- Confirm whether `$550` for Starter Bike lands within the desired early-unlock target.
- Stress-test traffic wave safety around active exits, especially cases where the player is already near the correct side but fails to satisfy the ramp slot threshold.

## Highest-Priority Next Task

Run the full 5-run iPhone Simulator Level 1 validation after this UI fix, then decide whether the exit completion threshold needs a visual or tuning adjustment.

## Suggested Next Prompt

Continue the Traffic Getaway Mac validation pass. Use the latest build, run five fresh natural Brooklyn Warmup attempts on iPhone Simulator, record exit appearance/reachability/completion/missed-exit causes, and only make a small Mac-side fix if the exit threshold or HUD/buddy readability still blocks first-time players.
