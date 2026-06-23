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
- The final tutorial exit-ramp illustration now actually shows `EXIT RIGHT`, because the old page-index gate targeted a removed sixth page. The exit-ramp practice now uses an explicit lane/visual completion predicate, debug diagnostics, and a short auto-start delay once the read gate opens.
- Dynamic Island-class debug autoplay was captured on iPhone 17 Pro. It completed 3/5 runs, reached a 42.3s median terminal time, recorded 0 lane-change intersection probes across 198 transitions, and still produced 2 traffic-collision terminals after `no_transition_safe_slots` decisions.
- Dynamic Island-class debug autoplay was rerun after adding a strict emergency-transition fallback. It completed 4/5 runs, kept lane-change intersection probes at 0 across 191 transitions, recorded 1 `emergency_move`, and reduced terminal traffic collisions from 2 to 1.
- `GameSim --active-traffic-lifetime` was partially calibrated with deterministic transition-risk scoring and a strict emergency movement comparison. The diagnostic improved from 7.3s to 10.7s average survival, but remains too punitive for balance tuning.
- `scripts/capture_live_telemetry.py --manual` now supports direct-start manual telemetry capture without enabling debug autoplay.
- iPhone 17e passive manual matrix captured 5 no-input runs: 0/5 completed, traffic terminal in all 5, 21.6s average terminal time, 0 autoplay decisions, collision analysis in 5/5.
- iPhone 17 Pro passive manual matrix captured 5 no-input runs: 0/5 completed, 4 traffic terminals and 1 roadblock terminal, 32.9s average terminal time, 0 autoplay decisions, collision analysis in 5/5.
- Passive police-capture fix was captured on iPhone 17e: 5 no-input manual runs, 0/5 completed, `police_caught` terminal in all 5, 9.0s average terminal time, 0 autoplay decisions.
- Passive police-capture fix was captured on iPhone 17 Pro: 5 no-input manual runs, 0/5 completed, `police_caught` terminal in all 5, 9.0s average terminal time, 0 autoplay decisions.
- Debug first-escape payoff scenario captured on iPhone 17e. The screenshot shows `ESCAPED`, `Starter Bike unlocked: split lanes`, and primary `USE BIKE`; save-state verification showed `selectedCarID=starter_bike`, unlocked `[starter_compact, starter_bike]`, completed `[la_01]`, `totalRuns=1`, and debug defaults cleared.
- `USE BIKE` tap-through smoke-validated on iPhone 17e with the real ResultsScene button. Telemetry recorded `run_started.levelID=la_02`, `vehicleID=starter_bike`, `vehicleClass=motorcycle`, and active input produced a `lane_changed` event into interstitial split slot `11`.
- Attempted active-steering iPhone 17e manual matrix captured 5 runs with 0 autoplay decisions, but only 1/5 runs had active input. This is partial/failed matrix evidence, not a completed active-steering validation.
- Debug manual start-gate smoke passed on iPhone 17e: `--manual --wait-for-start-tap` paused on the existing `Tap to Start` screen, then recorded 1/1 active-input smoke run with 3 lane changes and 0 autoplay decisions.

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
- Dynamic Island transition-clearance summary: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/summary.md`
- Dynamic Island transition-clearance telemetry: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry/`
- Dynamic Island transition-clearance notes: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/notes.md`
- Dynamic Island emergency-transition summary: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/summary.md`
- Dynamic Island emergency-transition telemetry: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry/`
- Dynamic Island emergency-transition notes: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/notes.md`
- GameSim active-lifetime calibration notes: `PlaytestArtifacts/2026-06-23-gamesim-active-lifetime-calibration/notes.md`
- Passive iPhone 17e manual summary: `PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/summary.md`
- Passive iPhone 17e manual telemetry: `PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/telemetry/`
- Passive iPhone 17e manual notes: `PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/notes.md`
- Passive iPhone 17 Pro manual summary: `PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/summary.md`
- Passive iPhone 17 Pro manual telemetry: `PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/telemetry/`
- Passive iPhone 17 Pro manual notes: `PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/notes.md`
- Passive police-capture iPhone 17e summary: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/summary.md`
- Passive police-capture iPhone 17e telemetry: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/telemetry/`
- Passive police-capture iPhone 17e notes: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/notes.md`
- Passive police-capture iPhone 17 Pro summary: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/summary.md`
- Passive police-capture iPhone 17 Pro telemetry: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/telemetry/`
- Passive police-capture iPhone 17 Pro notes: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/notes.md`
- Starter Bike payoff screenshot: `PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike/starter-bike-use-bike-results.png`
- Starter Bike payoff metadata: `PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike/metadata.txt`
- Starter Bike payoff notes: `PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike/notes.md`
- `USE BIKE` tap-through screenshot: `PlaytestArtifacts/2026-06-23-use-bike-tap-through/405-afterburn-starter-bike-active-input.png`
- `USE BIKE` tap-through telemetry: `PlaytestArtifacts/2026-06-23-use-bike-tap-through/405-afterburn-starter-bike-telemetry.jsonl`
- `USE BIKE` tap-through metadata: `PlaytestArtifacts/2026-06-23-use-bike-tap-through/metadata.json`
- `USE BIKE` tap-through notes: `PlaytestArtifacts/2026-06-23-use-bike-tap-through/notes.md`
- Attempted active iPhone 17e manual summary: `PlaytestArtifacts/2026-06-23-manual-active-17e-codex-matrix/summary.md`
- Attempted active iPhone 17e manual telemetry: `PlaytestArtifacts/2026-06-23-manual-active-17e-codex-matrix/telemetry/`
- Attempted active iPhone 17e manual notes: `PlaytestArtifacts/2026-06-23-manual-active-17e-codex-matrix/notes.md`
- Manual start-gate smoke summary: `PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/summary.md`
- Manual start-gate smoke telemetry: `PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/telemetry/`
- Manual start-gate smoke notes: `PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/notes.md`
- Logs:
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`

## Not Yet Validated

- 20 clean-install tutorial completions.
- Compact and large-height simulator matrices.
- Active human steering matrices; current manual active-input matrices are still missing. The latest iPhone 17e attempt produced only 1/5 active-input runs, but start-gated capture tooling now exists.
- Slow taps, rapid taps, repeated right movement, extra movement after target.
- Crash, capture, missed-exit, retry, return to menu.
- Full 405 Afterburn completion/balance matrix; current evidence is only a tap-through and active-input split-slot smoke validation.
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
- Debug autoplay now has a strict emergency fallback for cases where staying is predicted dangerous and every normal transition candidate is rejected.
- The active-lifetime GameSim diagnostic now has a deterministic risk-score equivalent for emergency movement comparison.
- Direct-start manual capture mode now exists for first-minute human matrices.
- Debug start-gated manual capture mode now exists for active human matrices that need the player to be ready before the run begins.
- Passive manual no-input matrices now pass on iPhone 17e and iPhone 17 Pro after the passive police-capture threshold; both sampled devices ended 5/5 runs as `police_caught` at 9.0s with autoplay disabled.
- Final tutorial exit-ramp signage is visible on the current five-step flow, and the final lesson advances automatically after the exit-side predicate and read gate are both satisfied.
- Debug first-escape payoff capture now proves the result-screen unlock copy, selected Starter Bike save state, completed Sunset Merge save state, and primary `USE BIKE` affordance.
- The real `USE BIKE` button now has smoke evidence for launching 405 Afterburn with Starter Bike selected and accepting active split-slot motorcycle input.

## Manual Capture Command

```bash
python3 -u scripts/capture_live_telemetry.py --device <SIMULATOR_UDID> --manual --wait-for-start-tap --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/<timestamp>-manual-first-minute/telemetry --timeout 180
python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/<timestamp>-manual-first-minute/telemetry > PlaytestArtifacts/<timestamp>-manual-first-minute/summary.md
```
