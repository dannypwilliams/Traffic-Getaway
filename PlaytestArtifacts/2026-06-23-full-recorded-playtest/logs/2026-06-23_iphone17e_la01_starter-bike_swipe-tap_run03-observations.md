# Run Observations: iPhone 17e LA01 Starter Bike Swipe+Tap Run 03

## Setup

- Device: iPhone 17e simulator, iOS 26.5.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Vehicle: `starter_bike` / Starter Bike.
- Control mode: default `SWIPE + TAP`, tap input used.
- Capture mode: `capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running`.
- Video: `videos/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run03.mp4`.
- Start screenshot: `screenshots/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run03_start-screen.png`.
- Result screenshot: `screenshots/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run03_result-crashed.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_09-31-55-la_01-starter_bike-16090129143462915092.jsonl`.

## Result

- Terminal reason: traffic collision.
- Completion: no.
- Terminal time: 21.1s.
- Near misses: 3.
- Lane changes: 3.
- Cash: 34.
- Wanted level: 3.
- Autoplay decisions: 0.

## Observations

- The start gate correctly showed Los Angeles and Starter Bike before the explicit start tap.
- Tap steering produced visible bike movement and telemetry lane-change events.
- Wanted pressure escalated to MOTO 3 before terminal state.
- The run lasted materially longer than the Starter Compact samples but still ended far before a successful escape.

## Validity

Valid active-input complete-evidence run. Counts toward the Los Angeles Starter Bike three-run requirement.
