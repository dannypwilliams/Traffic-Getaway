# First-Minute Lock

## Status

Not locked.

The first minute has stronger evidence than the original baseline: launch presentation is fixed in simulator capture, fake reward actions are hidden, debug live telemetry exists, tightened debug autoplay can escape Sunset Merge 5/5 times on iPhone 17e, Dynamic Island-class debug autoplay improved to 4/5 with a strict emergency-transition fallback, passive no-input play now resolves as police capture on both sampled devices, the Starter Bike result-screen payoff is screenshot-verified, `USE BIKE` tap-through into 405 Afterburn is smoke-validated, and the active-traffic GameSim diagnostic has begun moving toward live behavior. Manual active capture now has a start-gated tool path, but the actual active-steering matrices are still incomplete. It is still not locked because the human-controlled matrix, full tutorial matrix, result-outcome matrix, full 405 Afterburn motorcycle validation, and GameSim/live model ownership are incomplete.

## Locked So Far

- Launch no longer shows the captured white first frame on the latest iPhone 17e evidence.
- Rewarded revive and cash-double actions are hidden by default.
- `GameCore` determinism and traffic reachability tests pass.
- Debug live-run telemetry records traffic waves, decisions, collisions, active traffic, and terminal outcomes.
- Tightened debug autoplay guards animated lane-change exposure with transition horizon and predicted traffic padding.
- iPhone 17 Pro debug autoplay preserved 0 lane-change intersection probes across 191 transitions after the emergency fallback, and completed 4/5 sampled runs.
- Passive no-input manual matrices now end as police capture pressure on iPhone 17e and iPhone 17 Pro, each with 5/5 `police_caught` terminals at 9.0s.
- First Sunset Merge escape payoff is visually verified through the result screen: `ESCAPED`, `Starter Bike unlocked: split lanes`, primary `USE BIKE`, selected `starter_bike`, completed `la_01`, and debug defaults cleared after capture.
- `USE BIKE` tap-through is smoke-validated: real button click launched `la_02` / 405 Afterburn with `starter_bike`, and active input recorded motorcycle movement into interstitial split slot `11`.
- `GameSim --active-traffic-lifetime` now uses a deterministic transition-risk score and emergency move fallback, improving average diagnostic survival from 7.3s to 10.7s without changing default balance output.
- Manual capture can now pause on the existing start screen with `--wait-for-start-tap`; smoke evidence recorded active input with autoplay disabled.

## Not Locked

- Tutorial completion without `SKIP` has not been matrix-validated.
- Human-controlled Sunset Merge runs have not been matrix-captured after tightened transition clearance.
- Active-steering manual Sunset Merge runs have not been matrix-captured after tightened transition clearance; the latest iPhone 17e attempt only produced 1/5 active-input runs before the start gate was added.
- Dynamic Island-class active steering coverage is still missing, and debug autoplay exposed 1/5 traffic-collision terminal after `no_transition_safe_slots` decisions.
- Crash, capture, missed-exit, retry, and return-to-menu outcomes have not been fully matrix-validated.
- 405 Afterburn has only a Starter Bike tap-through smoke validation; no full active-input completion or balance matrix exists yet.
- Default GameSim still reports Level 1 as too easy, while the opt-in active-traffic lifetime diagnostic remains too punitive despite the first calibration pass.
- Placeholder art and release-device layout/performance checks remain outside the first-minute lock.

## Current Gate

Capture start-gated active-steering iPhone 17e and Dynamic Island-class first-minute runs with the tightened transition-clearance and passive-capture build. Use those results and the Dynamic Island debug-autoplay collisions to calibrate the active-traffic lifetime diagnostic before tuning Sunset Merge rewards, near misses, density, or completion rate.
