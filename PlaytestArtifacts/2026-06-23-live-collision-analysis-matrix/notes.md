# Live Collision Analysis Matrix Notes

## Purpose

Validate crash-frame telemetry for the remaining GameSim/live mismatch after live-hazard debug autoplay still crashed before the exit.

## Capture

Command:

```bash
python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry --timeout 120
```

Simulator: iPhone 17e, iOS 26.5.

## Summary

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 5.2s.
- Median terminal time: 4.7s.
- Avg traffic waves before collision: 5.4.
- Avg near misses/cash: 1.0 / 7.
- Autoplay decisions: 171.
- Autoplay move decisions: 22.
- Collision analyses: 5/5.
- Avg collision overlap area: 94.2.
- Avg active traffic at collision: 10.6.
- Collision last-decision sources: `debug_autoplay_latest_wave` 1, `debug_autoplay_live_hazards` 4.
- Collision last-decision statuses: `move` 5.

## Read

Every sampled collision happened after a move decision. Several crash frames show the logical `playerSlot` had already advanced to the target while the player sprite was still physically overlapping the departure lane or lane-change path. This points the next reconciliation step at lane-change transition timing: GameSim currently treats route selection as a discrete safe-slot decision, while the iOS collision model checks the animated sprite over time.

Do not retune Sunset Merge from this evidence yet. First decide whether GameSim must model lane-change duration/path occupancy, or whether live route safety/autoplay must require a clear transition path and longer lead time before moving.
