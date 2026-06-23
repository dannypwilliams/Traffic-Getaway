# Run Observations: Fresh-Install Tutorial And LA Progression Attempt 01

## Setup

- Device: iPhone 17e simulator, iOS 26.5.
- Install state: app uninstalled and reinstalled before recording to reset save data.
- Flow: first launch, onboarding pages 1-5 completed without using skip, then automatic transition into the first Los Angeles run.
- Level: `la_01` / Sunset Merge / Los Angeles.
- Vehicle: `starter_compact` in telemetry; visible result label Sunset Cruiser.
- Control mode: default `SWIPE + TAP`.
- Video: `videos/progression/2026-06-23_iphone17e_fresh-install_tutorial-la-progression_attempt01.mp4`.
- Tutorial screenshots: `screenshots/tutorial/2026-06-23_iphone17e_fresh-install_tutorial-progression_attempt01_*.png`.
- Result screenshot: `screenshots/progression/2026-06-23_iphone17e_fresh-install_tutorial-la-progression_attempt01_result-captured.png`.
- Telemetry: `telemetry/raw/01-2026-06-23_10-02-16-la_01-starter_compact-fresh-install-progression-17033032432948192956.jsonl`.
- Summary: `telemetry/summaries/2026-06-23_iphone17e_fresh-install_tutorial-la-progression_attempt01-summary.md`.

## Result

- Tutorial completion: completed without using skip.
- Terminal reason: police caught.
- Completion: no.
- Terminal time: 9.0s.
- Near misses: 0.
- Lane changes: 0.
- Cash: 12.
- Wanted level: 3.
- Autoplay decisions: 0.

## Observations

- The first-run onboarding sequence was understandable enough to complete all five pages with the visible controls.
- The tutorial transitioned directly into Los Angeles gameplay after the final exit-ramp lesson.
- The gameplay portion did not receive meaningful active steering after the transition. Telemetry recorded 0 lane changes and the run ended as passive police capture at 9.0s.
- The result screen communicated the failure reason, reward/progression line, and retry/level-select/menu actions.
- The recorded video was compressed after capture from the original simulator recording to keep the evidence file below GitHub's file-size limit.

## Validity

Valid fresh-install tutorial and first-run progression-flow evidence. Invalid for active-run, balance, fairness, or complete city-progression coverage because telemetry recorded 0 active lane changes and the attempt did not progress past the opening Los Angeles run.
