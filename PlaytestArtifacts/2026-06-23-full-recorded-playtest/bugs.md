# Defect Ledger

| ID | Severity | Title | Device/OS | City/Level | Vehicle | Control Mode | Build Commit | Frequency | Blocks Release | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|
| FTG-P1-001 | P1 | Active iPhone 17e LA01 runs all crash before 10 seconds | iPhone 17e / iOS 26.5 simulator | Los Angeles / la_01 Sunset Merge | Starter Compact | SWIPE + TAP using tap input | `35da9f8` | 6/6 recorded active runs | Yes, if confirmed by broader human play | `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md`, videos `run01`-`run06`, screenshots `run01`, `run02`, `run04`, `run05`, `run06` |

## FTG-P1-001 Details

- Reproduction steps: use iPhone 17e simulator, start `la_01` with `starter_compact` through `capture_live_telemetry.py --manual --wait-for-start-tap`, tap start, steer actively with tap inputs.
- Expected result: first-minute play should last long enough to evaluate responsiveness, readability, police pressure, and exit ramp-up; historical target says average first crash should be at least 30s.
- Actual result: all six recorded active-input samples ended as traffic collisions before 10 seconds.
- Random seeds: `17033032432948256308`, `17033032432948264227`, `17033032432948272146`, `17033032432948280065`, `17033032432948287984`, `17033032432948295903`.
- Notes: These are simulator runs driven through Codex UI control, not a broad human-play panel. Treat as a release-blocking signal to investigate, not final balance proof.

## Severity Reference

- P0: crash, data loss, impossible progression, or consistently unwinnable gameplay.
- P1: major control, fairness, progression, performance, or city-identity defect.
- P2: noticeable but non-blocking gameplay or presentation problem.
- P3: cosmetic or optional polish issue.
