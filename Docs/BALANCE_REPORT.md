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

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 6.3s.
- Median terminal time: 5.2s.
- Avg traffic waves before terminal event: 6.2.
- Avg near misses/cash: 0.6 / 8.
- Autoplay decisions: 207.
- Autoplay move decisions: 18.
- Autoplay target mismatches: 36.
- Autoplay move-target mismatches: 2.
- Autoplay applied-slot mismatches: 2.
- Terminal reasons: traffic collision in all 5.
- Summary: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/summary.md`.

Live-hazard debug-autoplay matrix:

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 8.6s.
- Median terminal time: 4.5s.
- Avg traffic waves before terminal event: 8.4.
- Avg near misses/cash: 2.6 / 19.
- Autoplay decisions: 269.
- Autoplay move decisions: 41.
- Autoplay decision sources: `debug_autoplay_live_hazards` 176, `debug_autoplay_latest_wave` 93.
- Autoplay decision statuses: `already_at_target` 205, `move` 41, `no_reachable_slots` 23.
- Terminal reasons: traffic collision in all 5.
- Summary: `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/summary.md`.

Live collision-analysis debug-autoplay matrix:

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 5.2s.
- Median terminal time: 4.7s.
- Avg traffic waves before terminal event: 5.4.
- Avg near misses/cash: 1.0 / 7.
- Collision analyses: 5/5.
- Avg collision overlap area: 94.2.
- Avg active traffic at collision: 10.6.
- Collision last-decision statuses: `move` 5.
- Summary: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/summary.md`.
- Notes: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/notes.md`.

Live lane-change parity debug-autoplay matrix:

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 7.9s.
- Median terminal time: 6.6s.
- Avg traffic waves before terminal event: 7.6.
- Avg near misses/cash: 1.8 / 13.
- Lane-change probes: 163.
- Lane-change transitions: 26.
- Lane-change intersection probes: 3.
- Lane-change unsafe-path probes: 1.
- Last pre-crash probe intersected traffic: 3/5.
- Summary: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/summary.md`.
- Notes: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/notes.md`.

Live transition-clearance debug-autoplay matrix:

- Runs: 5.
- Completed: 1/5.
- Avg terminal time: 26.7s.
- Median terminal time: 30.0s.
- Avg traffic waves before terminal event: 23.4.
- Avg near misses/cash: 6.4 / 58.
- `no_transition_safe_slots`: 6.
- Lane-change probes: 742.
- Lane-change transitions: 121.
- Lane-change intersection probes: 2.
- Last pre-crash probe intersected traffic: 2/5.
- Summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/summary.md`.
- Notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/notes.md`.

## Interpretation

The sim is now deterministic and traffic-stress clean, but Level 1 is still far outside the intended balance range. The live debug-autoplay matrix is also far outside the sim outcome, though transition clearance moved it substantially closer: one escape, 26.7s average terminal time, and near misses back inside the target range. Do not tune rewards or density yet; the live result is still only 20% completion and remains sensitive to transition-clearance and target-slot horizon details.

## Next

Tighten transition-clearance debug autoplay with a longer target-slot horizon and small vertical padding, rerun the transition-clearance matrix, capture manual human runs, then tune rewards, near-miss rates, and completion after the models are reconciled.
