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
- A transition-clearance debug-autoplay matrix was captured after installing the new verified build. It showed 1/5 escapes, 26.7s average terminal time, 30.0s median terminal time, 23.4 traffic waves/run, 6.4 near misses/run, and only 2 lane-change intersection probes across 121 transitions.
- Transition-clearance read: this is the first live autoplay matrix to produce an escape and it moves first-minute feel toward target, but it still needs a tighter horizon/padding model before GameSim or balance changes.
- A tightened transition-clearance debug-autoplay matrix was captured after installing the verified build. It showed 5/5 escapes, 42.8s average terminal time, 42.7s median terminal time, 36.2 traffic waves/run, 14.0 near misses/run, 0 lane-change intersection probes across 183 transitions, and 18 `no_transition_safe_slots` decisions.
- Tightened transition-clearance read: the live safety adapter now covers sampled animated lane-change exposure, but this is not final balance evidence because debug autoplay completed every run.
- A Dynamic Island-class iPhone 17 Pro debug-autoplay matrix was captured with the same tightened transition-clearance build. It showed 3/5 escapes, 38.9s average terminal time, 42.3s median terminal time, 32.3s average first crash, 16.6 near misses/run, 0 lane-change intersection probes across 198 transitions, and 23 `no_transition_safe_slots` decisions.
- Dynamic Island read: the transition-path fix held, but 2/5 traffic collisions show that device-shape/live timing sensitivity is still not locked.
- A strict emergency-transition fallback was added to debug autoplay and rerun on iPhone 17 Pro. It improved the Dynamic Island sample to 4/5 escapes, 38.4s average terminal time, 42.4s median terminal time, 15.8 near misses/run, 0 lane-change intersection probes across 191 transitions, 1 `emergency_move`, and 19 `no_transition_safe_slots` decisions.
- Emergency-transition read: the fallback helps when strict transition filtering would freeze in a dangerous lane, but the remaining 1/5 traffic collision means this is not first-minute lock evidence.
- The active-traffic lifetime GameSim diagnostic was partially calibrated from the live transition evidence. It now uses deterministic transition-risk scoring and an emergency movement comparison, improving average survival from 7.3s to 10.7s, but it remains much too punitive versus live debug autoplay.
- A manual direct-start telemetry capture mode was added to `scripts/capture_live_telemetry.py`; it leaves debug autoplay off and waits for a human-controlled `run_ended` event.
- The final tutorial exit-ramp page had an impossible sign-rendering gate from an older six-page flow. The current build now renders `EXIT RIGHT` on the five-step final page and can auto-advance after the exit-side practice predicate and read gate are satisfied.
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
- `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/summary.md`
- `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry/`
- `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/notes.md`
- `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/summary.md`
- `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/telemetry/`
- `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/notes.md`
- `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/summary.md`
- `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry/`
- `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/notes.md`
- `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/summary.md`
- `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry/`
- `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/notes.md`
- `PlaytestArtifacts/2026-06-23-gamesim-active-lifetime-calibration/notes.md`
- `PlaytestArtifacts/2026-06-23-manual-capture-tooling/notes.md`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
- `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`
