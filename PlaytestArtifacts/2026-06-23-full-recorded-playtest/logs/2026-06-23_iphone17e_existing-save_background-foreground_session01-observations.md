# Existing-Save Background / Foreground Session 01 Observations

- Date: 2026-06-23
- Device: iPhone 17e simulator, iOS 26.5
- Flow: visible Traffic Getaway start screen, iOS Home screen, foreground Traffic Getaway again
- Video: `videos/progression/2026-06-23_iphone17e_existing-save_background-foreground_session01.mp4`
- Before Home screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_background-foreground_session01_before-home.png`
- iOS Home screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_background-foreground_session01_actual-home-screen.png`
- After foreground screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_background-foreground_session01_actual-after-foreground.png`
- Final debug cleanup log: `build-validation/background-foreground-debug-defaults-final-clean-after-capture.log`
- Telemetry: none; this session did not start a gameplay run.

## Observed Result

Before backgrounding, Traffic Getaway was visible on the Los Angeles start screen with `Traffic Getaway`, `LOS ANGELES  Sunset Cruiser`, `Tap to Start`, `High Score 741`, and `Cash $443`. The Simulator was sent to the iOS Home screen with the Traffic Getaway app icon visible. Launching Traffic Getaway again returned to the same Los Angeles start screen with the same high score, cash, city, and selected vehicle visible.

## Validity

Partial for background/foreground coverage. This proves the app can move to the iOS Home screen and foreground back to a preserved start state without losing visible high score, cash, city, or selected vehicle. It does not prove background/foreground behavior during an active gameplay run, and the app was still using the debug start-gate state introduced by prior manual capture tooling. Final cleanup removed the debug auto-start keys while preserving `TrafficGetaway.SaveData.v2`.
