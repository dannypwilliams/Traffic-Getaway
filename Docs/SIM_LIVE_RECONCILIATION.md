# Sim/Live Reconciliation

## Status

Partial. Core stress gates are fixed, debug live gameplay telemetry works, and iPhone 17e autoplay matrices now exist. Live-hazard steering improved one run to 24.9s but still crashed 5/5 before the exit, so the remaining GameSim-vs-live gap is active traffic lifetime/collision timing rather than simple stale-wave steering.

## Known Modeling Gap

The iOS app still owns local presentation/gameplay definitions (`LevelData`, `LaneManager`, `TrafficPatternGenerator`, `TrafficSafetyAnalyzer`, collision and run systems) while `GameCore` owns pure simulation definitions. This duplication is the main drift risk.

## Current Comparison

| Metric | GameSim | iOS live | Difference | Cause | Resolution |
|---|---:|---:|---:|---|---|
| Exit activation time | 42s target from config | Not reached in 5/5 live-hazard autoplay runs | Live ends before exit | Active traffic/collision timing still crashes early | Inspect collision frames before tuning |
| First crash time | p50 36.8s | median 4.5s / avg 8.6s | Live autoplay much earlier | Live-hazard steering improved avg time but still 0/5 complete | Reconcile active traffic lifetime and collision timing |
| Traffic waves before failure | Stress: 0 impossible / 160,000 | avg 8.4 waves before crash | Live ends early | GameSim does not model active on-screen traffic lifetime directly | Add per-frame/collision comparison |
| Near misses | 35.3/run | 2.6/run | Live much lower | Short live runs plus different active-traffic timing | Do not tune rewards from this sample |
| Completion | 99.1% | 0/5 autoplay completed | Major mismatch | Live route decision/state is not equivalent to GameSim run model | Reconcile sim/live model |
| Collision box overlap | Unfair estimate 0.0% | Rects logged on every collision | Data available | App collision code separate | Review active traffic snapshots |
| Reachable path at failure | Stress clean | Safe slots plus active traffic logged | Pending review | Latest wave alone is insufficient; older traffic can still collide | Analyze active roster by timestamp |
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

Do not retune Sunset Merge from the autoplay matrix yet. The core simulator says the route policy can escape almost every run, while debug autoplay dies before the exit in live runs. Corrected telemetry shows applied movement is mostly aligned on actual moves, and live-hazard steering helps but does not solve the mismatch. The next discrepancy is active traffic lifetime and collision timing: GameSim treats waves as discrete safe-slot decisions, while live keeps spawned traffic on screen and colliding over time.

## Debug Rendering

The `OPEN PATHS` debug preference now draws lane centers, slot centers, safe-slot columns, active exit corridor, near-miss band, player hitbox, traffic hitboxes, active wave ID, and seed. This gives the live screenshot a direct visual counterpart to the JSONL fields.

## Next Instrumentation

- Add collision-frame analysis that reports the colliding vehicle, active traffic roster, player slot, safe slots, and last movement decision for each terminal live run.
- Decide whether GameSim should model live traffic lifetime/collision timing more directly, or whether live safety selection needs a longer route horizon.
- Capture one manual human-controlled iPhone 17e matrix and one Dynamic Island-class layout run.
- Compare live terminal outcomes, active traffic, collision rectangles, near misses, and exit progress against GameSim before retuning.
