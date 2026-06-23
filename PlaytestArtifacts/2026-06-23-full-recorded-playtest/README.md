# Full Recorded Playtest

## Scope

Evidence-based Traffic Getaway playtest pass for responsiveness, understandability, difficulty progression, procedural fairness, replayability, progression, performance, and city differentiation across Los Angeles, New York, and Miami.

This directory is the authoritative artifact root for the full recorded playtest requested on 2026-06-23. Do not mark a matrix row complete unless matching video, telemetry, summary, screenshots, and written observations exist.

Current status: partial. The iPhone 17e Los Angeles Starter Compact five-run slice is complete; the broader all-city/all-vehicle/all-device playtest remains incomplete.

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
- Start-gated manual capture tooling exists, and `--leave-app-running` was added during this pass so result-screen screenshots can be captured before the app is terminated. When this flag is used, terminate the app and verify debug defaults afterward.
- Post-run cleanup was verified after the LA Starter Compact capture set; `build-validation/post-run-debug-defaults-check.log` shows iPhone 17e debug defaults cleared to `[]`.
- Six valid active-input LA01 Starter Compact runs are recorded; five have complete screenshot evidence and one supplemental run is missing the result screenshot.

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
