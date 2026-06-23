# Live Autoplay Decision Matrix Notes

Date: 2026-06-22 local session.

Simulator: iPhone 17e, iOS 26.5.

Build: Debug simulator build from `Tools/mac/verify_on_mac.sh`.

## Purpose

Compare app-side debug autoplay decisions against a GameSim-style safe-slot target policy before tuning `la_01`.

## Summary

- Runs: 5.
- Completed: 0/5.
- Terminal reason: traffic collision in all 5 runs.
- Avg terminal time: 6.3s.
- Median terminal time: 5.2s.
- Avg traffic waves: 6.2.
- Avg near misses: 0.6.
- Autoplay decisions: 207.
- Autoplay move decisions: 18.
- Autoplay target mismatches: 36.
- Autoplay move-target mismatches: 2.
- Autoplay applied-slot mismatches: 2.

## Read

Corrected applied-slot telemetry shows live debug autoplay usually lands on the same slot it intends to reach during actual moves. The remaining sim/live gap is mostly decision policy and state modeling: live autoplay sometimes stays put when the GameSim-style policy would move, and many early live frames have no reachable safe slot while GameSim's aggregate run model still survives almost every run.

Do not retune traffic density or rewards from this matrix. First reconcile live decision timing, reachable-safe-slot state, and collision/traffic modeling against GameSim.
