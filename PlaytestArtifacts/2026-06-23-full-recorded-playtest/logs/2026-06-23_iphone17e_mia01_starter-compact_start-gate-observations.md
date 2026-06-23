# MIA01 Starter Compact Start Gate Observations

- Device: iPhone 17e simulator, iOS 26.5.
- Build/context: existing installed Debug simulator build, repository HEAD `28bde84` before this evidence update.
- Setup: simulator guest defaults set `TrafficGetaway.debug.autoStartLevelID=mia_01`, `TrafficGetaway.debug.autoStartVehicleID=starter_compact`, `TrafficGetaway.debug.autoplay=false`, and `TrafficGetaway.debug.waitForStartTap=true`.
- Evidence: `videos/city-3/2026-06-23_iphone17e_mia01_starter-compact_start-gate.mp4`, `screenshots/city-3/2026-06-23_iphone17e_mia01_starter-compact_start-gate.png`, `logs/2026-06-23_iphone17e_mia01_starter-compact_start-gate_probe.log`.
- Observed result: the start gate visibly shows `MIAMI` and `Sunset Cruiser` with `Tap to Start`.
- Validity: start-gate-only evidence. No start tap, active steering, raw run telemetry, result screen, balance conclusion, fairness conclusion, or city progression coverage was captured.
- Cleanup: debug defaults were cleared afterward; proof is saved at `build-validation/mia01-start-gate-debug-defaults-cleanup.log`.
