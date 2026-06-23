# Existing-Save LA01 Active Progression Attempt 03 Observations

- Date: 2026-06-23
- Device: iPhone 17e simulator, iOS 26.5
- Level: `la_01` / Sunset Merge
- Vehicle: telemetry `starter_compact`; visible result screen `Sunset Cruiser`
- Control mode: intended default `SWIPE + TAP` using coordinate taps after the start gate
- Video: `videos/progression/2026-06-23_iphone17e_existing-save_la01_active-progression_attempt03.mp4`
- Start screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_la01_active-progression_attempt03_start-screen.png`
- Result screenshot: `screenshots/progression/2026-06-23_iphone17e_existing-save_la01_active-progression_attempt03_result-captured.png`
- Raw telemetry: `telemetry/raw/01-2026-06-23_10-24-45-la_01-starter_compact-existing-save-active-progression-attempt03-17033032432948216713.jsonl`
- Summary: `telemetry/summaries/2026-06-23_iphone17e_existing-save_la01_active-progression_attempt03-summary.md`

## Observed Result

The run launched from the visible `Tap to Start` gate and reached a terminal result screen. The result screen showed `CAPTURED`, `Reason Caught by Police`, score 356, distance 314, cash `$71`, 60 XP, 0 near misses, best combo x0, wanted level 3, and player progress `Level 2 116/200 XP`.

Telemetry recorded 1 run, 0/1 completed, terminal `police_caught` at 9.0s, 0 near misses, 0 lane changed events, 0 lane-change probes, 0 autoplay decisions, 12 telemetry cash, and pattern mix `denseClusters` 5, `sparseLanes` 2, `staggeredCars` 2.

## Validity

Invalid for active-run, balance, fairness, and complete city-progression coverage. Although coordinate taps were attempted after the start gate, telemetry recorded 0 lane changes and classified 0/1 active-input runs. This evidence is retained as an invalid progression attempt and as a record that this simulator coordinate path did not satisfy the active-run rule.
