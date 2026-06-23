# Run Observations: iPhone 17e LA01 Starter Bike Swipe+Tap Run 05

## Setup

- Device: iPhone 17e simulator, iOS 26.5.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Vehicle: `starter_bike` / Starter Bike.
- Control mode: default `SWIPE + TAP`, tap input used.
- Capture mode: `capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running --app ''`.
- Video: `videos/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run05.mp4`.
- Start screenshot: `screenshots/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run05_start-screen.png`.
- Result screenshot: `screenshots/city-1/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run05_result-roadblock-hit.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_09-35-19-la_01-starter_bike-16090129143462930930.jsonl`.

## Result

- Terminal reason: roadblock hit.
- Completion: no.
- Terminal time: 11.2s.
- Near misses: 2.
- Lane changes: 1.
- Cash: 18.
- Wanted level: 3.
- Autoplay decisions: 0.

## Observations

- The run reached MOTO 3 quickly and prompted lane-change pressure before the terminal state.
- The result screen showed a distinct roadblock-hit terminal, adding blockage coverage beyond traffic-collision-only samples.
- The run was shorter and less informative than Run 04 but still has complete evidence and active-input telemetry.

## Validity

Valid active-input complete-evidence run. Counts toward the Los Angeles Starter Bike three-run requirement.
