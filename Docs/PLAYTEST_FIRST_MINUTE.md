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
- A corrected five-run debug-autoplay decision matrix was captured. It showed 207 autoplay decisions, 18 move decisions, 36 target-policy mismatches, 2 move-target mismatches, and 2 applied-slot mismatches versus the GameSim policy target.
- A live-hazard debug-autoplay matrix was captured after explicitly installing the new build. It showed 5/5 traffic collisions, 8.6s average terminal time, 269 decisions, 176 live-hazard decisions, and one run that survived 24.9s.
- A collision-analysis debug-autoplay matrix was captured after installing the new verified build. It showed 5/5 traffic collisions, 5/5 collision-analysis payloads, 5.2s average terminal time, 10.6 active traffic nodes at collision on average, and a `move` as the last autoplay decision before every crash.
- Crash-frame read: the next sim/live gap is lane-change transition timing/path occupancy. Live state can mark the target slot while SpriteKit collision still checks the animated car along the movement path.
- A lane-change parity debug-autoplay matrix was captured after installing the new verified build. It showed 163 lane-change probes across 26 transitions, 3 transition probes already intersecting traffic, 1 unsafe-path probe, and 3/5 last pre-crash probes intersecting traffic.
- Parity read: add transition-clearance checks before moving and a short target-slot danger horizon after moving, then rerun the matrix before touching balance.
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
- `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/summary.md`
- `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/telemetry/`
- `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/summary.md`
- `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry/`
- `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/notes.md`
- `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/summary.md`
- `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry/`
- `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/notes.md`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`
