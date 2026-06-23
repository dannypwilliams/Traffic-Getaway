# Production Roadmap

## Current Verified State

- HEAD at session start: `a5af66b Testrun` on `main`, ahead of `origin/main` by 1.
- Toolchain available: Git, Swift 6.3.2, Xcode 26.5, iOS 26.5 simulators, Python 3.9.6.
- Missing tool: PowerShell on Mac.
- Missing docs at session start: all expected `Docs/*.md` files.
- Core determinism and traffic stress are now green.
- First-minute fake revive/reward affordances are hidden by default.
- Launch no longer reproduces the captured white first frame on iPhone 17e simulator.
- Final tutorial exit-ramp signage and completion flow were repaired in code; full clean-install tutorial matrix remains open.
- Dynamic Island-class iPhone 17 Pro debug-autoplay telemetry now exists for the tightened transition-clearance build: 4/5 completed after emergency fallback, median terminal time 42.4s, 0 lane-change intersection probes.
- `GameSim --active-traffic-lifetime` is partially calibrated against live transition evidence: average survival improved from 7.3s to 10.7s and exit appearance from 0.0% to 0.4%, but it remains too punitive for balance tuning.
- Manual direct-start telemetry tooling now exists. Passive no-input matrices are captured on iPhone 17e and iPhone 17 Pro, and both remain red because passive play ends in traffic/roadblock crashes rather than capture pressure.

## Issue Matrix

| Concern | Status | Evidence |
|---|---|---|
| Final onboarding exit page stuck on READ | Partially fixed | Exit-ramp signage now appears on the five-step tutorial, and the final step uses explicit lane/visual completion plus auto-advance after the read gate; not matrix-validated. |
| Free revive loading then crash results | Partially fixed | Revive UI now hidden by `AppConfig.rewardedRevivesEnabled = false`. |
| Live crashes around LA 738-740 | Unverified | Needs live first-minute telemetry/manual runs. |
| Live first minute harsher than GameSim | Partially reproduced | Default GameSim over-completes, iPhone 17e debug autoplay completes 5/5, iPhone 17 Pro debug autoplay completes 4/5 after emergency fallback, while opt-in active-traffic lifetime diagnostic still overcorrects to early traffic collisions after improving average survival to 10.7s. |
| Passive driver outcome | Reproduced | iPhone 17e passive no-input matrix ends 0/5 in traffic crashes around 21.6s average; iPhone 17 Pro passive matrix ends 0/5 with 4 traffic and 1 roadblock terminal around 32.9s average. |
| GameSim far from Level 1 targets | Reproduced | 99.1% completion, 35.3 near misses/run, 998 cash/run after fixes. |
| GameCore determinism failing | Fixed | `swift test` passes. |
| Impossible committed waves | Fixed for current stress gate | 0 / 160,000 waves after fixes. |
| Main menu stale cash accessibility | Partially fixed | Cash label/value now use final visible string; needs accessibility snapshot validation. |
| Tutorial page 3 cramped | Unverified | No compact manual matrix completed. |
| White first frame | Fixed in simulator capture | Before/after screenshots saved. |
| Results state clarity | Partially fixed already | Code distinguishes escaped/crashed/captured/missed exit; no full manual matrix this pass. |
| Procedural placeholder art | Reproduced from code audit | No art pass done. |
| App duplicates GameCore rules | Reproduced | App target has local `LevelData`, `LaneManager`, traffic/safety copies. |

## Milestone Order

1. Continue active-traffic lifetime calibration and capture the first-minute manual matrix.
2. Retune Sunset Merge against verified sim/live metrics.
3. Incrementally adopt `GameCore` models in the app with parity tests.
4. Lock tutorial/results/progression first-session flow.
5. Build art/UI cohesion only after first-minute reliability and balance are green.
6. Add Infinite Chase, records, replay proof, and release checklist depth.

## Scope Cuts

- Cut route count before cutting determinism, traffic fairness, first-minute clarity, or save integrity.
- Keep rewarded ads/revives/cash doubles hidden until real reward integration exists.
- Keep content/art expansion behind Level 1 balance and sim/live reconciliation.
