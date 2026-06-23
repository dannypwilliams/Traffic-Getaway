# Live Autoplay Decision Matrix Notes

Date: 2026-06-22 local session.

Simulator: iPhone 17e, iOS 26.5.

Build: Debug simulator build from `Tools/mac/verify_on_mac.sh`.

## Purpose

Compare app-side debug autoplay movement decisions against a GameSim-style safe-slot target policy before tuning `la_01`.

## Summary

- Runs: 6.
- Completed: 0/6.
- Terminal reason: traffic collision in all 6 runs.
- Avg terminal time: 6.5s.
- Median terminal time: 6.5s.
- Avg traffic waves: 6.8.
- Avg near misses: 2.2.
- Autoplay decisions: 246.
- Autoplay move decisions: 36.
- Autoplay target mismatches: 4.
- Autoplay applied-slot mismatches: 35.

## Read

The app-side debug autoplay usually chooses the same route target as the GameSim-style policy. The large mismatch is between the intended target slot and the applied live slot after SpriteKit movement. In most move decisions, the app lands on an intermediate slot while GameSim treats the route target as reached.

Do not retune traffic density or rewards from this matrix. First align the movement policy or make GameSim model the same multi-step movement.
