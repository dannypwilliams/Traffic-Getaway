# Run Observations: iPhone 17e LA01 Starter Compact Swipe+Tap Run 01

## Metadata

- Device: iPhone 17e simulator
- OS: iOS 26.5
- Commit: `3c2431d`
- Level: `la_01` / Sunset Merge / Los Angeles
- Vehicle: `starter_compact` / Starter Compact
- Control mode: default `SWIPE + TAP`; this run used tap inputs
- Seed: `17033032432948256308`
- Video: `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run01.mp4`
- Raw telemetry: `telemetry/raw/01-2026-06-23_09-12-16-la_01-starter_compact-17033032432948256308.jsonl`
- Summary: `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run01-summary.md`
- Screenshots:
  - `screenshots/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run01_start-screen.png`
  - `screenshots/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run01_result-crashed.png`

## Validity

Valid active-input run.

- Began after explicit start tap: yes.
- Active telemetry detected: yes, `Active-input runs: 1/1`.
- Intentional steering recorded: yes, 2 `lane_changed` events and 3 lane-change probes.
- Continued to terminal state: yes, `traffic` collision at 9.0s.
- Complete metadata/video/telemetry: yes.

## Observations

- Controls responded to tap input and changed lanes.
- The run ended quickly at 9.0s, before exit activation.
- Telemetry shows 1 near miss, 2 lane changes, 8 traffic waves, and 0 autoplay decisions.
- Collision telemetry was present and recorded a large overlap area plus active traffic context.
- The result screen clearly reported `CRASHED`, `Traffic Collision`, score, distance, cash, XP, near misses, wanted level, and retry/menu navigation.

## Read

This is good evidence that the start-gated capture path can produce a valid recorded active run. It is only one short failed run, so it does not validate first-minute balance, city identity, or overall control feel by itself.

