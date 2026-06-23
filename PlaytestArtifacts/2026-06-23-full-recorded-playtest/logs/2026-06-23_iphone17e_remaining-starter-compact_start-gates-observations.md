# Remaining Starter Compact Start-Gate Observations

- Device: iPhone 17e simulator, iOS 26.5.
- Build/context: existing installed Debug simulator build, repository HEAD `96c64c0` before this evidence update.
- Scope: configured start-gate captures for `la_02`, `la_03`, `la_04`, `la_05`, `ny_02`, `ny_03`, `ny_04`, `ny_05`, `mia_02`, `mia_03`, `mia_04`, and `mia_05`.
- Setup: simulator guest defaults set `TrafficGetaway.debug.autoStartLevelID` to the target level, `TrafficGetaway.debug.autoStartVehicleID=starter_compact`, `TrafficGetaway.debug.autoplay=false`, and `TrafficGetaway.debug.waitForStartTap=true`.
- Evidence: videos under `videos/city-*/*_starter-compact_start-gate.mp4`, screenshots under `screenshots/city-*/*_starter-compact_start-gate.png`, per-level probe logs under `logs/*_starter-compact_start-gate_probe.log`, and cleanup logs under `build-validation/*-start-gate-debug-defaults-cleanup.log`.
- Observed result: representative Los Angeles, New York, and Miami screenshots show the expected city start gate with `Sunset Cruiser` and `Tap to Start`.
- Limitation: the start screen visibly confirms city and vehicle only; it does not display the specific level name. Level-specific evidence comes from the debug-default probe logs.
- Validity: start-gate-only evidence. No start tap, active steering, raw run telemetry, result screen, balance conclusion, fairness conclusion, stress run, or city progression coverage was captured.
