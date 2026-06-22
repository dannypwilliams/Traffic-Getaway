# First Minute Playtest

## Devices

Use at least:

- Small compact-height iPhone simulator.
- Dynamic Island / iPhone 17-class simulator when available.
- Larger-height iPhone simulator.

On this Windows machine, Simulator validation is unavailable. Run `Tools/mac/verify_on_mac.sh` on Mac before claiming release readiness.

## Debug HUD

Use `AppConfig.swift` flags for local diagnostics:

- `debugMode`
- `debugAutoplay`
- `showTrafficSpawnHeatmap`
- `showOpenLaneAnalysis`
- `showPerformanceOverlay`

Debug overlays must remain off in normal release behavior.

## Test Seeds

Initial deterministic seeds:

- `12345`: baseline Sunset Merge / starter compact.
- `24680`: replay/RNG stream check.
- `99`: compact fixed-step replay fixture.

Add bad seeds to this document whenever validation finds an impossible or unclear sequence.

## Scenario A: Clean Install

Expected:

- First in-app frame is branded, not black.
- Tutorial title and Skip are inside safe content.
- Final tutorial step can be completed by moving right repeatedly.
- Sunset Merge launches from the first-session flow.

## Scenario B: Passive Driver

Expected:

- Sitting in one lane raises lane-stale/police pressure feedback.
- Police visually closes in without clipping under the home indicator.
- Terminal result is CAPTURED, not CRASHED.

## Scenario C: Skilled Driver

Expected:

- Deliberate lane changes and near misses build combo/Flow.
- Police pressure visibly relaxes or slows.
- Exit can be reached from readable guidance.
- Terminal result is ESCAPED.

## Scenario D: Traffic Collision

Expected:

- Collision feedback appears at the hit.
- Result is CRASHED.
- Result reason distinguishes traffic/roadblock from capture.

## Scenario E: Missed Exit

Expected:

- Ramp miss is called out.
- Result is MISSED EXIT.
- It is not mislabeled as capture or traffic collision.

## Scenario F: Extreme HUD Pressure

Expected:

- WANTED remains readable on the left.
- Score/status remains readable in the center.
- Exit direction/countdown remains readable on the right.
- Combo/near-miss text appears below the persistent top row.
- Dynamic Island does not cover required text.

## Scenario G: First Escape Progression

Expected:

- Rewards are readable.
- First Sunset Merge completion unlocks the Starter Bike once.
- The Starter Bike becomes the selected vehicle.
- Next Level launches 405 Afterburn with motorcycle lane-splitting available.

## Scenario H: Replay

Expected:

- Fixed-step replay with the same config, seed, and commands matches outcome, score, and recorded hashes.
- Any mismatch records the first divergent frame.

## Evidence To Capture

- Clean launch first frame screenshot.
- Tutorial header screenshot.
- Gameplay HUD with active exit and combo.
- Police at low, medium, high, and critical pressure.
- Results for escaped, captured, crashed, and missed exit.
- Short video for clean tutorial -> Sunset Merge -> results when available.
