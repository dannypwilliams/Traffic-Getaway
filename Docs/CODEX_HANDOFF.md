# Traffic Getaway Codex Handoff

## Milestone

First-minute reliability, deterministic-core repair, live telemetry, and live lane-change transition diagnosis: partial. Tightened debug autoplay now clears the sampled live first minute, but human-controlled validation and GameSim model ownership remain open.

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
- `GameCore/Sources/GameCore/TrafficPatternGenerator.swift`: stopped returning invalid recovery waves as committed plans.
- `Traffic Getaway/AppConfig.swift`: added off-by-default flags for rewarded revives and rewarded cash doubles.
- `Traffic Getaway/GameScene.swift`: disabled first-crash revive offers unless `rewardedRevivesEnabled` is explicitly enabled.
- `Traffic Getaway/ResultsScene.swift`: hid cash-doubling reward UI unless `rewardedCashDoublesEnabled` is explicitly enabled.
- `Traffic Getaway/OnboardingScene.swift`: removed the tutorial page that promised a revive.
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
- `Traffic Getaway/GameViewController.swift` and `Traffic Getaway/AppConfig.swift`: added debug-only direct level/vehicle auto-start defaults so simulator live telemetry can be captured without hand navigation.
- `Traffic Getaway.xcodeproj/project.pbxproj`: added the telemetry recorder to the iOS target.
- `scripts/summarize_run_telemetry.py`: added a repeatable JSONL summarizer for live-run telemetry exports, including autoplay target, move-target, applied-slot mismatch, decision-source, decision-status, collision-analysis counts, and lane-change probe counts.
- `scripts/capture_live_telemetry.py`: added a repeatable simulator capture loop for debug autoplay live-run matrices, with flushed progress output, a working empty `--app ''` skip-install path, and direct plist debug-default writes to avoid flaky simulator `defaults write` hangs.

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
- Logs:
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-launch-after-fix.log`
  - `PlaytestArtifacts/2026-06-22-production-pass-18-38/logs/simulator-telemetry-run.log`

## Metrics before and after

| Metric | Before | After |
|---|---:|---:|
| GameCore tests | 18 tests, 3 failures | 18 tests, 0 failures |
| Traffic stress impossible waves | 9,432 / 160,000 | 0 / 160,000 |
| Traffic stress exit failures | 9,432 / 160,000 | 0 / 160,000 |
| Level 1 completion | 98.7% | 99.1% |
| Level 1 near misses | 32.1/run | 35.3/run |
| Level 1 avg cash | 909 | 998 |
| Level 1 avg XP | 359 | 391 |
| Live telemetry | Not present | 1 manual smoke run, 5 active-traffic autoplay runs, 5 corrected decision-matrix autoplay runs, 5 live-hazard autoplay runs, 5 lane-change parity runs, 5 transition-clearance runs, and 5 tightened transition-clearance runs captured |
| Debug visualization | Not present | Open-path overlay screenshot captured |
| Active traffic telemetry | Not present | Present in new collision samples |
| Autoplay decision telemetry | Not present | 207 decisions captured; 36 target-policy mismatches, 2 move-target mismatches, 2 applied-slot mismatches |
| Live-hazard autoplay | Not present | 269 decisions captured; 176 live-hazard decisions; avg terminal time 8.6s but still 0/5 complete |
| Collision-analysis telemetry | Not present | 5/5 sampled terminal crashes include colliding vehicle, active roster, safe slots, overlap, and last movement decision |
| Lane-change parity telemetry | Not present | 163 lane-change probes captured; 3/5 last pre-crash probes intersected traffic |
| Transition-clearance autoplay | Not present | Baseline transition clearance: 1/5 completed, avg terminal time 26.7s. Tightened transition clearance: 5/5 completed, avg terminal time 42.8s, 0 lane-change intersection probes |

## Remaining defects

- P0 ship blocker: Sunset Merge balance is far too easy and over-rewarding versus target; completion is about 99%, near misses around 35/run, cash around 998/run.
- P1 milestone blocker: Full clean-install tutorial completion matrix has not been manually or automatically exercised.
- P1 milestone blocker: Sim/live reconciliation is still not complete; tightened transition-clearance autoplay completed 5/5 live runs, but human-controlled validation and GameSim model ownership are still unresolved.
- P2 important polish: Remaining duplicate app-local rules need incremental migration/parity against `GameCore`.
- P2 important polish: Reward/monetization code remains present behind disabled flags and needs a real integration or removal before release.

## Risks

- The exit reachability model now validates path preservation across waves; future stricter tests should add multi-wave route proofs and bad-seed fixtures.
- The simulator launch logs include simulator/accessibility/audio warnings; no app crash was observed, but full manual flow validation is still needed.
- The app target still does not import `GameCore`; rules are duplicated between app and pure Swift systems.
- The debug overlay and debug direct-start defaults are intentionally debug-only and should remain off for normal production screenshots/play.

## Next highest-priority action

Capture one human-controlled iPhone 17e matrix and one Dynamic Island-class layout/input run with the tightened transition-clearance build. Then decide whether the successful horizon/padding model belongs in `GameCore`/`GameSim`, the live safety adapter, or both before retuning Sunset Merge.
