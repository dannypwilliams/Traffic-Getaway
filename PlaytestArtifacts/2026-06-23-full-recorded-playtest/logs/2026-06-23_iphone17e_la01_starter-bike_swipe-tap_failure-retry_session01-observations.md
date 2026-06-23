# Functional Observations: Failure And Retry Session 01

## Setup

- Device: iPhone 17e simulator, iOS 26.5.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Vehicle shown and captured: `starter_bike` / Starter Bike.
- Control mode: default `SWIPE + TAP`, tap input used.
- Capture mode: `capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running`.
- Video: `videos/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01.mp4`.
- Start screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01_start-screen.png`.
- Result screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01_result-crashed.png`.
- Retry proof screenshot: `screenshots/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01_retry-start-screen.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_09-42-21-la_01-starter_bike-16090129143462938849.jsonl`.
- Summary: `telemetry/summaries/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01-summary.md`.

## Result

- Terminal reason: traffic collision.
- Completion: no.
- Terminal time: 26.2s.
- Near misses: 8.
- Lane changes: 4.
- Cash: 57.
- Wanted level: 3.
- Autoplay decisions: 0.

## Functional Coverage

- Failure screen was visible and captured after the run ended.
- `RETRY LEVEL` was tapped from the result screen.
- The game returned to the Los Angeles Starter Bike start screen, proving the retry path starts a new ready state.
- The video covers the complete flow from before the start tap, through active play and failure, through retry, and back to the start screen.

## Validity

Valid active-input functional session. Counts toward failure-and-retry functional coverage, but not toward the LA Starter Bike three-run city requirement because that requirement was already satisfied by Runs 03, 04, and 05.
