# Live Lane-Change Parity Matrix Notes

## Purpose

Validate whether early live crashes happen while the player sprite is physically moving between logical slots, after the preceding collision-frame analysis showed terminal crashes clustered around move decisions.

## Capture

Command:

```bash
python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry --timeout 120
```

Simulator: iPhone 17e, iOS 26.5.

## Summary

- Runs: 5.
- Completed: 0/5.
- Avg terminal time: 7.9s.
- Median terminal time: 6.6s.
- Avg traffic waves before collision: 7.6.
- Avg near misses/cash: 1.8 / 13.
- Autoplay decisions: 264.
- Autoplay move decisions: 26.
- Lane-change probes: 163.
- Lane-change transitions: 26.
- Lane-change intersection probes: 3.
- Lane-change unsafe-path probes: 1.
- Last pre-crash probe intersected traffic: 3/5.
- Terminal reasons: traffic collision in all 5.

## Read

The mismatch is now more specific than "live traffic is harsher." Three sampled crashes were already intersecting traffic during the last lane-change probe before collision. One fast-swipe move settled into a latest-wave target that later collided, and one crash occurred after the move was complete while autoplay was already at target.

The next gameplay fix should be transition-aware, not a broad density/reward retune:

- Treat a move as safe only if the path between current slot and target slot is clear for the lane-change duration.
- Apply this to debug autoplay first, then decide whether the same rule belongs in the live safety adapter and GameSim model.
- Keep target-slot danger on a short horizon after the move, because a safe endpoint at decision time can become unsafe before the animation finishes.
