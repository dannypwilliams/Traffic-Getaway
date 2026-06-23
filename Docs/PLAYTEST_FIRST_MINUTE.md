# First-Minute Playtest Notes

## Session

Date: 2026-06-22 local session.

Simulator: iPhone 17e, iOS 26.5.

Build: Debug simulator build from `Tools/mac/verify_on_mac.sh`.

## Findings

- The first launch capture reproduced a blank white system frame.
- After adding a named launch background color, the next fresh launch capture showed the dark tutorial screen instead.
- The onboarding skip path entered a live chase.
- One live telemetry sample ended in a traffic crash at 22.946s after 21 traffic waves.
- `scripts/summarize_run_telemetry.py` summarized the sample as 0/1 completed, 4 near misses, 44 cash, wanted level 3, with collision rectangles present.
- The debug open-path overlay was screenshot-verified, then disabled again in the simulator.
- A five-run debug-autoplay matrix was captured with active traffic snapshots in all collision samples.
- A six-run debug-autoplay decision matrix was captured. It showed 246 autoplay decisions, 36 move decisions, 4 target mismatches, and 35 applied-slot mismatches versus the GameSim policy target.
- No full clean-install tutorial matrix or human-controlled terminal outcome matrix was performed in this pass.

## Evidence

- `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/01-launch.png`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/02-launch-after-fix.png`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/04-live-telemetry-run.png`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/05-debug-diagnostics-overlay.png`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry/2026-06-22_18-49-43-la_01-starter_compact-17033032432948192956.jsonl`
- `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/summary.md`
- `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry/`
- `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/summary.md`
- `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/telemetry/`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`
