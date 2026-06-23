# GameSim Active-Lifetime Calibration Notes

## Scope

This pass calibrated the opt-in `GameSim --active-traffic-lifetime` diagnostic only. It did not change default balance simulation output and did not tune player-facing density, rewards, exits, or traffic pacing.

## Change

- Added deterministic transition-risk scoring in `GameCore`.
- Added a strict emergency movement comparison to the active-lifetime diagnostic when staying in the current slot is predicted riskier than moving.
- Adjusted diagnostic transition timing toward the live debug-autoplay lane-change window.

## Evidence

- `cd GameCore && swift test`: 22 tests, 0 failures.
- Default `GameSim`: 99.1% completion, 35.3 near misses/run, 998 cash/run, unchanged from the prior reported baseline.
- Active-lifetime `GameSim` before this pass: 0.0% completion, 7.3s average survival, 6.5s median survival.
- Active-lifetime `GameSim` after this pass: 0.3% completion, 10.7s average survival, 8.8s median survival, first crash p10/p50/p90 4.8s / 8.8s / 19.8s.
- Traffic stress: 160,000 waves, 0 impossible committed waves, 0 exit reachability failures.

## Read

The diagnostic moved in the right direction but remains too punitive versus the tightened live debug-autoplay matrix. Treat it as a better red diagnostic, not as a balance source.
