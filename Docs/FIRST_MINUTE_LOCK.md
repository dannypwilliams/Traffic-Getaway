# First-Minute Lock

## Status

Not locked.

The first minute has stronger evidence than the original baseline: launch presentation is fixed in simulator capture, fake reward actions are hidden, debug live telemetry exists, tightened debug autoplay can escape Sunset Merge 5/5 times on iPhone 17e, Dynamic Island-class debug autoplay improved to 4/5 with a strict emergency-transition fallback, and the active-traffic GameSim diagnostic has begun moving toward live behavior. It is still not locked because the human-controlled matrix, full tutorial matrix, result-outcome matrix, Starter Bike payoff flow, and GameSim/live model ownership are incomplete.

## Locked So Far

- Launch no longer shows the captured white first frame on the latest iPhone 17e evidence.
- Rewarded revive and cash-double actions are hidden by default.
- `GameCore` determinism and traffic reachability tests pass.
- Debug live-run telemetry records traffic waves, decisions, collisions, active traffic, and terminal outcomes.
- Tightened debug autoplay guards animated lane-change exposure with transition horizon and predicted traffic padding.
- iPhone 17 Pro debug autoplay preserved 0 lane-change intersection probes across 191 transitions after the emergency fallback, and completed 4/5 sampled runs.
- `GameSim --active-traffic-lifetime` now uses a deterministic transition-risk score and emergency move fallback, improving average diagnostic survival from 7.3s to 10.7s without changing default balance output.

## Not Locked

- Tutorial completion without `SKIP` has not been matrix-validated.
- Human-controlled Sunset Merge runs have not been captured after tightened transition clearance.
- Dynamic Island-class coverage is still debug-autoplay only, and it exposed 1/5 traffic-collision terminal after `no_transition_safe_slots` decisions.
- Crash, capture, missed-exit, retry, and return-to-menu outcomes have not been fully matrix-validated.
- First escape to Starter Bike unlock to `USE BIKE` to 405 Afterburn has not been validated.
- Default GameSim still reports Level 1 as too easy, while the opt-in active-traffic lifetime diagnostic remains too punitive despite the first calibration pass.
- Placeholder art and release-device layout/performance checks remain outside the first-minute lock.

## Current Gate

Capture human-controlled iPhone 17e and Dynamic Island-class first-minute runs with the tightened transition-clearance build. Use those results and the Dynamic Island debug-autoplay collisions to calibrate the active-traffic lifetime diagnostic before tuning Sunset Merge rewards, near misses, density, or completion rate.
