# Traffic Getaway Codex Handoff

## Milestone

First-minute reliability, deterministic-core repair, live telemetry, live lane-change transition diagnosis, active-traffic diagnostic calibration, first-escape payoff evidence, manual-capture tooling, and full recorded playtest setup: partial. Tightened debug autoplay now clears the sampled iPhone 17e first minute, Dynamic Island debug autoplay is improved but not locked, the Starter Bike result-screen payoff and `USE BIKE` tap-through into 405 Afterburn are smoke-validated, start-gated manual capture tooling is ready, the full recorded playtest artifact root exists with one valid iPhone 17e active run, and GameSim's opt-in active-traffic lifetime diagnostic has moved toward live evidence but remains too punitive for balance.

## Verified baseline

- Branch/state before edits: `main...origin/main [ahead 1]`, HEAD `a5af66b Testrun`, clean working tree.
- Required source docs were missing from `Docs/`; only `Docs/.DS_Store` existed at session start.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1` could not run on this Mac because `powershell` is not installed.
- PBX validation passed.
- `GameCore` baseline failed determinism and traffic stress:
  - `testSimulationIsDeterministic` produced different `ChaseRunResult` values for the same seed/config.
  - `testSunsetMergeTrafficStressCommitsReachableWaves` reported 203 impossible committed waves and 203 exit reachability failures.
- Baseline GameSim Level 1 Starter Compact: 10,000 runs, avg survival 43.3s, completed 98.7%, near misses 32.1, avg cash 909, avg XP 359, unfair collision 0.0%.
- Baseline traffic stress: 160,000 waves, 9,432 fallback waves, 9,432 impossible committed waves, 9,432 exit reachability failures.
- Mac app build passed before edits.
- Simulator launch reproduced a white first frame; evidence: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/01-launch.png`.

## Changes made

- `GameCore/Sources/GameCore/ChaseSimulator.swift`: made slot selection deterministic by sorting reachable safe slots and adding a stable tie-breaker.
- `GameCore/Sources/GameCore/TrafficSafety.swift`: changed active-exit validation to preserve a reachable step toward the exit when the player is not yet on the exit side, and to preserve an exit-side route once they are.
- `GameCore/Sources/GameCore/TrafficSafety.swift`: added pure transition safety filtering for active hazards, including lane-change-duration path exposure and short target-slot prediction.
- `GameCore/Sources/GameCore/ChaseSimulator.swift`: added an opt-in active-traffic lifetime diagnostic mode that carries spawned hazards forward, checks current-slot collision, and filters decisions through transition safety.
- `GameCore/Sources/GameCore/TrafficPatternGenerator.swift`: stopped returning invalid recovery waves as committed plans.
- `GameSim/Sources/GameSim/main.swift`: added `--active-traffic-lifetime` to run the active on-screen traffic diagnostic without changing default balance output.
- `Traffic Getaway/AppConfig.swift`: added off-by-default flags for rewarded revives and rewarded cash doubles.
- `Traffic Getaway/GameScene.swift`: disabled first-crash revive offers unless `rewardedRevivesEnabled` is explicitly enabled.
- `Traffic Getaway/ResultsScene.swift`: hid cash-doubling reward UI unless `rewardedCashDoublesEnabled` is explicitly enabled.
- `Traffic Getaway/OnboardingScene.swift`: removed the tutorial page that promised a revive.
- `Traffic Getaway/OnboardingScene.swift`: fixed the final exit-ramp illustration so `EXIT RIGHT` appears on the current five-step tutorial, added an explicit exit-side lane/visual completion predicate, added debug tutorial diagnostics, and auto-advances the final lesson after the read gate opens.
- `Traffic Getaway/MainMenuScene.swift`: made cash/best-score accessibility label/value use the same final string as visible state after the count-up.
- `Traffic Getaway/Info.plist` and `Traffic Getaway/Assets.xcassets/LaunchBackground.colorset/Contents.json`: added a dark launch-screen color to remove the white system launch frame.
- `Traffic Getaway/TrafficSafetyAnalyzer.swift`: matched the app-side active-exit route validation to the fixed `GameCore` route-preservation rule.
- `Traffic Getaway/TrafficPatternGenerator.swift`: stopped the app-side generator from committing invalid recovery waves.
- `Traffic Getaway/RunTelemetryRecorder.swift`: added debug JSONL live-run telemetry for run starts, traffic waves, lane changes, exits, collisions, and run endings.
- `Traffic Getaway/RunTelemetryRecorder.swift`: extended telemetry with active traffic snapshots: spawn ID, lane, slot, lane span, type, speed, y-position, size, spawn time, and roadblock state.
- `Traffic Getaway/RunTelemetryRecorder.swift`: added debug autoplay movement-decision telemetry with live target, applied slot, reach, reachable slots, and GameSim policy target.
- `Traffic Getaway/GameScene.swift`: records live first-minute state including seed, player slot/lane, traffic pattern, safe slots, active traffic, exit state, police pressure, collision rectangles, and terminal outcomes; also adds a debug open-path overlay for lane centers, slot centers, safe slots, exit corridors, near-miss bands, hitboxes, wave ID, and seed.
- `Traffic Getaway/GameScene.swift`: records `autoplay_decision` events and compares debug autoplay choices against a GameSim-style route target.
- `Traffic Getaway/GameScene.swift`: debug autoplay now uses live on-screen hazard safety while immediate traffic is near and records whether each decision came from live hazards or the latest traffic-wave plan.
- `Traffic Getaway/GameScene.swift`: collision telemetry now records a structured crash-frame analysis with colliding vehicle, active traffic roster, player slot/lane, live safe and unsafe slots, overlap geometry, and the last movement decision.
- `Traffic Getaway/GameScene.swift`: lane-change parity telemetry now records logical slot, target slot, sprite x-position, sprite nearest slot, path danger, active traffic intersection, and completion state while the lane-change animation is active.
- `Traffic Getaway/GameScene.swift`: debug autoplay now rejects moves whose predicted lane-change path or post-move target horizon intersects active traffic, using a lane-change-duration horizon and small vertical padding on predicted traffic hitboxes.
- `Traffic Getaway/GameScene.swift`: debug autoplay now has a strict emergency-transition fallback for cases where every normal transition is rejected but staying is predicted dangerous; the fallback records `emergency_move` telemetry.
- `GameCore/Sources/GameCore/TrafficSafety.swift`: added deterministic transition risk scoring for active-hazard path comparison.
- `GameCore/Sources/GameCore/ChaseSimulator.swift`: calibrated the active-traffic lifetime diagnostic with live-like transition timing and a strict emergency transition comparison when staying put is riskier than moving.
- `GameCore/Tests/GameCoreTests/GameCoreTests.swift`: added coverage proving the risk score ranks an emergency move below staying in an incoming hazard.
- `Traffic Getaway/GameViewController.swift` and `Traffic Getaway/AppConfig.swift`: added debug-only direct level/vehicle auto-start defaults so simulator live telemetry can be captured without hand navigation.
- `Traffic Getaway.xcodeproj/project.pbxproj`: added the telemetry recorder to the iOS target.
- `scripts/summarize_run_telemetry.py`: added a repeatable JSONL summarizer for live-run telemetry exports, including autoplay target, move-target, applied-slot mismatch, decision-source, decision-status, collision-analysis counts, and lane-change probe counts.
- `scripts/capture_live_telemetry.py`: added a repeatable simulator capture loop for debug autoplay live-run matrices, with flushed progress output, a working empty `--app ''` skip-install path, and direct plist debug-default writes to avoid flaky simulator `defaults write` hangs.
- `scripts/capture_live_telemetry.py`: added `--manual` mode so the same direct-start telemetry loop can capture human-controlled runs with debug autoplay disabled.
- `scripts/capture_live_telemetry.py`: hardened debug-default cleanup by restarting simulator `cfprefsd` and raising if debug keys remain after capture.
- `scripts/capture_live_telemetry.py`: further hardened debug-default cleanup by stopping simulator `cfprefsd` before and after preference writes, preventing cached debug direct-start keys from reappearing after manual captures.
- Captured passive no-input manual matrices on iPhone 17e and iPhone 17 Pro, both with zero autoplay decisions and collision analysis in every terminal sample.
- `Traffic Getaway/GameScene.swift`: increased passive police catch-up while the player stays idle and added an explicit passive capture threshold after max passive pressure has been ignored, so no-input play resolves as `police_caught` before traffic or roadblocks can hide the failure reason.
- Captured post-fix passive no-input manual matrices on iPhone 17e and iPhone 17 Pro; both produced 5/5 `police_caught` terminals at 9.0s with zero autoplay decisions.
- `Traffic Getaway/AppConfig.swift` and `Traffic Getaway/GameViewController.swift`: added a debug-only first-escape result scenario that resets save data, synthesizes a completed Sunset Merge run, processes normal progression, and presents the real `ResultsScene`.
- `scripts/capture_progression_payoff.py`: added a repeatable simulator capture script for the first-escape Starter Bike payoff screenshot, metadata, save-state proof, and debug-default cleanup.
- `scripts/capture_live_telemetry.py`: added the result-scenario debug key to cleanup and hardened remaining debug-default cleanup with simulator shutdown/boot plist fallback.
- Captured the first Sunset Merge escape payoff on iPhone 17e; the result screen shows `ESCAPED`, `Starter Bike unlocked: split lanes`, and primary `USE BIKE`, with `starter_bike` selected and `la_01` completed in save state afterward.
- `scripts/validate_use_bike_tap_through.py`: added a telemetry validator for the real `USE BIKE` tap-through smoke artifact.
- Captured `USE BIKE` tap-through on iPhone 17e via the visible Simulator UI; telemetry proves 405 Afterburn launched with `starter_bike` as a motorcycle and active input reached interstitial split slot `11`.
- `Traffic Getaway/AppConfig.swift` and `Traffic Getaway/GameScene.swift`: added a debug-only `waitForStartTap` default so manual telemetry capture can pause on the existing start screen instead of launching immediately.
- `scripts/capture_live_telemetry.py`: added `--wait-for-start-tap`, writes and clears the debug start-gate key, and prints a manual-mode prompt to tap the start screen when ready.
- `scripts/summarize_run_telemetry.py`: added lane-change counts and active-input run counts so passive manual samples and active manual samples are distinguishable in summaries.
- `scripts/capture_progression_payoff.py`: clears the new start-gate debug key during cleanup.
- Captured an attempted active iPhone 17e manual matrix; it recorded 0 autoplay decisions but only 1/5 active-input runs, so it is partial/failed evidence and not a balance source.
- Captured a one-run iPhone 17e manual start-gate smoke sample; it paused on `Tap to Start`, then recorded 1/1 active-input run, 3 lane changes, and 0 autoplay decisions.
- Created the full recorded playtest artifact root at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/` with README, metadata, test matrix, findings, bugs ledger, balance observations, acceptance report, screenshots/videos/telemetry/log/build-validation folders.
- Captured one valid start-gated active iPhone 17e `la_01` / `starter_compact` run with full-screen video, start/result screenshots, raw telemetry, telemetry summary, and written observations.

## Tests run

- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"`: passed.
- `python3 scripts/validate_pbxproj_ids.py --self-test`: passed.
- `cd GameCore && swift test`: passed after fixes, 18 tests, 0 failures.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --traffic-stress`: passed stress gate after fixes, 160,000 waves, 0 impossible committed waves, 0 exit reachability failures.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`: passed command, but balance remains too easy.
- `bash Tools/mac/verify_on_mac.sh`: passed after fixes.
- `plutil -lint "Traffic Getaway/Info.plist"`: passed.
- Live telemetry smoke test on iPhone 17e simulator: passed; produced 24 JSONL events including `run_started`, 21 `traffic_wave` events, `collision`, and `run_ended`.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry`: passed; summarized the live crash sample.
- Re-ran `cd GameCore && swift test` after debug overlay changes: passed, 18 tests, 0 failures.
- Re-ran `bash Tools/mac/verify_on_mac.sh` after debug overlay changes: passed.
- `python3 scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry --timeout 100`: passed.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry`: passed.
- Re-ran `cd GameCore && swift test` after direct-start/capture changes: passed, 18 tests, 0 failures.
- Re-ran `bash Tools/mac/verify_on_mac.sh` after direct-start/capture changes: passed.
- Re-ran `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`: passed; current sim still reports 99.1% completion.
- Re-ran `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --traffic-stress`: passed; 160,000 waves, 0 impossible committed waves, 0 exit reachability failures.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after movement telemetry: passed, 99 unique IDs.
- `cd GameCore && swift test` after movement telemetry: passed, 18 tests, 0 failures.
- `bash Tools/mac/verify_on_mac.sh` after movement telemetry: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/telemetry --timeout 100`: produced corrected decision telemetry.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were missing after cleanup.
- Re-ran `bash Tools/mac/verify_on_mac.sh` after live-hazard autoplay changes: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/telemetry --timeout 120`: passed after explicitly installing the verified build.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were missing after the live-hazard capture.
- `python3 -m py_compile scripts/summarize_run_telemetry.py scripts/capture_live_telemetry.py`: passed after collision-analysis summarizer changes.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after collision-analysis telemetry: passed, 99 unique IDs.
- `bash Tools/mac/verify_on_mac.sh` after collision-analysis telemetry: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry --timeout 120`: passed after explicitly installing the verified build.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were missing after the collision-analysis capture.
- `python3 -m py_compile scripts/summarize_run_telemetry.py scripts/capture_live_telemetry.py`: passed after lane-change parity summarizer changes.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after lane-change parity telemetry: passed, 99 unique IDs.
- `bash Tools/mac/verify_on_mac.sh` after lane-change parity telemetry: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry --timeout 120`: passed after explicitly installing the verified build.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were missing after the lane-change parity capture.
- `python3 -m py_compile scripts/summarize_run_telemetry.py scripts/capture_live_telemetry.py`: passed after transition-clearance autoplay changes.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after transition-clearance autoplay: passed, 99 unique IDs.
- `bash Tools/mac/verify_on_mac.sh` after transition-clearance autoplay: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry --timeout 120`: passed after explicitly installing the verified build.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were missing after the transition-clearance capture.
- `python3 -m py_compile scripts/summarize_run_telemetry.py scripts/capture_live_telemetry.py`: passed after tightened transition-clearance autoplay changes.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after tightened transition-clearance autoplay: passed, 99 unique IDs.
- `bash Tools/mac/verify_on_mac.sh` after tightened transition-clearance autoplay: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --runs 5 --level la_01 --vehicle starter_compact --app '' --output-dir PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/telemetry --timeout 120`: passed after explicitly installing the verified build.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were missing after the tightened transition-clearance capture.
- `cd GameCore && swift test` after active-traffic lifetime diagnostic calibration: passed, 21 tests, 0 failures.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345` after active-traffic diagnostic: passed; default output remains 99.1% completion, 35.3 near misses/run, 998 cash/run.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --active-traffic-lifetime`: passed; diagnostic output is 0.0% completion, 7.3s average survival, 6.5s median survival, 2.1 near misses/run, 58 cash/run, 33.3% unfair collision estimate, top failure `traffic_collision:6668`.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --traffic-stress` after active-traffic diagnostic: passed; 160,000 waves, 0 impossible committed waves, 0 exit reachability failures.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after tutorial exit-ramp fix: passed, 99 unique IDs.
- `bash Tools/mac/verify_on_mac.sh` after tutorial exit-ramp fix: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry --timeout 120`: passed after installing the verified build on iPhone 17 Pro simulator.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were manually cleared after the Dynamic Island capture.
- `bash Tools/mac/verify_on_mac.sh` after emergency-transition fallback: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry --timeout 120`: passed after installing the verified build on iPhone 17 Pro simulator.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry`: passed.
- Direct plist verification confirmed the debug auto-start/autoplay keys were manually cleared after the emergency-transition capture.
- `cd GameCore && swift test` after active-lifetime emergency-risk calibration: passed, 22 tests, 0 failures.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345` after active-lifetime emergency-risk calibration: passed; default output remains 99.1% completion, 35.3 near misses/run, 998 cash/run.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --active-traffic-lifetime` after active-lifetime emergency-risk calibration: passed; diagnostic output improved to 0.3% completion, 10.7s average survival, 8.8s median survival, 2.8 near misses/run, 75 cash/run, 59.4% unfair collision estimate, top failure `traffic_collision:4032`.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --traffic-stress` after active-lifetime emergency-risk calibration: passed; 160,000 waves, 0 impossible committed waves, 0 exit reachability failures.
- `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py` after manual capture mode: passed.
- `python3 scripts/capture_live_telemetry.py --help` after manual capture mode: passed and lists `--manual`.
- Manual defaults self-check after manual capture mode: passed; `TrafficGetaway.debug.autoplay` is written as `false` for manual capture and debug defaults are cleared afterward.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/telemetry --timeout 120`: passed.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/telemetry`: passed.
- Direct plist verification confirmed iPhone 17e debug defaults were cleared after the passive manual matrix.
- `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/telemetry --timeout 120`: passed.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/telemetry`: passed.
- Direct plist verification confirmed iPhone 17 Pro debug defaults were cleared after the passive manual matrix.
- `bash Tools/mac/verify_on_mac.sh` after passive police-capture fix: passed.
- `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py` after passive police-capture fix: passed.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after passive police-capture fix: passed, 99 unique IDs.
- `git diff --check` after passive police-capture fix: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/telemetry --timeout 120`: passed.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/telemetry`: passed.
- `python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --manual --runs 5 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/telemetry --timeout 120`: passed.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/telemetry`: passed.
- Direct plist verification confirmed iPhone 17e and iPhone 17 Pro debug defaults were cleared after the passive police-capture matrices.
- `bash Tools/mac/verify_on_mac.sh` after first-escape payoff scenario: passed.
- `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py scripts/capture_progression_payoff.py` after first-escape payoff tooling: passed.
- `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` after first-escape payoff tooling: passed, 99 unique IDs.
- `python3 scripts/capture_progression_payoff.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --output-dir PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike`: passed.
- Direct plist/save-state verification confirmed selected `starter_bike`, unlocked `[starter_compact, starter_bike]`, completed `[la_01]`, `totalRuns=1`, and no remaining debug defaults after the payoff capture.
- `python3 -m py_compile scripts/capture_progression_payoff.py scripts/validate_use_bike_tap_through.py`: passed.
- `python3 scripts/validate_use_bike_tap_through.py PlaytestArtifacts/2026-06-23-use-bike-tap-through/405-afterburn-starter-bike-telemetry.jsonl`: passed; 26 events, `run_started` `la_02` / `starter_bike` / `motorcycle`, 2 lane changes, 1 split-slot lane change.
- Direct plist verification confirmed no remaining `TrafficGetaway.debug.*` defaults after the tap-through smoke run.
- `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py scripts/capture_progression_payoff.py scripts/validate_use_bike_tap_through.py` after manual start-gate tooling: passed.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-manual-active-17e-codex-matrix/telemetry`: passed; 5 runs, 0/5 completed, 1/5 active-input runs, 5 lane changed events, 0 autoplay decisions.
- `python3 -u scripts/capture_live_telemetry.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --manual --wait-for-start-tap --runs 1 --level la_01 --vehicle starter_compact --output-dir PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/telemetry --timeout 90`: passed after tapping the start screen and steering in Simulator.
- `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/telemetry`: passed; 1 run, 0/1 completed, 1/1 active-input runs, 3 lane changed events, 0 autoplay decisions.
- Direct plist verification confirmed no remaining `TrafficGetaway.debug.*` defaults after the manual start-gate smoke run.
- Final cleanup validation after documentation updates:
  - `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py scripts/capture_progression_payoff.py scripts/validate_use_bike_tap_through.py`: passed.
  - `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"`: passed, 99 unique IDs.
  - `git diff --check`: passed.
  - Regenerated attempted-active and start-gate telemetry summaries: passed.
  - `cd GameCore && swift test`: passed, 22 tests, 0 failures.
  - `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`: passed; completion 99.1%, near misses/run 35.3, avg cash 998, recommendation still says Level 1 may be too easy.
  - `bash Tools/mac/verify_on_mac.sh`: passed, iOS Simulator Debug build succeeded.
  - Direct plist verification confirmed no remaining `TrafficGetaway.debug.*` defaults on iPhone 17e after cleanup.
- Full recorded playtest setup validation:
  - `python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py scripts/capture_progression_payoff.py scripts/validate_use_bike_tap_through.py`: passed; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/python-py-compile.log`.
  - `python3 scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"`: passed; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/pbxproj-validation.log`.
  - `git diff --check`: passed; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/git-diff-check.log`.
  - `swift test --package-path GameCore`: passed, 22 tests, 0 failures; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/gamecore-swift-test.log`.
  - `swift run --package-path GameSim GameSim --level all --vehicle starter_compact --runs 1000 --seed 12345`: passed across all 15 levels; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/gamesim-all-levels-starter-compact.log`.
  - `swift run --package-path GameSim GameSim --level all --vehicle starter_bike --runs 1000 --seed 12345`: passed across all 15 levels; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/gamesim-all-levels-starter-bike.log`.
  - `bash Tools/mac/verify_on_mac.sh`: passed; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/verify-on-mac.log`.
  - Installed verified build on iPhone 17e and iPhone 17 Pro simulators and confirmed `debug defaults=[]`; log saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/install-and-debug-defaults-check.log`.
  - `python3 scripts/summarize_run_telemetry.py PlaytestArtifacts/2026-06-23-full-recorded-playtest/telemetry/raw`: passed for Run 01; summary saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run01-summary.md`.

## Simulator/device evidence

- Simulator: iPhone 17e, iOS 26.5, Debug simulator build from `/tmp/TrafficGetawayVerifyDerivedData`.
- Before launch fix: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/01-launch.png` captured a white screen.
- After launch fix: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/02-launch-after-fix.png` captured the dark first tutorial screen.
- Live telemetry run: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/04-live-telemetry-run.png` plus `PlaytestArtifacts/2026-06-22-production-pass-18-38/telemetry/2026-06-22_18-49-43-la_01-starter_compact-17033032432948192956.jsonl`.
- Debug diagnostic overlay: `PlaytestArtifacts/2026-06-22-production-pass-18-38/screenshots/05-debug-diagnostics-overlay.png`.
- Telemetry sample ended in a traffic collision at 22.946s with 21 traffic waves logged; pattern counts were `staggeredCars` 8, `denseClusters` 6, `sparseLanes` 6, and `recoveryWave` 1.
- Telemetry summarizer result: 1 run, 0/1 completed, average terminal time 22.9s, 4 near misses, 44 cash, wanted level 3, collision rectangles present.
- Autoplay matrix: `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/telemetry/`.
- Autoplay matrix summary: `PlaytestArtifacts/2026-06-22-live-autoplay-matrix-active-traffic/summary.md`.
- Autoplay matrix result: 5 iPhone 17e debug-autoplay runs, 0/5 completed, avg terminal time 6.4s, median terminal time 4.4s, avg traffic waves 6.2, avg near misses 2.2, traffic collision in all 5, collision rectangles and active traffic snapshots present in all 5.
- Autoplay decision matrix: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/telemetry/`.
- Autoplay decision matrix summary: `PlaytestArtifacts/2026-06-22-live-autoplay-decision-matrix/summary.md`.
- Autoplay decision matrix result: 5 iPhone 17e debug-autoplay runs, 0/5 completed, avg terminal time 6.3s, median terminal time 5.2s, avg traffic waves 6.2, avg near misses 0.6, traffic collision in all 5, 207 autoplay decisions, 18 move decisions, 36 target-policy mismatches, 2 move-target mismatches, and 2 applied-slot mismatches.
- Live-hazard autoplay matrix: `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/telemetry/`.
- Live-hazard autoplay matrix summary: `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/summary.md`.
- Live-hazard autoplay matrix result: 5 iPhone 17e debug-autoplay runs, 0/5 completed, avg terminal time 8.6s, median terminal time 4.5s, avg traffic waves 8.4, avg near misses 2.6, traffic collision in all 5, 269 autoplay decisions, 41 move decisions, 176 live-hazard decisions, 93 latest-wave decisions, and one run that survived 24.9s.
- Collision-analysis autoplay matrix: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/telemetry/`.
- Collision-analysis autoplay matrix summary: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/summary.md`.
- Collision-analysis autoplay matrix notes: `PlaytestArtifacts/2026-06-23-live-collision-analysis-matrix/notes.md`.
- Collision-analysis autoplay matrix result: 5 iPhone 17e debug-autoplay runs, 0/5 completed, avg terminal time 5.2s, median terminal time 4.7s, avg traffic waves 5.4, avg near misses 1.0, traffic collision in all 5, collision analysis in 5/5, avg active traffic at collision 10.6, and the last movement decision before every sampled crash was `move`.
- Collision-analysis read: sampled early live crashes are now narrowed to lane-change transition timing/path occupancy. The logical player slot can advance to a selected safe slot while the SpriteKit car is still physically intersecting the departure lane or movement path.
- Lane-change parity matrix: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/telemetry/`.
- Lane-change parity matrix summary: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/summary.md`.
- Lane-change parity matrix notes: `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/notes.md`.
- Lane-change parity matrix result: 5 iPhone 17e debug-autoplay runs, 0/5 completed, avg terminal time 7.9s, median terminal time 6.6s, avg traffic waves 7.6, avg near misses 1.8, traffic collision in all 5, 163 lane-change probes across 26 transitions, 3 lane-change intersection probes, 1 unsafe-path probe, and 3/5 last pre-crash probes already intersecting traffic.
- Lane-change parity read: the next fix should be transition-aware. A move should only be considered safe if the current-to-target path stays clear for the lane-change duration and the target slot remains safe on a short post-move horizon.
- Transition-clearance matrix: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/telemetry/`.
- Transition-clearance matrix summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/summary.md`.
- Transition-clearance matrix notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-matrix/notes.md`.
- Transition-clearance matrix result: 5 iPhone 17e debug-autoplay runs, 1/5 completed, avg terminal time 26.7s, median terminal time 30.0s, avg traffic waves 23.4, avg near misses 6.4, 742 lane-change probes across 121 transitions, 2 lane-change intersection probes, 1 unsafe-path probe, and 6 `no_transition_safe_slots` decisions.
- Transition-clearance read: this is the first live autoplay matrix to produce an escape and it moves first-minute telemetry toward target, but 4/5 runs still crash and the next pass should tighten the target-slot horizon/padding before retuning or moving the model into GameSim.
- Tightened transition-clearance matrix: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/telemetry/`.
- Tightened transition-clearance matrix summary: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/summary.md`.
- Tightened transition-clearance matrix notes: `PlaytestArtifacts/2026-06-23-live-transition-clearance-tightened-matrix/notes.md`.
- Tightened transition-clearance matrix result: 5 iPhone 17e debug-autoplay runs, 5/5 completed, avg terminal time 42.8s, median terminal time 42.7s, avg traffic waves 36.2, avg near misses 14.0, 1079 lane-change probes across 183 transitions, 0 lane-change intersection probes, 2 unsafe-path probes, and 18 `no_transition_safe_slots` decisions.
- Tightened transition-clearance read: the longer transition horizon plus padded predicted traffic hitboxes closed the sampled live autoplay failure, but it is still debug-autoplay evidence rather than human difficulty evidence.
- GameSim active-traffic lifetime diagnostic command: `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --active-traffic-lifetime`.
- GameSim active-traffic lifetime diagnostic result after emergency-risk calibration: 10,000 runs, 0.3% completed, avg survival 10.7s, median survival 8.8s, first crash p10/p50/p90 4.8s / 8.8s / 19.8s, avg near misses 2.8/run, avg cash/XP 75/40, unfair collision estimate 59.4%, top failure `traffic_collision:4032`.
- GameSim active-traffic lifetime read: deterministic and moving toward the tightened live evidence. Risk-aware emergency movement and live-like transition timing improved average survival from 7.3s to 10.7s, but it remains much too punitive versus tightened live autoplay, so it needs further calibration before balance tuning.
- Dynamic Island transition-clearance matrix: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry/`.
- Dynamic Island transition-clearance matrix summary: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/summary.md`.
- Dynamic Island transition-clearance matrix notes: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/notes.md`.
- Dynamic Island transition-clearance result: 5 iPhone 17 Pro debug-autoplay runs, 3/5 completed, avg terminal time 38.9s, median terminal time 42.3s, avg first crash 32.3s, avg traffic waves 33.6, avg near misses 16.6, 1039 lane-change probes across 198 transitions, 0 lane-change intersection probes, 1 unsafe-path probe, and 23 `no_transition_safe_slots` decisions.
- Dynamic Island transition-clearance read: the transition-path fix held on a Dynamic Island-class device, but 2/5 traffic collisions show device-shape/live timing sensitivity remains unresolved.
- Dynamic Island emergency-transition matrix: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry/`.
- Dynamic Island emergency-transition matrix summary: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/summary.md`.
- Dynamic Island emergency-transition matrix notes: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/notes.md`.
- Dynamic Island emergency-transition result: 5 iPhone 17 Pro debug-autoplay runs, 4/5 completed, avg terminal time 38.4s, median terminal time 42.4s, avg first crash 21.5s, avg traffic waves 31.4, avg near misses 15.8, 1103 lane-change probes across 191 transitions, 0 lane-change intersection probes, 0 unsafe-path probes, 1 `emergency_move`, and 19 `no_transition_safe_slots` decisions.
- Dynamic Island emergency-transition read: the fallback reduced sampled Dynamic Island traffic terminals from 2 to 1 without reopening lane-change intersection failures, but it remains debug-autoplay evidence.
- Passive iPhone 17e manual matrix: `PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/telemetry/`.
- Passive iPhone 17e manual matrix summary: `PlaytestArtifacts/2026-06-23-manual-passive-17e-matrix/summary.md`.
- Passive iPhone 17e manual matrix result: 5 no-input manual runs, 0/5 completed, avg terminal time 21.6s, median terminal time 21.5s, terminal reasons `traffic` 5, autoplay decisions 0, collision analysis 5/5.
- Passive iPhone 17 Pro manual matrix: `PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/telemetry/`.
- Passive iPhone 17 Pro manual matrix summary: `PlaytestArtifacts/2026-06-23-manual-passive-17pro-matrix/summary.md`.
- Passive iPhone 17 Pro manual matrix result: 5 no-input manual runs, 0/5 completed, avg terminal time 32.9s, median terminal time 23.7s, terminal reasons `traffic` 4 and `roadblock` 1, autoplay decisions 0, collision analysis 5/5.
- Passive baseline matrix read: passive/no-input play failed as traffic/roadblock crashes rather than police capture pressure.
- Passive police-capture iPhone 17e manual matrix: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/telemetry/`.
- Passive police-capture iPhone 17e manual matrix summary: `PlaytestArtifacts/2026-06-23-passive-police-capture-17e-matrix/summary.md`.
- Passive police-capture iPhone 17e manual matrix result: 5 no-input manual runs, 0/5 completed, avg terminal time 9.0s, median terminal time 9.0s, terminal reasons `police_caught` 5, autoplay decisions 0.
- Passive police-capture iPhone 17 Pro manual matrix: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/telemetry/`.
- Passive police-capture iPhone 17 Pro manual matrix summary: `PlaytestArtifacts/2026-06-23-passive-police-capture-17pro-matrix/summary.md`.
- Passive police-capture iPhone 17 Pro manual matrix result: 5 no-input manual runs, 0/5 completed, avg terminal time 9.0s, median terminal time 9.0s, terminal reasons `police_caught` 5, autoplay decisions 0.
- Passive police-capture matrix read: passive/no-input play now resolves as police capture pressure on both sampled devices before traffic or roadblocks become terminal.
- Starter Bike payoff capture: `PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike/starter-bike-use-bike-results.png`.
- Starter Bike payoff notes: `PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike/notes.md`.
- Starter Bike payoff read: the first Sunset Merge escape payoff now has visual and save-state proof for result-screen unlock copy, selected Starter Bike state, completed Sunset Merge state, and primary `USE BIKE`.
- `USE BIKE` tap-through artifact: `PlaytestArtifacts/2026-06-23-use-bike-tap-through/`.
- `USE BIKE` tap-through read: the real result-button click launched 405 Afterburn with `starter_bike`; telemetry recorded `vehicleClass=motorcycle` and an active-input lane change into split slot `11`. This is not a full 405 Afterburn completion or balance matrix.
- Attempted active iPhone 17e manual matrix: `PlaytestArtifacts/2026-06-23-manual-active-17e-codex-matrix/`.
- Attempted active iPhone 17e manual result: 5 runs, 0/5 completed, avg terminal time 12.6s, active-input runs 1/5, lane changed events 5, terminal reasons `police_caught` 4 and `roadblock` 1, autoplay decisions 0.
- Attempted active iPhone 17e manual read: this is not a valid active-steering matrix because most runs effectively became passive police-capture samples before sustained input began.
- Manual start-gate smoke artifact: `PlaytestArtifacts/2026-06-23-manual-start-gate-smoke/`.
- Manual start-gate smoke result: 1 run, 0/1 completed, active-input runs 1/1, lane changed events 3, terminal reason `traffic` at 5.1s, autoplay decisions 0.
- Manual start-gate smoke read: `--wait-for-start-tap` proves the next active-steering matrix can begin from the existing start screen when the player is ready; it is tooling evidence, not balance evidence.
- Full recorded playtest artifact root: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/`.
- Full recorded playtest current counts: planned tests 73, passed 17, partial 1, not tested 55, valid active-input runs 10, invalid runs 1.
- Full recorded playtest LA Starter Compact slice: five complete-evidence iPhone 17e active runs are captured for `la_01` / `starter_compact` / default `SWIPE + TAP` using tap input; run 03 is supplemental active telemetry/video evidence but is excluded from the five complete-evidence count because it lacks the result screenshot.
- Full recorded playtest LA Starter Compact aggregate: 6/6 active-input runs, 0/6 completed, average terminal time 7.6s, median terminal time 7.5s, traffic collision in all 6, 15 lane changes, 27 lane-change probes, 0 autoplay decisions, collision analysis in 6/6.
- Full recorded playtest LA Starter Bike slice: three complete-evidence iPhone 17e active runs are captured for `la_01` / `starter_bike` / default `SWIPE + TAP` using tap input; counted runs are Bike Runs 03, 04, and 05. Bike Run 02 has telemetry/result evidence but is rejected from the complete-evidence count because the start screenshot and video are missing.
- Full recorded playtest LA Starter Bike aggregate: 3/3 active-input runs, 0/3 completed, average terminal time 27.5s, median terminal time 21.1s, terminal reasons `traffic` twice and `roadblock` once, 13 lane changes, 43 lane-change probes, 0 autoplay decisions, collision analysis in 3/3. Run 04 reached right-exit countdown at about 50s before crashing.
- Full recorded playtest P1 issue: `FTG-P1-001` documents that active iPhone 17e LA01 runs all crash before 10 seconds, contradicting the intended first-minute target and showing sim/live/manual difficulty are not reconciled.
- Full recorded playtest P1 issue: `FTG-P1-002` documents that complete-evidence active iPhone 17e LA01 Starter Bike runs fail 3/3, including one right-exit-countdown crash and one roadblock hit.
- Full recorded playtest evidence: video files `run01` through `run06` under `PlaytestArtifacts/2026-06-23-full-recorded-playtest/videos/city-1/`, raw telemetry under `telemetry/raw/`, aggregate summary `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md`, and observations under `logs/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run0*-observations.md`.
- Full recorded playtest Bike evidence: video files `2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run03.mp4` through `run05.mp4`, raw telemetry under `telemetry/raw/`, aggregate summary `telemetry/summaries/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_runs03-05-summary.md`, and observations under `logs/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_run0*-observations.md`.
- Full recorded playtest failure/retry evidence: `videos/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01.mp4`, screenshots for start/result/retry-return under `screenshots/progression/`, raw telemetry `telemetry/raw/01-2026-06-23_09-42-21-la_01-starter_bike-16090129143462938849.jsonl`, summary `telemetry/summaries/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01-summary.md`, and observations `logs/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01-observations.md`.
- Full recorded playtest capture-tooling note: `--leave-app-running` now preserves the result UI for screenshots and warns that the app should be terminated and debug defaults verified afterward; post-run iPhone 17e cleanup proof is saved at `PlaytestArtifacts/2026-06-23-full-recorded-playtest/build-validation/post-run-debug-defaults-check.log`.
- Logs:
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`

## Metrics before and after

| Metric | Before | After |
|---|---:|---:|
| GameCore tests | 18 tests, 3 failures | 21 tests, 0 failures |
| Traffic stress impossible waves | 9,432 / 160,000 | 0 / 160,000 |
| Traffic stress exit failures | 9,432 / 160,000 | 0 / 160,000 |
| Level 1 completion | 98.7% | 99.1% |
| Level 1 near misses | 32.1/run | 35.3/run |
| Level 1 avg cash | 909 | 998 |
| Level 1 avg XP | 359 | 391 |
| Live telemetry | Not present | 1 manual smoke run, multiple debug-autoplay matrices, and passive no-input manual matrices on iPhone 17e/iPhone 17 Pro captured |
| Debug visualization | Not present | Open-path overlay screenshot captured |
| Active traffic telemetry | Not present | Present in new collision samples |
| Autoplay decision telemetry | Not present | 207 decisions captured; 36 target-policy mismatches, 2 move-target mismatches, 2 applied-slot mismatches |
| Live-hazard autoplay | Not present | 269 decisions captured; 176 live-hazard decisions; avg terminal time 8.6s but still 0/5 complete |
| Collision-analysis telemetry | Not present | 5/5 sampled terminal crashes include colliding vehicle, active roster, safe slots, overlap, and last movement decision |
| Lane-change parity telemetry | Not present | 163 lane-change probes captured; 3/5 last pre-crash probes intersected traffic |
| Transition-clearance autoplay | Not present | Baseline transition clearance: 1/5 completed, avg terminal time 26.7s. Tightened transition clearance: 5/5 completed, avg terminal time 42.8s, 0 lane-change intersection probes |
| Active-traffic GameSim diagnostic | Not present | Opt-in mode exists; first calibration improved avg survival from 7.3s to 10.7s, but 0.3% completion remains too punitive |
| Dynamic Island debug autoplay | Not present | iPhone 17 Pro tightened transition clearance: 3/5 completed. Emergency fallback: 4/5 completed, 42.4s median terminal time, 0 lane-change intersection probes, 1 traffic collision |
| Passive no-input outcome | Traffic/roadblock terminals | iPhone 17e and iPhone 17 Pro post-fix matrices both produce 5/5 `police_caught` terminals at 9.0s with autoplay disabled |
| First escape payoff | Smoke validated | Result-screen screenshot shows `ESCAPED`, `Starter Bike unlocked: split lanes`, and `USE BIKE`; save state selects `starter_bike`, completes `la_01`, leaves debug defaults cleared, and real tap-through starts `la_02` with motorcycle split-slot input |
| Manual active capture | Ungated direct-start only | Ungated 17e attempt produced only 1/5 active-input runs; start-gated smoke produced 1/1 active-input run with 3 lane changes and autoplay disabled |
| Full recorded playtest | In progress | Artifact scaffold exists; automated validation passed; LA Starter Compact iPhone 17e slice has five complete-evidence active runs plus one supplemental active run; LA Starter Bike has three complete-evidence active runs; failure/retry functional session is recorded; both opening slices are 0% complete in counted active play |

## Remaining defects

- P0 ship blocker: Sunset Merge balance is far too easy and over-rewarding versus target; completion is about 99%, near misses around 35/run, cash around 998/run.
- P1 milestone blocker: Full clean-install tutorial completion matrix has not been manually or automatically exercised.
- P1 milestone blocker: Sim/live reconciliation is still not complete; tightened transition-clearance autoplay completed 5/5 iPhone 17e runs and 4/5 iPhone 17 Pro runs after emergency fallback, passive no-input manual matrices are captured, but active steering validation is still missing and the active-traffic diagnostic still overcorrects. The latest active iPhone 17e attempt is partial/failed evidence because only 1/5 runs had active input.
- P1 milestone blocker: Full recorded playtest is incomplete. Current full-playtest artifact has completed only the Los Angeles Starter Compact and Starter Bike iPhone 17e slices; New York, Miami, tutorial, progression, Dynamic Island active play, pause/retry/backgrounding, and many required videos are still not tested.
- P1 gameplay blocker candidate: Active iPhone 17e LA01 Starter Compact runs all ended as traffic collisions before 10 seconds (`FTG-P1-001`).
- P1 gameplay blocker candidate: Active iPhone 17e LA01 Starter Bike complete-evidence runs failed 3/3 (`FTG-P1-002`), including one roadblock hit and one run that reached the right-exit countdown before crashing.
- P1 milestone blocker: Starter Bike payoff is smoke-validated through `USE BIKE` into 405 Afterburn, but full 405 Afterburn active-input completion and balance have not been validated.
- P2 important polish: Remaining duplicate app-local rules need incremental migration/parity against `GameCore`.
- P2 important polish: Reward/monetization code remains present behind disabled flags and needs a real integration or removal before release.

## Risks

- The exit reachability model now validates path preservation across waves; future stricter tests should add multi-wave route proofs and bad-seed fixtures.
- The simulator launch logs include simulator/accessibility/audio warnings; no app crash was observed, but full manual flow validation is still needed.
- The app target still does not import `GameCore`; rules are duplicated between app and pure Swift systems.
- The debug overlay, debug direct-start defaults, debug manual start gate, and debug result scenario are intentionally debug-only and should remain off for normal production screenshots/play.

## Next highest-priority action

Continue `PlaytestArtifacts/2026-06-23-full-recorded-playtest/`: capture the Los Angeles Starter Bike three-run slice next, then Dynamic Island active coverage and New York/Miami starter-vehicle coverage before retuning Sunset Merge.
