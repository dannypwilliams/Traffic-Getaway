# Sim/Live Reconciliation

## Status

Partial. Core stress gates are fixed and debug live gameplay telemetry now works, but only one live iPhone 17e crash sample has been captured so far.

## Known Modeling Gap

The iOS app still owns local presentation/gameplay definitions (`LevelData`, `LaneManager`, `TrafficPatternGenerator`, `TrafficSafetyAnalyzer`, collision and run systems) while `GameCore` owns pure simulation definitions. This duplication is the main drift risk.

## Current Comparison

| Metric | GameSim | iOS live | Difference | Cause | Resolution |
|---|---:|---:|---:|---|---|
| Exit activation time | 42s target from config | Not reached in one sample | Unknown | Live sample crashed at 22.946s | Capture more runs |
| First crash time | p50 36.8s | 22.946s in one sample | Live sample earlier | One sample is not enough | Capture 5-20 runs |
| Traffic waves before failure | Stress: 0 impossible / 160,000 | 21 waves before crash | Unknown | Live telemetry now available | Compare wave mix |
| Near misses | 35.3/run | 4 in one sample | Live sample lower | Manual play/input differs from sim policy | Capture repeated runs |
| Completion | 99.1% | 0/1 sample completed | Unknown | One sample only | Build live outcome set |
| Collision box overlap | Unfair estimate 0.0% | Rects logged on collision | Pending review | App collision code separate | Add parser/report |
| Reachable path at failure | Stress clean | Safe slots logged per wave | Pending review | App safety analyzer now parity-patched | Add parser/report |
| Police pressure at failure | Highest wanted 3 | Wanted 3 at run end | Aligned in sample | App pursuit may still differ | Track across runs |

## Live Evidence

- Telemetry file: `PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry/2026-06-22_18-49-43-la_01-starter_compact-17033032432948192956.jsonl`
- Screenshot: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/04-live-telemetry-run.png`
- Debug overlay screenshot: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/05-debug-diagnostics-overlay.png`
- Simulator log: `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`
- Events: 24 total; `run_started` 1, `traffic_wave` 21, `collision` 1, `run_ended` 1.
- Pattern mix: `staggeredCars` 8, `denseClusters` 6, `sparseLanes` 6, `recoveryWave` 1.
- Terminal outcome: traffic collision at 22.946s.

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

## Debug Rendering

The `OPEN PATHS` debug preference now draws lane centers, slot centers, safe-slot columns, active exit corridor, near-miss band, player hitbox, traffic hitboxes, active wave ID, and seed. This gives the live screenshot a direct visual counterpart to the JSONL fields.

## Next Instrumentation

- Capture at least 5 iPhone 17e live runs and one compact/Dynamic Island-class layout run.
- Compare live terminal outcomes, wave mix, collision rectangles, near misses, and exit progress against GameSim before retuning.
