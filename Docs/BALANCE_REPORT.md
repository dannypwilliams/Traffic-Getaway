# Balance Report

## Target

Level 1 target from the production prompt:

- Exit target around 42s.
- Average first crash at least 30s.
- Completion around 40-60% for Starter Compact once sim/live agree.
- Unfair collisions under 5%.
- Average near misses around 3-8.
- Heavy traffic should not dominate the first 25s.

## Measured Baseline

Command:

```bash
cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345
```

Before core fixes:

- Avg survival: 43.3s.
- Median survival: 43.8s.
- First crash p10/p50/p90: 11.8s / 35.8s / 42.2s.
- Exit appeared/reached/completed: 99.0% / 98.7% / 98.7%.
- Near misses: 32.1/run.
- Avg max combo: 28.0.
- Avg cash/XP: 909 / 359.
- Unfair collision estimate: 0.0%.

After core fixes:

- Avg survival: 43.4s.
- Median survival: 43.8s.
- First crash p10/p50/p90: 10.8s / 36.8s / 43.0s.
- Exit appeared/reached/completed: 99.3% / 99.1% / 99.1%.
- Near misses: 35.3/run.
- Avg max combo: 34.3.
- Avg cash/XP: 998 / 391.
- Unfair collision estimate: 0.0%.

Live debug-autoplay matrix after telemetry improvements:

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 6.4s.
- Median terminal time: 4.4s.
- Avg traffic waves before terminal event: 6.2.
- Avg near misses/cash: 2.2 / 16.
- Terminal reasons: traffic collision in all 5.
- Collision rectangles and active traffic snapshots were present in all 5 collision samples.

Live debug-autoplay decision matrix:

- Runs: 6.
- Completed: 0/6.
- Avg terminal time: 6.5s.
- Median terminal time: 6.5s.
- Avg traffic waves before terminal event: 6.8.
- Avg near misses/cash: 2.2 / 11.
- Autoplay decisions: 246.
- Autoplay move decisions: 36.
- Autoplay target mismatches: 4.
- Autoplay applied-slot mismatches: 35.
- Terminal reasons: traffic collision in all 6.
- Summary: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/summary.md`.

## Interpretation

The sim is now deterministic and traffic-stress clean, but Level 1 is still far outside the intended balance range. The live debug-autoplay matrix is also far outside the sim outcome, and the decision matrix points to movement application rather than target selection: live autoplay chooses nearly the same route target as GameSim, then usually lands on an intermediate slot. Do not tune rewards or density until that control-model mismatch is fixed or intentionally modeled.

## Next

Align debug autoplay movement with GameSim or update GameSim to model the app's multi-step slot movement, rerun the decision matrix, capture manual human runs, then tune rewards, near-miss rates, and completion after the models are reconciled.
