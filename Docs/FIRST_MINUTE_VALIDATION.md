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
