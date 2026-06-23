# Defect Ledger

| ID | Severity | Title | Device/OS | City/Level | Vehicle | Control Mode | Build Commit | Frequency | Blocks Release | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| FTG-P1-001 | P1 | Active iPhone 17e LA01 runs all crash before 10 seconds | iPhone 17e / iOS 26.5 simulator | Los Angeles / la_01 Sunset Merge | Starter Compact | SWIPE + TAP using tap input | `35da9f8` | 6/6 recorded active runs | Yes, if confirmed by broader human play | `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md`, videos `run01`-`run06`, screenshots `run01`, `run02`, `run04`, `run05`, `run06` |
| FTG-P1-002 | P1 | Active iPhone 17e LA01 Starter Bike complete-evidence runs fail 3/3 | iPhone 17e / iOS 26.5 simulator | Los Angeles / la_01 Sunset Merge | Starter Bike | SWIPE + TAP using tap input | `378d832` | 3/3 complete-evidence active runs | Yes, if confirmed by broader human play | `telemetry/summaries/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_runs03-05-summary.md`, videos `run03`-`run05`, screenshots `run03`-`run05` |
| FTG-P2-001 | P2 | Dynamic Island overlaps top gameplay HUD | iPhone 17 Pro / iOS 26.5 simulator | Los Angeles / la_01 Sunset Merge | Visible UI: Sunset Cruiser; telemetry: Starter Compact | SWIPE + TAP using tap input | `dbe1519` | 2/2 Dynamic Island samples observed | No, but must be fixed before release UI signoff | `videos/dynamic-island/2026-06-23_iphone17pro_la01_starter-compact_vehicle-mismatch_swipe-tap_dynamic-island_run02.mp4`, screenshots under `screenshots/dynamic-island/` |
| FTG-P2-002 | P2 | iPhone 17 Pro debug vehicle identity mismatch during manual capture | iPhone 17 Pro / iOS 26.5 simulator | Los Angeles / la_01 Sunset Merge | Requested Starter Bike; telemetry Starter Compact; UI Sunset Cruiser | SWIPE + TAP using tap input | `dbe1519` | 2/2 Dynamic Island samples observed | No, but it weakens vehicle-specific test validity | `telemetry/raw/01-2026-06-23_09-51-27-la_01-starter_compact-17033032432948438445.jsonl`, start/result screenshots under `screenshots/dynamic-island/` |

## FTG-P1-001 Details

- Reproduction steps: use iPhone 17e simulator, start `la_01` with `starter_compact` through `capture_live_telemetry.py --manual --wait-for-start-tap`, tap start, steer actively with tap inputs.
- Expected result: first-minute play should last long enough to evaluate responsiveness, readability, police pressure, and exit ramp-up; historical target says average first crash should be at least 30s.
- Actual result: all six recorded active-input samples ended as traffic collisions before 10 seconds.
- Random seeds: `17033032432948256308`, `17033032432948264227`, `17033032432948272146`, `17033032432948280065`, `17033032432948287984`, `17033032432948295903`.
- Notes: These are simulator runs driven through Codex UI control, not a broad human-play panel. Treat as a release-blocking signal to investigate, not final balance proof.

## FTG-P1-002 Details

- Reproduction steps: use iPhone 17e simulator, start `la_01` with `starter_bike` through `capture_live_telemetry.py --manual --wait-for-start-tap`, tap start, steer actively with tap inputs.
- Expected result: the unlocked Starter Bike should be able to complete the opening Los Angeles level often enough to validate motorcycle control feel and progression payoff.
- Actual result: all three complete-evidence active-input samples failed before completion. Runs 03 and 04 ended as traffic collisions; Run 05 ended as a roadblock hit. Run 04 reached the right-exit countdown at about 50s but crashed before escape.
- Random seeds: `16090129143462915092`, `16090129143462923011`, `16090129143462930930`.
- Notes: These are simulator runs driven through Codex UI control. Treat as a release-blocking signal to investigate with broader human play before tuning.

## FTG-P2-001 Details

- Reproduction steps: use iPhone 17 Pro simulator, start `la_01` through the manual start-gated capture flow, tap start, observe the top HUD during active gameplay.
- Expected result: wanted level, score, cash, exit state, and top HUD text should sit below the Dynamic Island safe area without clipping or visual overlap.
- Actual result: the Dynamic Island overlaps the top HUD band; wanted/status text appears under or behind the island in the recording.
- Random seeds: active sample `17033032432948438445`; passive/invalid sample `17033032432948430526`.
- Notes: Controls remained usable in the active sample, but HUD readability is compromised on a required device class.

## FTG-P2-002 Details

- Reproduction steps: use iPhone 17 Pro simulator, run `capture_live_telemetry.py --manual --wait-for-start-tap --vehicle starter_bike`, then compare start/result UI labels with telemetry.
- Expected result: requested debug vehicle, visible UI vehicle label, and telemetry `vehicleID` should agree.
- Actual result: requested vehicle was Starter Bike, visible UI/result label showed Sunset Cruiser, while telemetry recorded `starter_compact`.
- Random seeds: `17033032432948430526`, `17033032432948438445`.
- Notes: This is treated as a playtest/tooling validity defect until the app-side debug vehicle selection path is verified.

## Severity Reference

- P0: crash, data loss, impossible progression, or consistently unwinnable gameplay.
- P1: major control, fairness, progression, performance, or city-identity defect.
- P2: noticeable but non-blocking gameplay or presentation problem.
- P3: cosmetic or optional polish issue.
