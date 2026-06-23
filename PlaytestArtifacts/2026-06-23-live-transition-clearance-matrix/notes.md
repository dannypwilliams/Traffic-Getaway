# Live Transition-Clearance Matrix Notes

## Purpose

Measure whether debug autoplay improves when it rejects moves whose current-to-target path is predicted to collide during the lane-change duration or short post-move horizon.

## Capture

Command:

```bash
python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry --timeout 120
```

Simulator: iPhone 17e, iOS 26.5.

## Summary

- Runs: 5.
- Completed: 1/5.
- Avg terminal time: 26.7s.
- Median terminal time: 30.0s.
- Avg traffic waves before terminal event: 23.4.
- Avg near misses/cash: 6.4 / 58.
- Autoplay decisions: 851.
- Autoplay move decisions: 121.
- `no_transition_safe_slots`: 6.
- Lane-change probes: 742.
- Lane-change transitions: 121.
- Lane-change intersection probes: 2.
- Lane-change unsafe-path probes: 1.
- Last pre-crash probe intersected traffic: 2/5.
- Terminal reasons: escaped 1, traffic 4.

## Comparison

Compared with `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/`:

- Completion improved from 0/5 to 1/5.
- Avg terminal time improved from 7.9s to 26.7s.
- Median terminal time improved from 6.6s to 30.0s.
- Avg traffic waves improved from 7.6 to 23.4.
- Lane-change intersection probes dropped from 3 to 2 despite many more transitions.
- Last pre-crash probe intersections dropped from 3/5 to 2/5.

## Read

Transition clearance is a real improvement and should stay in the debug autoplay diagnostic path. It is not sufficient yet: two crashes still intersect during the final transition, and two remaining crashes appear just after a move begins or before the current probe catches the overlap.

Next, tighten the transition model before retuning balance:

- Increase the post-move target danger horizon.
- Add a small vertical safety padding to predicted traffic hitboxes.
- Record transition-rejection counts by reason if the next comparison is ambiguous.
