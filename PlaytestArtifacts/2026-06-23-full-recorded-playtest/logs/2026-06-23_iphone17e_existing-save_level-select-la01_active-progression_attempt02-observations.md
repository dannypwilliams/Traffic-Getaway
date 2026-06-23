# Run Observations: Existing-Save Level Select LA01 Active Progression Attempt 02

## Setup

- Device: iPhone 17e simulator, iOS 26.5.
- Save state: existing save after fresh-install tutorial/progression evidence and one uncounted input-smoke run.
- Flow: result screen, Level Select, Los Angeles city/progression screen, Sunset Merge start screen, active gameplay, result screen.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Vehicle: `starter_compact` in telemetry; visible UI label Sunset Cruiser.
- Control mode: default `SWIPE + TAP`, tap input used.
- Video: `videos/progression/2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02.mp4`.
- City/progression screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02_city-select.png`.
- Start screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02_start-screen.png`.
- Result screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02_result-crashed.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_10-17-12-la_01-starter_compact-existing-save-active-progression-17033032432948208794.jsonl`.
- Summary: `telemetry/summaries/2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02-summary.md`.

## Result

- Terminal reason: traffic collision.
- Completion: no.
- Terminal time: 8.5s.
- Near misses: 3.
- Lane changes: 3.
- Cash: 19 in telemetry; result screen showed cumulative reward/progression state.
- Wanted level: 3.
- Autoplay decisions: 0.

## Observations

- City/progression screen was reachable from the failure result screen via `LEVEL SELECT`.
- Los Angeles was selected, New York and Miami were visible as locked, and only Sunset Merge was ready.
- The run began from the visible `Tap to Start` gate.
- Coordinate tap input produced active lane-change telemetry and near-miss feedback.
- The run ended quickly as a traffic collision before the exit phase. Result screen showed `Level 1 -> 2`, proving existing-save progression/reward feedback advanced despite failure.

## Validity

Valid active-input progression/navigation sample. Counts toward city/progression screen evidence and valid active-input total. Does not satisfy the complete Los Angeles city-progression requirement because it did not complete Sunset Merge or progress through the city.
