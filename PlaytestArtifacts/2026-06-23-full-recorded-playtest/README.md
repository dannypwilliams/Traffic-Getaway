# Full Recorded Playtest

## Scope

Evidence-based Traffic Getaway playtest pass for responsiveness, understandability, difficulty progression, procedural fairness, replayability, progression, performance, and city differentiation across Los Angeles, New York, and Miami.

This directory is the authoritative artifact root for the full recorded playtest requested on 2026-06-23. Do not mark a matrix row complete unless matching video, telemetry, summary, screenshots, and written observations exist.

Current status: partial. The iPhone 17e Los Angeles Starter Compact five-run slice and Los Angeles Starter Bike three-run slice are complete, failure/retry has recorded evidence, one iPhone 17 Pro Dynamic Island active sample has been captured, fresh-install tutorial completion has recorded evidence, the City Select / Level Select progression screen has recorded evidence, Garage/vehicle browsing has partial recorded evidence, relaunch/save restoration has partial recorded evidence, pause/restart-after-pause has a recorded negative probe, completion/reward UI has debug-assisted result evidence, and New York/Miami start gates have start-screen-only evidence. The broader all-city/all-device active-play matrix remains incomplete.

## Starting State

- Branch: `main`
- Starting commit: `3c2431d`
- Repository state at setup: clean and aligned with `origin/main`
- Build configuration: Debug/playtest simulator configuration
- Physical hardware: unavailable in this pass; simulator evidence must be labeled as simulator-only

## Devices

- iPhone 17e, iOS 26.5, UDID `8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E`
- iPhone 17 Pro, iOS 26.5, UDID `90D3514A-BDE2-412C-8238-8ECC17BD86B6`

## Supported Content Inventory

- Cities: Los Angeles, New York, Miami
- Levels: 15 total, 5 per city
- Required vehicles for this pass: `starter_compact` and `starter_bike`
- Control modes: `SWIPE + TAP`, `SWIPE ONLY`, `TAP ONLY`
- Manual capture mode: `scripts/capture_live_telemetry.py --manual --wait-for-start-tap`

## Known Limitations

- No physical-device validation has been performed.
- Previous artifacts include simulator screenshots and telemetry, but this full pass requires video in addition to screenshots; old screenshot-only evidence is reference material, not proof of a completed required test.
- The latest active iPhone 17e manual attempt outside this folder produced only 1/5 active-input runs and is invalid for balance conclusions.
- Start-gated manual capture tooling exists, `--leave-app-running` can preserve the result UI for screenshots, and `--control-preference` can seed `SWIPE + TAP`, `SWIPE ONLY`, or `TAP ONLY` saves for future control-mode coverage. When result-preservation or preference seeding is used, terminate the app and verify debug defaults afterward.
- Post-run cleanup was verified after the LA Starter Compact capture set; `build-validation/post-run-debug-defaults-check.log` shows iPhone 17e debug defaults cleared to `[]`.
- Six valid active-input LA01 Starter Compact runs are recorded; five have complete screenshot evidence and one supplemental run is missing the result screenshot.
- Three complete-evidence active-input LA01 Starter Bike runs are recorded in Runs 03, 04, and 05. A prior Bike Run 02 has telemetry/result evidence but is rejected from the complete-evidence count because the start screenshot and video are missing.
- Failure-and-retry functional coverage is recorded in `videos/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01.mp4`.
- Dynamic Island-class coverage is recorded in `videos/dynamic-island/2026-06-23_iphone17pro_la01_starter-compact_vehicle-mismatch_swipe-tap_dynamic-island_run02.mp4`, but the safe-area check failed because the Dynamic Island overlaps the top HUD. See `FTG-P2-001`.
- The iPhone 17 Pro Dynamic Island capture also exposed a vehicle identity mismatch: the run requested Starter Bike, telemetry reported `starter_compact`, and visible UI/result labels showed Sunset Cruiser. See `FTG-P2-002`. Treat the sample as valid for Dynamic Island safe-area evidence, but only partial for vehicle-specific control coverage.
- Fresh-install tutorial completion is recorded in `videos/progression/2026-06-23_iphone17e_fresh-install_tutorial-la-progression_attempt01.mp4`. The follow-on gameplay run had 0 lane changes and ended as police capture at 9.0s, so it is valid tutorial/progression-flow evidence but invalid for active-run, balance, or complete city-progression coverage.
- Existing-save Level Select to LA01 active progression evidence is recorded in `videos/progression/2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02.mp4`. It has 3 lane changes and 3 near misses, but ended as a traffic collision at 8.5s, so complete Los Angeles city progression remains open.
- Existing-save LA01 progression attempt 03 is recorded in `videos/progression/2026-06-23_iphone17e_existing-save_la01_active-progression_attempt03.mp4` with start/result screenshots and telemetry, but is invalid for active-run and city-progression coverage because telemetry recorded 0 lane changes and terminal `police_caught` at 9.0s.
- Existing-save Garage/vehicle browsing is recorded in `videos/progression/2026-06-23_iphone17e_existing-save_garage-vehicle-selection_session01.mp4`; it proves Garage access, selected Sunset Cruiser display, Cars/Bikes tab switching, locked Starter Bike messaging, and return navigation, but does not prove selecting an alternate unlocked vehicle.
- Existing-save relaunch restoration is recorded in `videos/progression/2026-06-23_iphone17e_existing-save_relaunch-restoration-clean_session02.mp4`; it proves high score, cash, selected vehicle, and Los Angeles start context survive termination/relaunch, but it does not prove OS background/foreground behavior or full main-menu progression restoration.
- Existing-save background/foreground is recorded in `videos/progression/2026-06-23_iphone17e_existing-save_background-foreground_session01.mp4`; it proves Home-screen backgrounding and foregrounding back to the Los Angeles start state, but not active-gameplay backgrounding.
- Active-gameplay background/foreground is recorded in `videos/progression/2026-06-23_iphone17e_la01_active-gameplay_background-foreground_session01.mp4`; it proves Home-screen backgrounding during a run and foregrounding into a terminal captured result, but the gameplay sample is invalid for active-run/balance coverage because telemetry recorded 0 lane changes.
- Pause/settings probing is recorded in `videos/progression/2026-06-23_iphone17e_la01_pause-settings-probe_session01.mp4`; it proves start-screen Settings opens and returns with Back, and it shows no app-level Pause, Resume, Settings, Back, or Restart control during active gameplay. The run is invalid for active-run/balance coverage because telemetry recorded 0 lane changes. See `FTG-P2-003`.
- Completion/reward UI is recorded in `videos/progression/2026-06-23_iphone17e_la01_debug-first-escape_completion-reward_session01.mp4`; it proves the result screen can show `ESCAPED`, cash/XP reward, `Level 1 -> 2`, `Starter Bike unlocked: split lanes`, and primary `USE BIKE`. It is partial evidence only because it uses the debug-only `first_escape_starter_bike` synthetic result scenario rather than a real active-input completion.
- New York and Miami start gates are recorded in `videos/city-2/2026-06-23_iphone17e_ny01_starter-compact_start-gate.mp4` and `videos/city-3/2026-06-23_iphone17e_mia01_starter-compact_start-gate.mp4`, with matching screenshots and debug-default cleanup logs. These are start-screen-only artifacts and do not count as active-input runs, city progression, balance, fairness, or completion evidence.

## Artifact Structure

- `metadata.json`: run metadata and inventory.
- `test-matrix.md`: planned tests, statuses, and evidence links.
- `findings.md`: observations and release-readiness read.
- `bugs.md`: prioritized defect ledger.
- `balance-observations.md`: human, telemetry, and simulation balance notes.
- `acceptance-report.md`: current acceptance rollup.
- `screenshots/`: required screenshots by area.
- `videos/`: required full-screen recordings by area.
- `telemetry/raw/`: raw JSONL telemetry.
- `telemetry/summaries/`: generated telemetry summaries.
- `logs/`: command logs and runtime logs.
- `build-validation/`: build/test outputs.
