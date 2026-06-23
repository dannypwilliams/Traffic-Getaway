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

Active-traffic lifetime diagnostic:

- Command: `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --active-traffic-lifetime`.
- Before this calibration: avg survival 7.3s, median survival 6.5s, exit appeared/reached/completed 0.0% / 0.0% / 0.0%, near misses 2.1/run, avg cash/XP 58 / 33.
- After this calibration: avg survival 10.7s, median survival 8.8s, first crash p10/p50/p90 4.8s / 8.8s / 19.8s, exit appeared/reached/completed 0.4% / 0.4% / 0.3%, near misses 2.8/run, avg max combo 2.1, avg cash/XP 75 / 40.
- Top failure after calibration: `traffic_collision:4032`.
- Unfair collision estimate after calibration: 59.4%.
- Read: this opt-in mode is a diagnostic bound, not a balance source. It now uses deterministic transition-risk scoring and a strict emergency movement comparison, improving average survival from 7.3s to 10.7s. It still overcorrects versus the tightened live autoplay matrix.

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

Live tightened transition-clearance debug-autoplay matrix:

- Runs: 5.
- Completed: 5/5.
- Avg terminal time: 42.8s.
- Median terminal time: 42.7s.
- Avg traffic waves before terminal event: 36.2.
- Avg near misses/cash: 14.0 / 115.
- `no_transition_safe_slots`: 18.
- Lane-change probes: 1079.
- Lane-change transitions: 183.
- Lane-change intersection probes: 0.
- Lane-change unsafe-path probes: 2.
- Terminal reasons: escaped in all 5.
- Summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/summary.md`.
- Notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/notes.md`.

Dynamic Island emergency-transition debug-autoplay matrix:

- Runs: 5.
- Completed: 4/5.
- Avg terminal time: 38.4s.
- Median terminal time: 42.4s.
- Avg traffic waves before terminal event: 31.4.
- Avg near misses/cash: 15.8 / 114.
- `emergency_move`: 1.
- `no_transition_safe_slots`: 19.
- Lane-change probes: 1103.
- Lane-change transitions: 191.
- Lane-change intersection probes: 0.
- Lane-change unsafe-path probes: 0.
- Terminal reasons: escaped 4, traffic 1.
- Summary: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/summary.md`.
- Notes: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/notes.md`.

## Interpretation

The sim is now deterministic and traffic-stress clean, but Level 1 is still far outside the intended balance range. Default GameSim over-completes at 99.1%, tightened iPhone 17e debug autoplay over-completes at 5/5 escapes, iPhone 17 Pro debug autoplay is now 4/5 after emergency transition handling, and the opt-in active-traffic lifetime diagnostic still overcorrects to 0.3% completion after its first calibration pass. Do not tune rewards or density from either simulation mode alone; first calibrate active traffic lifetime against human/live evidence.

## Next

Capture manual human runs with the tightened transition-clearance build, calibrate `GameSim --active-traffic-lifetime`, then tune rewards, near-miss rates, and completion after sim/live state agrees.
