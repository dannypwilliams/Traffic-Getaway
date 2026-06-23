# Run Observations: iPhone 17 Pro LA01 Dynamic Island Run 02

## Setup

- Device: iPhone 17 Pro simulator, iOS 26.5.
- Device class: Dynamic Island-class simulator.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Requested vehicle: `starter_bike`.
- Telemetry vehicle: `starter_compact`.
- Visible UI vehicle label: Sunset Cruiser.
- Control mode: default `SWIPE + TAP`, tap input used.
- Capture mode: `capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running`.
- Video: `videos/dynamic-island/2026-06-23_iphone17pro_la01_starter-compact_vehicle-mismatch_swipe-tap_dynamic-island_run02.mp4`.
- Start screenshot: `screenshots/dynamic-island/2026-06-23_iphone17pro_la01_starter-compact_vehicle-mismatch_swipe-tap_dynamic-island_run02_start-screen.png`.
- Result screenshot: `screenshots/dynamic-island/2026-06-23_iphone17pro_la01_starter-compact_vehicle-mismatch_swipe-tap_dynamic-island_run02_result-crashed.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_09-51-27-la_01-starter_compact-17033032432948438445.jsonl`.
- Summary: `telemetry/summaries/2026-06-23_iphone17pro_la01_starter-compact_vehicle-mismatch_swipe-tap_dynamic-island_run02-summary.md`.

## Result

- Terminal reason: traffic collision.
- Completion: no.
- Terminal time: 23.7s.
- Near misses: 5.
- Lane changes: 2.
- Cash: 49.
- Wanted level: 3.
- Autoplay decisions: 0.

## Observations

- The run began after the explicit start tap and telemetry recorded active input.
- The Dynamic Island visibly overlaps the top HUD band during gameplay. The wanted label and top status area sit under or behind the island in the captured video and screenshots.
- Controls remained usable, but the top HUD is not safely laid out for a Dynamic Island-class device.
- Vehicle identity is inconsistent: the requested debug vehicle was Starter Bike, telemetry reports `starter_compact`, and visible UI/result labels show Sunset Cruiser. Treat this run as valid for Dynamic Island safe-area evidence and active-input device coverage, but partial for vehicle-specific control coverage.

## Validity

Valid active-input functional Dynamic Island sample. Counts toward Dynamic Island device-profile evidence and safe-area check evidence. Does not count toward any city vehicle-run requirement.
