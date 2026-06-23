# Sim/Live Reconciliation

## Status

Partial. Core stress gates are fixed, debug live gameplay telemetry works, and iPhone 17e plus iPhone 17 Pro autoplay matrices now exist. Tightened transition-clearance debug autoplay completed 5/5 iPhone 17e runs, and a strict emergency-transition fallback moved iPhone 17 Pro debug autoplay from 3/5 to 4/5 completion while keeping sampled lane-change intersection probes at 0. GameSim now has an opt-in active-traffic lifetime diagnostic with risk-aware emergency movement, but it is intentionally not the default balance model yet because it remains much more punitive than the tightened live autoplay matrices.

## Known Modeling Gap

The iOS app still owns local presentation/gameplay definitions (`LevelData`, `LaneManager`, `TrafficPatternGenerator`, `TrafficSafetyAnalyzer`, collision and run systems) while `GameCore` owns pure simulation definitions. This duplication is the main drift risk.

## Current Comparison

| Metric | GameSim | iOS live | Difference | Cause | Resolution |
|---|---:|---:|---:|---|---|
| Exit activation time | 42s target from config | Reached in 5/5 tightened transition-clearance autoplay runs | Aligned in debug autoplay | Longer transition horizon plus padded predicted traffic checks | Validate with human input |
| First crash time | p50 36.8s default / p50 8.8s active-lifetime diagnostic | no crashes in tightened 5-run autoplay matrix | Default sim omits active lifetime; diagnostic still overcorrects | Active lifetime, collision timing, and steering cadence need more calibration | Calibrate before tuning |
| Traffic waves before terminal event | Stress: 0 impossible / 160,000 | avg 36.2 waves before escape | Much closer to sim | Live still tracks active on-screen traffic directly | Compare manual matrix before tuning |
| Near misses | 35.3/run | 14.0/run | Live remains below sim but above target band | Longer runs plus safer transition filtering | Do not tune rewards from autoplay alone |
| Completion | 99.1% default / 0.3% active-lifetime diagnostic | 5/5 iPhone 17e autoplay, 4/5 iPhone 17 Pro autoplay after emergency fallback | Sim bounds still bracket live instead of matching it | Diagnostic mode is too punitive; autoplay is not human input; device shape still affects outcomes | Capture manual matrix |
| Collision box overlap | Unfair estimate 0.0% | Rects logged on every collision | Data available | App collision code separate | Review active traffic snapshots |
| Reachable path at failure | Stress clean | Safe slots, active traffic, colliding vehicle, overlap, last decision, and lane-change probes logged | Lane-change samples available | Latest safe slot can be logically safe while the animated car is still exposed on the lane-change path | Keep tightened live guard; evaluate GameSim parity |
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

### Tightened Transition-Clearance Autoplay Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/notes.md`
- Runs: 5.
- Completed: 5/5.
- Avg terminal time: 42.8s.
- Median terminal time: 42.7s.
- Avg traffic waves: 36.2.
- Avg near misses: 14.0.
- Terminal reasons: `escaped` 5.
- Lane-change probes: 1079.
- Lane-change transitions: 183.
- Lane-change intersection probes: 0.
- Lane-change unsafe-path probes: 2.
- `no_transition_safe_slots` decisions: 18.
- Interpretation: extending transition prediction to the lane-change duration and padding predicted traffic vertically eliminated sampled live autoplay collisions. This validates the live safety direction, but not final balance: debug autoplay completed every run and near misses are still above the first-minute target band.

### GameSim Active-Traffic Lifetime Diagnostic

- Command: `swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --active-traffic-lifetime`
- Runs: 10,000.
- Before this calibration: 0.0% completed, 7.3s average survival, 6.5s median survival, 2.1 near misses/run, 58 cash/run, 33.3% unfair collision estimate.
- After this calibration: 0.3% completed, 10.7s average survival, 8.8s median survival, first crash p10/p50/p90 4.8s / 8.8s / 19.8s, exit appeared/reached/completed 0.4% / 0.4% / 0.3%, 2.8 near misses/run, 75 cash/run, 59.4% unfair collision estimate, top failure `traffic_collision:4032`.
- Calibration change: `TrafficSafetyAnalyzer.transitionRiskScore` now provides a deterministic lower-risk emergency comparison, and the active diagnostic uses live-like transition timing for the starter car and motorcycle. Default GameSim output did not change.
- Interpretation: the opt-in diagnostic now moves in the same direction as the tightened live safety work, but the geometry/timing calibration is still not credible enough for balance. It still overcorrects relative to the tightened live autoplay matrix, which escaped 5/5 iPhone 17e runs.

### Passive Manual iPhone 17e Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/summary.md`
- Simulator: iPhone 17e, iOS 26.5.
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 21.6s.
- Median terminal time: 21.5s.
- Terminal reasons: `traffic` 5.
- Autoplay decisions: 0.
- Collision analyses: 5/5.
- Baseline interpretation: passive no-input play ended in traffic crashes around 21-22s, which failed the police-capture target before the later passive-capture fix.

### Passive Manual iPhone 17 Pro Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/summary.md`
- Simulator: iPhone 17 Pro, iOS 26.5.
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 32.9s.
- Median terminal time: 23.7s.
- Terminal reasons: `traffic` 4, `roadblock` 1.
- Autoplay decisions: 0.
- Collision analyses: 5/5.
- Interpretation: Dynamic Island passive no-input runs are more variable, including one missed-exit-then-crash sample, but still fail as traffic/roadblock rather than capture pressure.

### Passive Police-Capture iPhone 17e Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/notes.md`
- Simulator: iPhone 17e, iOS 26.5.
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 9.0s.
- Median terminal time: 9.0s.
- Terminal reasons: `police_caught` 5.
- Autoplay decisions: 0.
- Collision analyses: 0/5, expected for police capture terminals.
- Interpretation: passive no-input play now reads as police capture pressure before traffic or roadblocks become terminal.

### Passive Police-Capture iPhone 17 Pro Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/notes.md`
- Simulator: iPhone 17 Pro, iOS 26.5.
- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 9.0s.
- Median terminal time: 9.0s.
- Terminal reasons: `police_caught` 5.
- Autoplay decisions: 0.
- Collision analyses: 0/5, expected for police capture terminals.
- Interpretation: Dynamic Island passive no-input play now matches the police-capture target.

### Dynamic Island Transition-Clearance Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/notes.md`
- Simulator: iPhone 17 Pro, iOS 26.5.
- Runs: 5.
- Completed: 3/5.
- Avg terminal time: 38.9s.
- Median terminal time: 42.3s.
- Avg first crash: 32.3s.
- Avg traffic waves: 33.6.
- Avg near misses: 16.6.
- Terminal reasons: `escaped` 3, `traffic` 2.
- Lane-change probes: 1039.
- Lane-change transitions: 198.
- Lane-change intersection probes: 0.
- Lane-change unsafe-path probes: 1.
- `no_transition_safe_slots` decisions: 23.
- Interpretation: Dynamic Island-class telemetry preserves the tightened transition-path fix, but it is not as clean as the iPhone 17e matrix. The remaining two traffic crashes happen after the policy declines marginal transitions, which makes this useful evidence for active traffic lifetime and device-shape calibration before balance tuning.

### Dynamic Island Emergency-Transition Matrix

- Capture command: `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry --timeout 120`
- Summary: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/summary.md`
- Notes: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/notes.md`
- Simulator: iPhone 17 Pro, iOS 26.5.
- Runs: 5.
- Completed: 4/5.
- Avg terminal time: 38.4s.
- Median terminal time: 42.4s.
- Avg first crash: 21.5s.
- Avg traffic waves: 31.4.
- Avg near misses: 15.8.
- Terminal reasons: `escaped` 4, `traffic` 1.
- Lane-change probes: 1103.
- Lane-change transitions: 191.
- Lane-change intersection probes: 0.
- Lane-change unsafe-path probes: 0.
- `emergency_move` decisions: 1.
- `no_transition_safe_slots` decisions: 19.
- Interpretation: the strict emergency fallback reduced Dynamic Island traffic terminals without reopening the lane-change-intersection failure. The remaining crash still follows `no_transition_safe_slots`, so this is a diagnostic improvement, not a first-minute lock.

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

Do not retune Sunset Merge from the autoplay matrix yet. The default core simulator says the route policy can escape almost every run, tightened debug autoplay escapes 5/5 iPhone 17e runs and 4/5 iPhone 17 Pro runs after emergency transition handling, passive no-input now resolves as police capture on both sampled devices, and the opt-in active-traffic lifetime diagnostic still crashes almost every run before the exit even after improving average survival to 10.7s. That bracket is useful evidence, not a lock: the diagnostic direction is validated, but the active-lifetime geometry, steering cadence, collision timing, and device-shape sensitivity still need calibration against live/human runs.

## Debug Rendering

The `OPEN PATHS` debug preference now draws lane centers, slot centers, safe-slot columns, active exit corridor, near-miss band, player hitbox, traffic hitboxes, active wave ID, and seed. This gives the live screenshot a direct visual counterpart to the JSONL fields.

## Next Instrumentation

- Capture one human-controlled iPhone 17e matrix with the tightened transition-clearance build.
- Capture human-controlled iPhone 17e and Dynamic Island-class runs with the same live-safety behavior.
- Use `scripts/capture_live_telemetry.py --manual` to direct-start the level without debug autoplay and wait for `run_ended` telemetry.
- Passive no-input manual matrices are captured and now pass as police-capture outcomes; next manual evidence should include active human steering styles.
- Calibrate `GameSim --active-traffic-lifetime` against tightened live telemetry before using it for balance.
- Compare live terminal outcomes, active traffic, collision rectangles, near misses, and exit progress against GameSim before retuning.
