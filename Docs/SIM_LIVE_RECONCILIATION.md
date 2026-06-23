# Sim/Live Reconciliation

## Status

Partial. Core stress gates are fixed, debug live gameplay telemetry works, and an iPhone 17e autoplay matrix now exists. The matrix exposes a large GameSim-vs-live-control discrepancy that must be explained before tuning.

## Known Modeling Gap

The iOS app still owns local presentation/gameplay definitions (`LevelData`, `LaneManager`, `TrafficPatternGenerator`, `TrafficSafetyAnalyzer`, collision and run systems) while `GameCore` owns pure simulation definitions. This duplication is the main drift risk.

## Current Comparison

| Metric | GameSim | iOS live | Difference | Cause | Resolution |
|---|---:|---:|---:|---|---|
| Exit activation time | 42s target from config | Not reached in 5/5 autoplay runs | Live ends before exit | Autoplay/live control policy crashes early | Compare input policy, not traffic balance yet |
| First crash time | p50 36.8s | median 4.4s / avg 6.4s | Live autoplay much earlier | App debug autoplay does not match GameSim route policy | Add route-decision telemetry or align policies |
| Traffic waves before failure | Stress: 0 impossible / 160,000 | avg 6.2 waves before crash | Live ends early | Autoplay collides in active traffic before exit | Inspect active traffic at collision |
| Near misses | 35.3/run | 2.2/run | Live much lower | Short live runs plus different movement policy | Do not tune rewards from this sample |
| Completion | 99.1% | 0/5 autoplay completed | Major mismatch | Live autoplay policy is not equivalent to GameSim policy | Reconcile player-control model |
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

## Summarizer

Run:

```bash
python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry
```

Current result:

- Runs: 1.
- Completed: 0/1.
- Avg terminal time: 22.9s.
- Avg near misses: 4.0.
- Avg cash: 44.
- Terminal reasons: `traffic` 1.
- Collision rectangles: present.
- Active traffic column is present for new-schema telemetry.

## Current Read

Do not retune Sunset Merge from the autoplay matrix yet. The core simulator says the route policy can escape almost every run, while debug autoplay dies before the exit in 5/5 live runs. The next discrepancy to isolate is the app-side movement/autoplay policy versus the GameSim route-selection policy, using active traffic snapshots and lane-change decisions.

## Debug Rendering

The `OPEN PATHS` debug preference now draws lane centers, slot centers, safe-slot columns, active exit corridor, near-miss band, player hitbox, traffic hitboxes, active wave ID, and seed. This gives the live screenshot a direct visual counterpart to the JSONL fields.

## Next Instrumentation

- Add lane-change decision telemetry for debug autoplay and compare it against GameSim's chosen safe slot per wave.
- Capture one manual human-controlled iPhone 17e matrix and one Dynamic Island-class layout run.
- Compare live terminal outcomes, active traffic, collision rectangles, near misses, and exit progress against GameSim before retuning.
