# LA01 Active Gameplay Background / Foreground Session 01 Observations

- Date: 2026-06-23
- Device: iPhone 17e simulator, iOS 26.5
- Level: `la_01` / Sunset Merge
- Vehicle: `starter_compact` telemetry / visible `Sunset Cruiser`
- Flow: start gate, gameplay start tap, active gameplay, iOS Home screen, foreground Traffic Getaway, terminal result
- Video: `videos/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01.mp4`
- Start gate screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01_start-gate.png`
- Before Home screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01_before-home-active.png`
- Home screen screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01_home-screen.png`
- After foreground screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01_after-foreground.png`
- Result screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01_result-captured.png`
- Raw telemetry: `telemetry/raw/01-2026-06-23_10-46-19-la_01-starter_compact-active-gameplay-background-foreground-17033032432948224632.jsonl`
- Summary: `telemetry/summaries/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01-summary.md`
- Final cleanup log: `build-validation/active-gameplay-background-foreground-debug-defaults-final-clean-after-capture.log`

## Observed Result

The run began from the visible `Tap to Start` gate. Traffic Getaway was sent to the iOS Home screen during active gameplay, with the Traffic Getaway icon visible on Home. Foregrounding the app returned to gameplay/result flow and ended at a `CAPTURED` result screen. The result screen showed `Caught by Police`, score 356, distance 314, cash `$71`, XP 60, 0 near misses, wanted level 3, progress `Level 2 176/200 XP`, and `Yellow Cab ready`.

Telemetry recorded 1 run, 0/1 completed, terminal `police_caught` at 9.0s, 0 near misses, 0 lane changed events, 0 autoplay decisions, 12 telemetry cash, and 0 collision analyses.

## Validity

Valid as functional active-gameplay background/foreground lifecycle evidence because the app went to Home during a gameplay run, foregrounded again, and reached a legitimate terminal result with raw telemetry and screenshots. Invalid for active-run, fairness, or balance coverage because telemetry recorded 0 lane changes and 0 active-input runs.
