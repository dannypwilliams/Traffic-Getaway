# Run Observations: iPhone 17e LA01 Starter Compact Swipe+Tap Run 03

## Metadata

- Device: iPhone 17e simulator
- OS: iOS 26.5
- Commit: `35da9f8`
- Level: `la_01` / Sunset Merge / Los Angeles
- Vehicle: `starter_compact` / Starter Compact
- Control mode: default `SWIPE + TAP`; this run used tap inputs
- Seed: `17033032432948272146`
- Video: `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run03.mp4`
- Raw telemetry: `telemetry/raw/01-2026-06-23_09-18-53-la_01-starter_compact-17033032432948272146.jsonl`
- Summary: `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md`
- Screenshots:
  - `screenshots/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run03_start-screen.png`

## Validity

Valid active-input telemetry/video run, but incomplete screenshot evidence.

- Began after explicit start tap: yes.
- Active telemetry detected: yes.
- Intentional steering recorded: yes, 4 lane changes.
- Continued to terminal state: yes, `traffic` collision at 9.9s.
- Complete metadata/video/telemetry: yes.
- Missing evidence: result-screen screenshot was not captured because the capture script terminated the app before the screenshot was taken.

## Observations

- This run lasted longer than the first two and recorded 4 lane changes.
- The run still ended before exit activation.
- The missing result screenshot exposed a capture-tooling problem, fixed afterward with `--leave-app-running`.

## Read

Useful active telemetry/video evidence, but excluded from the five complete-evidence LA Starter Compact count because the result screenshot is missing.

