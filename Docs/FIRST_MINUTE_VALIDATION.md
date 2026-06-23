# First-Minute Validation

## Status

Partial.

## Validated This Pass

- iPhone 17e simulator, iOS 26.5, Debug build.
- Fresh install launch captured before and after launch-screen fix.
- White launch frame reproduced before fix.
- Dark/tutorial first frame captured after fix.
- Build, install, launch, and screenshot succeeded.
- Skip path succeeded from onboarding into a live chase.
- Debug live telemetry produced one first-minute terminal sample: traffic crash at 22.946s.
- Debug open-path overlay was enabled, visually verified, captured, then disabled again in the simulator.
- Debug direct-start/autoplay capture produced a five-run iPhone 17e live matrix for `la_01` + `starter_compact`.
- New-schema collision telemetry includes active traffic snapshots.
- Debug autoplay decision telemetry produced a five-run iPhone 17e matrix. Corrected instrumentation shows only 2 applied-slot mismatches across 18 move decisions, with the remaining sim/live gap concentrated in target-policy and no-reachable-state differences.
- Live-hazard debug autoplay produced another five-run iPhone 17e matrix. Average terminal time improved to 8.6s, including one 24.9s run, but 5/5 runs still ended in traffic collisions before the exit.
- Collision-analysis debug autoplay produced a five-run iPhone 17e matrix. Collision analysis was present in 5/5 terminal crashes, and every sampled crash followed a move decision, pointing to lane-change transition timing/path occupancy as the next sim/live mismatch.
- Lane-change parity debug autoplay produced a five-run iPhone 17e matrix. It recorded 163 lane-change probes across 26 transitions; 3/5 last pre-crash probes were already intersecting traffic, narrowing the next fix to transition clearance plus target-slot danger horizon.
- Transition-clearance debug autoplay produced a five-run iPhone 17e matrix. Completion improved to 1/5, average terminal time improved to 26.7s, and average near misses reached 6.4, but 4/5 runs still ended in traffic collisions.
- Tightened transition-clearance debug autoplay produced a five-run iPhone 17e matrix. Completion improved to 5/5, average terminal time reached 42.8s, lane-change intersection probes dropped to 0, and all terminal reasons were `escaped`.

## Evidence

- Before: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/01-launch.png`
- After: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/02-launch-after-fix.png`
- Telemetry screenshot: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/04-live-telemetry-run.png`
- Debug overlay screenshot: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/05-debug-diagnostics-overlay.png`
- Live telemetry: `PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry/2026-06-22_18-49-43-la_01-starter_compact-17033032432948192956.jsonl`
- Autoplay matrix summary: `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/summary.md`
- Autoplay matrix telemetry: `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry/`
- Autoplay decision matrix summary: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/summary.md`
- Autoplay decision matrix telemetry: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/telemetry/`
- Live-hazard autoplay matrix summary: `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/summary.md`
- Live-hazard autoplay matrix telemetry: `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/telemetry/`
- Collision-analysis autoplay matrix summary: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/summary.md`
- Collision-analysis autoplay matrix telemetry: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry/`
- Collision-analysis autoplay matrix notes: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/notes.md`
- Lane-change parity autoplay matrix summary: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/summary.md`
- Lane-change parity autoplay matrix telemetry: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry/`
- Lane-change parity autoplay matrix notes: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/notes.md`
- Transition-clearance autoplay matrix summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/summary.md`
- Transition-clearance autoplay matrix telemetry: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry/`
- Transition-clearance autoplay matrix notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/notes.md`
- Tightened transition-clearance autoplay matrix summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/summary.md`
- Tightened transition-clearance autoplay matrix telemetry: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/telemetry/`
- Tightened transition-clearance autoplay matrix notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/notes.md`
- Logs:
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`

## Not Yet Validated

- 20 clean-install tutorial completions.
- Compact, Dynamic Island, and large-height simulator matrix.
- Slow taps, rapid taps, repeated right movement, extra movement after target.
- Crash, capture, missed-exit, retry, return to menu.
- First escape to Starter Bike unlock to `USE BIKE` to 405 Afterburn.
- Human-controlled live matrix; debug autoplay is useful for repeatability but is not a proxy for player input yet.

## Current First-Minute Fixes

- Revive tutorial page removed.
- Runtime revive offer disabled by default.
- Results cash-double reward disabled by default.
- Main-menu cash accessibility label/value now mirrors final visible cash/best-score string.
- Launch white frame fixed in simulator capture.
- Live first-minute JSONL telemetry added and smoke-tested.
- Debug collision/traffic-plan visualization added and screenshot-verified.
- Debug direct-start/autoplay telemetry capture added and verified.
- Debug autoplay movement-decision telemetry added and summarized.
- Debug autoplay now switches to live on-screen hazard safety when immediate traffic is near, with the source recorded in telemetry.
- Collision-frame telemetry now records the colliding vehicle, active traffic roster, player slot/lane, live safe and unsafe slots, overlap geometry, and last movement decision.
- Lane-change parity telemetry now records logical slot, target slot, sprite nearest slot, sprite x-position, path danger, active traffic intersection, and completion state while the lane-change animation is active.
- Debug autoplay now rejects predicted unsafe transition paths before moving, using a lane-change-duration horizon and small vertical padding on predicted traffic hitboxes.
