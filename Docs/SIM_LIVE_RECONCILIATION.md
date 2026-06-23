# Sim/Live Reconciliation

## Status

Partial. Core stress gates are fixed, debug live gameplay telemetry works, and iPhone 17e autoplay matrices now exist. Transition-clearance debug autoplay produced the first escaped run in the live autoplay matrices and improved average terminal time to 26.7s, but still crashed 4/5 runs. The remaining GameSim-vs-live gap is narrowed to stricter transition clearance, target-slot danger horizon, and active traffic lifetime.

## Known Modeling Gap

The iOS app still owns local presentation/gameplay definitions (`LevelData`, `LaneManager`, `TrafficPatternGenerator`, `TrafficSafetyAnalyzer`, collision and run systems) while `GameCore` owns pure simulation definitions. This duplication is the main drift risk.

## Current Comparison

| Metric | GameSim | iOS live | Difference | Cause | Resolution |
|---|---:|---:|---:|---|---|
| Exit activation time | 42s target from config | Reached in 1/5 transition-clearance autoplay runs | Live still usually ends before exit | Transition/path safety improved but remains incomplete | Tighten clearance before tuning |
| First crash time | p50 36.8s | median 25.2s / avg 22.3s among crashes | Live autoplay still earlier | 2/5 last pre-crash lane probes still intersected traffic | Reconcile lane-change timing/path occupancy |
| Traffic waves before failure | Stress: 0 impossible / 160,000 | avg 23.4 waves before terminal event | Much closer, still below sim | GameSim does not model active on-screen traffic lifetime or animated lane changes directly | Add stricter transition-aware comparison |
| Near misses | 35.3/run | 6.4/run | Live now near target range but not model-parity evidence | Longer runs plus transition filtering | Do not tune rewards from this sample alone |
| Completion | 99.1% | 1/5 autoplay completed | Major mismatch, but improved | Live route decision/state is still not equivalent to GameSim run model | Reconcile sim/live model |
| Collision box overlap | Unfair estimate 0.0% | Rects logged on every collision | Data available | App collision code separate | Review active traffic snapshots |
| Reachable path at failure | Stress clean | Safe slots, active traffic, colliding vehicle, overlap, last decision, and lane-change probes logged | Lane-change samples available | Latest safe slot can be logically safe while the animated car is still exposed on the lane-change path | Guard the transition path and horizon |
| Police pressure at failure | Highest wanted 3 | Wanted mostly 1, one sample not above 2 | Live crashes before police peak | Early input/traffic interaction dominates | Keep police tuning unchanged |

## Live Evidence

### Manual Smoke Sample

- Telemetry file: `PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry/2026-06-22_18-49-43-la_01-starter_compact-17033032432948192956.jsonl`
- Screenshot: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/04-live-telemetry-run.png`
- Debug overlay screenshot: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/05-debug-diagnostics-overlay.png`
- Simulator log: `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`
- Events: 24 total; `run_started` 1, `traffic_wave` 21, `collision` 1, `run_ended` 1.
- Pattern mix: `staggeredCars` 8, `denseClusters` 6, `sparseLanes` 6, `recoveryWave` 1.
- Terminal outcome: traffic collision at 22.946s.

### Autoplay Matrix With Active Traffic

- Capture command: `python3 scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry --timeout 100`
- Summary: `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/summary.md`
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 6.4s.
- Median terminal time: 4.4s.
- Avg traffic waves: 6.2.
- Avg near misses: 2.2.
- Avg cash: 16.
- Terminal reasons: `traffic` 5.
- Collision rectangles: present in all 5 runs.
- Active traffic snapshots: present in all 5 collision samples.

### Autoplay Decision Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/telemetry --timeout 100`
- Summary: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/summary.md`
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 6.3s.
- Median terminal time: 5.2s.
- Avg traffic waves: 6.2.
- Avg near misses: 0.6.
- Terminal reasons: `traffic` 5.
- Autoplay decisions: 207.
- Autoplay move decisions: 18.
- Autoplay target mismatches: 36.
- Autoplay move-target mismatches: 2.
- Autoplay applied-slot mismatches: 2.
- Interpretation: corrected applied-slot telemetry shows actual moves usually land on the intended target. The remaining mismatch is mostly policy/state: live sometimes stays when GameSim would move, and live reaches no-safe-route frames much earlier than the aggregate simulator.

### Live-Hazard Autoplay Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/summary.md`
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 8.6s.
- Median terminal time: 4.5s.
- Avg traffic waves: 8.4.
- Avg near misses: 2.6.
- Terminal reasons: `traffic` 5.
- Autoplay decisions: 269.
- Autoplay move decisions: 41.
- Autoplay decision sources: `debug_autoplay_live_hazards` 176, `debug_autoplay_latest_wave` 93.
- Autoplay decision statuses: `already_at_target` 205, `move` 41, `no_reachable_slots` 23.
- Interpretation: live-hazard steering improved average terminal time versus the corrected latest-wave matrix (8.6s versus 6.3s) and produced one 24.9s run, but still did not reach the exit. Stale latest-wave steering is not the whole cause.

### Collision-Analysis Autoplay Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/notes.md`
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 5.2s.
- Median terminal time: 4.7s.
- Avg traffic waves: 5.4.
- Avg near misses: 1.0.
- Terminal reasons: `traffic` 5.
- Collision analyses: 5/5.
- Avg collision overlap area: 94.2.
- Avg active traffic at collision: 10.6.
- Collision last-decision sources: `debug_autoplay_live_hazards` 4, `debug_autoplay_latest_wave` 1.
- Collision last-decision statuses: `move` 5.
- Interpretation: the remaining mismatch is not only which slot the policy chooses. The live car can still collide while moving between slots, so GameSim and/or live route safety must account for lane-change duration/path occupancy.

### Lane-Change Parity Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/notes.md`
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 7.9s.
- Median terminal time: 6.6s.
- Avg traffic waves: 7.6.
- Avg near misses: 1.8.
- Terminal reasons: `traffic` 5.
- Lane-change probes: 163.
- Lane-change transitions: 26.
- Lane-change intersection probes: 3.
- Lane-change unsafe-path probes: 1.
- Last pre-crash probe intersected traffic: 3/5.
- Interpretation: transition path safety is a real cause, but not the only one. One sampled crash happened after a fast-swipe latest-wave move settled into a vehicle, and one happened after the move completed while autoplay was already at target. The next fix should combine transition clearance with a short target-slot danger horizon.

### Transition-Clearance Autoplay Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/notes.md`
- Runs: 5.
- Completed: 1/5.
- Avg terminal time: 26.7s.
- Median terminal time: 30.0s.
- Avg traffic waves: 23.4.
- Avg near misses: 6.4.
- Terminal reasons: `escaped` 1, `traffic` 4.
- Lane-change probes: 742.
- Lane-change transitions: 121.
- Lane-change intersection probes: 2.
- Lane-change unsafe-path probes: 1.
- Last pre-crash probe intersected traffic: 2/5.
- Interpretation: transition clearance is the first diagnostic change to produce an escape and move live telemetry toward the target first-minute feel. It still needs a stronger horizon/padding model before this should be moved into GameSim or used for balance tuning.

## Summarizer

Run:

```bash
python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry
```

Manual smoke result:

- Runs: 1.
- Completed: 0/1.
- Avg terminal time: 22.9s.
- Avg near misses: 4.0.
- Avg cash: 44.
- Terminal reasons: `traffic` 1.
- Collision rectangles: present.
- Active traffic column is present for new-schema telemetry.
- Decision telemetry columns are present for new-schema autoplay telemetry.

## Current Read

Do not retune Sunset Merge from the autoplay matrix yet. The core simulator says the route policy can escape almost every run, while debug autoplay now escapes only 1/5 runs after transition clearance. The diagnostic direction is validated: transition clearance improved terminal time and produced an escape. The next discrepancy is the exact clearance model: GameSim treats route steps as discrete safe-slot decisions, while live keeps spawned traffic on screen and checks the animated sprite along its movement path.

## Debug Rendering

The `OPEN PATHS` debug preference now draws lane centers, slot centers, safe-slot columns, active exit corridor, near-miss band, player hitbox, traffic hitboxes, active wave ID, and seed. This gives the live screenshot a direct visual counterpart to the JSONL fields.

## Next Instrumentation

- Tighten transition-clearance debug autoplay with a longer target-slot horizon and small vertical padding on predicted traffic hitboxes.
- Rerun the transition-clearance matrix and compare completion, terminal time, lane-change intersections, unsafe-path probes, and `no_transition_safe_slots` before changing balance.
- Capture one manual human-controlled iPhone 17e matrix and one Dynamic Island-class layout run.
- Compare live terminal outcomes, active traffic, collision rectangles, near misses, and exit progress against GameSim before retuning.
