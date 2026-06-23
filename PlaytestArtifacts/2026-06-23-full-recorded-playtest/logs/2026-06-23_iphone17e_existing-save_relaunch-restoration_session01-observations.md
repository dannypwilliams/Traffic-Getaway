# Existing-Save Relaunch Restoration Session 01 Observations

- Date: 2026-06-23
- Device: iPhone 17e simulator, iOS 26.5
- Flow: existing-save screen, app termination, app relaunch, restored start screen
- Initial video: `videos/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration_session01.mp4`
- Clean relaunch video: `videos/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration-clean_session02.mp4`
- Before terminate screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration_session01_before-terminate.png`
- First after relaunch screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration_session01_after-relaunch-start-screen.png`
- Clean before terminate screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration-clean_session02_before-terminate.png`
- Clean after relaunch screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration-clean_session02_after-relaunch.png`
- Debug cleanup log: `build-validation/relaunch-restoration-debug-defaults-cleanup-after-terminate.log`
- Final cleanup log: `build-validation/relaunch-restoration-debug-defaults-final-clean-after-capture.log`
- Telemetry: none; this session did not start a gameplay run.

## Observed Result

Before termination, the existing-save menu showed `TRAFFIC GETAWAY`, cash `$443`, best score 741, Level 2 progress `116 / 200 XP`, selected `SUNSET CRUISER`, and Los Angeles `Sunset Merge`.

After app termination and relaunch, the app restored to the Los Angeles start screen showing `Traffic Getaway`, `LOS ANGELES  Sunset Cruiser`, `Tap to Start`, `High Score 741`, and `Cash $443`. This proves the save-backed high score, cash, selected vehicle, and city/start context survived relaunch.

## Debug Defaults Note

The first relaunch landed on the start-gated level because debug auto-start defaults were present from prior manual-capture tooling. A cleanup pass removed those keys while preserving `TrafficGetaway.SaveData.v2`. A second clean relaunch session still restored to the same start screen with high score 741, cash `$443`, Los Angeles, and Sunset Cruiser visible. During the clean relaunch, the app/simulator environment reintroduced the debug auto-start keys after launch; final cleanup was performed after capture while the app was terminated, and the final log shows only audio/haptics preferences plus `TrafficGetaway.SaveData.v2` remaining.

## Validity

Partial for background/relaunch restoration because this used app termination and relaunch, not OS backgrounding and foregrounding. Partial for existing-save progression restoration because the relaunch visibly restored high score, cash, selected vehicle, and Los Angeles start context, but it did not restore to the richer main-menu progression screen with Level 2 XP visible after relaunch.
