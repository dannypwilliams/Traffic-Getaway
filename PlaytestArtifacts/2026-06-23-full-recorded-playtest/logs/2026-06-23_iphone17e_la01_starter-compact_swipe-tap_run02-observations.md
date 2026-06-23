# Run Observations: iPhone 17e LA01 Starter Compact Swipe+Tap Run 02

## Metadata

- Device: iPhone 17e simulator
- OS: iOS 26.5
- Commit: `35da9f8`
- Level: `la_01` / Sunset Merge / Los Angeles
- Vehicle: `starter_compact` / Starter Compact
- Control mode: default `SWIPE + TAP`; this run used tap inputs
- Seed: `17033032432948264227`
- Video: `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run02.mp4`
- Raw telemetry: `telemetry/raw/01-2026-06-23_09-18-11-la_01-starter_compact-17033032432948264227.jsonl`
- Summary: `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md`
- Screenshots:
  - `screenshots/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run02_start-screen.png`
  - `screenshots/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run02_result-crashed.png`

## Validity

Valid active-input run.

- Began after explicit start tap: yes.
- Active telemetry detected: yes.
- Intentional steering recorded: yes, 3 lane changes.
- Continued to terminal state: yes, `traffic` collision at 4.6s.
- Complete metadata/video/telemetry: yes.

## Observations

- Controls accepted tap input and lane changes happened quickly.
- Near-miss feedback appeared (`NEAR MISS x3 1.6x`) before the collision.
- The traffic-collision overlay explained that the hitbox overlapped traffic and suggested committing earlier.
- The failure was very early, before exit activation or any meaningful difficulty ramp.

## Read

Useful valid active run, but the 4.6s crash is too early to evaluate first-minute pacing beyond the opening traffic spike.

