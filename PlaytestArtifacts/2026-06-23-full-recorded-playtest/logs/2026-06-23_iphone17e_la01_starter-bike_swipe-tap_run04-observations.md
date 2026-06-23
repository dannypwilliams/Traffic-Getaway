# Run Observations: iPhone 17e LA01 Starter Bike Swipe+Tap Run 04

## Setup

- Device: iPhone 17e simulator, iOS 26.5.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Vehicle: `starter_bike` / Starter Bike.
- Control mode: default `SWIPE + TAP`, tap input used.
- Capture mode: `capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running --app ''`.
- Video: `videos/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run04.mp4`.
- Start screenshot: `screenshots/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run04_start-screen.png`.
- Result screenshot: `screenshots/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run04_result-crashed.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_09-33-40-la_01-starter_bike-16090129143462923011.jsonl`.

## Result

- Terminal reason: traffic collision.
- Completion: no.
- Terminal time: 50.2s.
- Near misses: 11.
- Lane changes: 9.
- Cash: 101.
- Wanted level: 3.
- Autoplay decisions: 0.

## Observations

- This was the strongest active-bike sample in the set.
- The run included construction/blockage warning, roadblock warning, wanted pressure, near-miss feedback, and a visible right-exit countdown.
- The player reached the exit phase but crashed before completion.
- The longer duration makes this run useful for first-minute readability and pressure pacing, even though it still failed.

## Validity

Valid active-input complete-evidence run. Counts toward the Los Angeles Starter Bike three-run requirement.
