# Debug First-Escape Completion/Reward Session 01

## Scope

- Device: iPhone 17e simulator, iOS 26.5
- Build: Debug simulator build installed from `/tmp/TrafficGetawayVerifyDerivedData/Build/Products/Debug-iphonesimulator/Traffic Getaway.app`
- Scenario: `TrafficGetaway.debug.resultScenario = first_escape_starter_bike`
- City/level: Los Angeles / `la_01` Sunset Merge
- Vehicle shown: Sunset Cruiser
- Evidence video: `videos/progression/2026-06-23_iphone17e_la01_debug-first-escape_completion-reward_session01.mp4`
- Evidence screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_debug-first-escape_completion-reward_session01_results-use-bike.png`

## Observed UI

- Result title: `ESCAPED`
- Level text: `Sunset Merge  Los Angeles`
- Score: `3200`
- Distance: `1420`
- Cash: `$423`
- XP: `213 XP`
- Near misses: `5`
- Best combo: `x4`
- Wanted: `LEVEL 3`
- Progress: `Level 1 -> 2`
- Next/unlock text: `Starter Bike unlocked: split lanes`
- Primary action: `USE BIKE`
- Secondary actions: `GARAGE`, `LEVEL SELECT`, `MENU`

## Classification

This is valid functional evidence for the completion screen, reward screen, unlock copy, and primary payoff affordance. It is debug-assisted synthetic result evidence, not a real active-input completion and not a balance source. No raw run telemetry is expected because the app opens directly into the real `ResultsScene` after processing a synthetic completed run through the progression path.

## Cleanup

Post-capture cleanup is saved at `build-validation/debug-first-escape-completion-reward-debug-defaults-final-clean-after-capture.log`. The cleanup removed all observed `TrafficGetaway.debug.*` defaults and preserved `TrafficGetaway.SaveData.v2`.
