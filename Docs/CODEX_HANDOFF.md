# CODEX_HANDOFF.md

## Current Session Summary

Mac loop validation pulled commit `efe870f` (`Chase`) from `origin/main`, ran the required Mac-side checks, captured compact-simulator evidence, and identified the next MoneyMaker task. The iOS app builds, launches, records, and reaches gameplay, but `GameCore` validation is red and Sunset Merge balance is outside target.

## Files Changed This Session

- `Docs/CODEX_HANDOFF.md`
- `PlaytestArtifacts/mac-loop-2026-06-22-report.md`

## What Changed This Session

- Fast-forwarded this Mac checkout from `e9d1543` to `efe870f`.
- Ran `GameCore` tests, `GameSim`, and the Mac iOS build script.
- Fresh-installed the app on compact simulator `RiggedShoe-SE-Layout-Test` and recorded launch, tutorial, gameplay HUD, and early failure evidence.
- Wrote the next MoneyMaker prompt into `PlaytestArtifacts/mac-loop-2026-06-22-report.md`.

## Tests And Checks Run This Session

- `cd GameCore && swift test`
  - Failed: `testSimulationIsDeterministic` returned different `ChaseRunResult` values for two `la_01` / `starter_compact` / seed `12345` runs.
  - Failed: `testSunsetMergeTrafficStressCommitsReachableWaves` reported `136` impossible committed waves and `136` exit reachability failures.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`
  - Passed, but reported `99.0%` completion, far above the documented `40-60%` Level 1 target.
- `bash Tools/mac/verify_on_mac.sh`
  - Passed; iOS Simulator build succeeded.

## Simulation Results This Session

`la_01`, `starter_compact`, 10,000 runs, seed `12345`: average survival `43.3s`, median `43.0s`, exit appeared `99.3%`, exit reached `99.0%`, completed `99.0%`, near misses `34.4`, average max combo `32.1`, average cash `970`, average XP `381`, unfair collision estimate `0.1%`. GameSim recommendation: Level 1 may be too easy.

## Simulator Notes This Session

Local captures: `PlaytestArtifacts/mac-loop-2026-06-22/`. Fresh install shows the tutorial immediately and gameplay launches. Compact-layout issues observed: pressed tutorial button labels smear/clip, `ONE REVIVE` / `FREE REVIVE` appears as a first-minute mechanic, and the revive modal body overflows horizontally after a traffic collision.

## Known Issues After This Session

- `GameCore` determinism is broken.
- Sunset Merge traffic stress can commit unreachable exit-side waves.
- GameSim says Level 1 is too easy at `99.0%` completion, but the compact simulator passive run still crashed early, so sim/app feel need reconciliation after the core bug is fixed.
- Compact tutorial/result modal text needs layout cleanup.
- Confirm whether first-minute revive is intended; if not, remove or hide that copy/mechanic before expanding the first minute.

## Highest-Priority Next Task

MoneyMaker should fix `GameCore` determinism and Sunset Merge traffic reachability first, then retune Level 1 toward the `40-60%` completion target, and only then clean the compact tutorial/result copy. Use the full prompt in `PlaytestArtifacts/mac-loop-2026-06-22-report.md`.

## Previous Session Summary

Continued the Core Gameplay Lock / First Minute Fix milestone from the pasted production brief. Completed a source-level Phase 0 audit/checkpoint pass, added a PBX duplicate-ID regression gate, documented the first-minute architecture/plan, made scoped Phase 1 presentation fixes, added deterministic `GameCore` replay/Flow/lane-stale/pursuit primitives with broader terminal-state tests, added a pure traffic stress command, wired the first Sunset Merge escape to unlock/select the Starter Bike for 405 Afterburn, and moved the SpriteKit traffic/hazard path onto run-owned seeded RNG streams. This Windows environment still cannot run Git, Swift, Python scripts, Xcode, or iOS Simulator, so Mac/Swift validation remains required before claiming the milestone complete.

## Files Changed This Session

- `Docs/FIRST_MINUTE_LOCK.md`
- `Docs/TRAFFIC_DIRECTOR.md`
- `Docs/PLAYTEST_FIRST_MINUTE.md`
- `Docs/REPLAY_FORMAT.md`
- `Docs/KNOWN_BUGS.md`
- `Docs/CODEX_HANDOFF.md`
- `WINDOWS_DEVELOPMENT.md`
- `Tools/windows/check_pc_handoff.ps1`
- `scripts/validate_pbxproj_ids.py`
- `Traffic Getaway/GameViewController.swift`
- `Traffic Getaway/UIHelpers.swift`
- `Traffic Getaway/OnboardingScene.swift`
- `Traffic Getaway/GameScene.swift`
- `Traffic Getaway/TrafficPatternGenerator.swift`
- `Traffic Getaway/ResultsScene.swift`
- `GameCore/Sources/GameCore/SeededRNG.swift`
- `GameCore/Sources/GameCore/RunSimulation.swift`
- `GameCore/Sources/GameCore/ProgressionModel.swift`
- `GameCore/Tests/GameCoreTests/GameCoreTests.swift`
- `GameSim/Sources/GameSim/main.swift`

## What Changed This Session

- Read the pasted Core Gameplay Lock brief and audited the current repo, docs, project file, scene flow, app-local gameplay systems, `GameCore`, and `GameSim`.
- Verified the previously reported duplicate Xcode object ID is not present in the current project file. `ArcadeArt.swift in Sources` keeps `2A6D0E002C21A00100A00001`; the old Strip Signing Metadata duplicate is absent.
- Added `scripts/validate_pbxproj_ids.py` to detect duplicate PBX object definitions, with a built-in self-test fixture.
- Added a native PBX duplicate-ID check to `Tools/windows/check_pc_handoff.ps1`, so the check works here even while Python cannot run.
- Created `Docs/FIRST_MINUTE_LOCK.md` with the required architecture map, existing flow, defect list, module boundaries, file-level plan, risks, test plan, acceptance criteria, non-goals, and assumptions.
- Created `Docs/TRAFFIC_DIRECTOR.md`, `Docs/PLAYTEST_FIRST_MINUTE.md`, and `Docs/REPLAY_FORMAT.md`.
- Replaced the unexplained black initial `SKView` frame with a lightweight branded SpriteKit launch scene.
- Added `GameLayoutMetrics` for safe-content, top-HUD, playfield, and bottom-control frames.
- Updated onboarding's final exit lesson to teach the actual repeated lane movement: "Move right until you reach the ramp."
- Split gameplay HUD source layout into persistent left/center/right zones, with WANTED on the left and exit status on the right; combo feedback is now positioned below the persistent row.
- Clamped the pursuing police sprite presentation above the bottom unsafe region while keeping logical capture based on pursuit distance.
- Rebuilt results layout into fixed header, fixed actions, and a compressed central stats panel; result titles now distinguish ESCAPED, CAPTURED, CRASHED, and MISSED EXIT.
- Added `GameCore` fixed-step/replay primitives: `PlayerCommand`, `RunOutcome`, `RunConfigurationRecord`, `RunReplay`, `LaneStaleState`, `FlowState`, `PursuitPressureState`, `RunStateSnapshot`, and `FixedStepRunSimulation`.
- Added `SeededRNG.derivedStream(named:)` so cosmetic streams can be separated from gameplay streams.
- Added tests for derived RNG streams, lane-stale/Flow/pursuit behavior, and fixed-step replay hash matching.
- Added replayable non-input run events in `GameCore`: `RecordedRunEvent` and `RunEvent` for near misses, traffic collisions, and roadblock collisions.
- Extended fixed-step snapshots and hashes with near-miss count and highest combo.
- Added replay fixtures for passive capture, missed exit, traffic collision, multi-near-miss combo, and motorcycle interstitial-slot escape.
- Preserved replay decoding compatibility for older encoded replays without an `events` field.
- Added `GameSim --traffic-stress`, a pure traffic reachability stress mode that reports generated waves, recovery fallback waves, impossible committed waves, exit reachability failures, missing plans, top rejection reason, and top pattern.
- Added a `GameCore` Sunset Merge traffic stress test covering 250 seeds x 12 waves.
- Added pure progression coverage so first `la_01` completion unlocks the Starter Bike once.
- Updated app progression so the first Sunset Merge escape unlocks and selects the Starter Bike exactly once, making the existing Next Level path demonstrate motorcycle lane splitting in 405 Afterburn.
- Updated results copy so the primary unlock line calls out the Starter Bike and the primary next action becomes `USE BIKE` when that payoff is newly granted.
- Added app-local `AppSeededRNG` mirroring the pure `GameCore` RNG shape.
- Updated `Traffic Getaway/TrafficPatternGenerator.swift` so pattern selection, lane shuffling, open gaps, vehicle choices, wave offsets, and wave speed multipliers use seeded RNG instead of ambient Swift randomness.
- Updated `GameScene` run start to derive a run seed from level ID, vehicle ID, game mode, and save run count, then split traffic into `traffic-plan`, `traffic-spawn`, and `traffic-events` streams.
- Updated normal traffic spawning, roadblock lane choice, road-event selection/timing, traffic-jam lane ordering, construction block lanes, and VIP motorcade lanes to use the run-owned traffic streams.

## Tests And Checks Run This Session

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1`
  - Passed.
  - PBX object identifiers are unique: 97 definitions checked.
  - Git not found on PATH.
  - Swift not found on PATH.
  - Swift files found: 53.
  - Swift line endings look PC-safe.
  - Mac/Xcode build and simulator testing still required.
- Merge-marker scan:
  - No conflict markers found.
- Random-use scan:
  - Confirmed `GameCore` traffic generation uses seeded RNG.
  - Confirmed `Traffic Getaway/TrafficPatternGenerator.swift` no longer uses ambient `Int.random`, `CGFloat.random`, `randomElement`, or `shuffle` in committed wave generation.
  - Confirmed `GameScene` still has presentation-only `random` calls for scenery, camera shake, particles, speed-line recycling, and feedback effects.
- `swift --version`
  - Failed because Swift is not on PATH.
- `cd GameCore && swift test`
  - Failed because Swift is not on PATH.
  - Newly added replay tests still need actual execution on a Swift-capable machine.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345 --traffic-stress`
  - Failed because Swift is not on PATH.
- `python --version`
  - Failed because `python.exe` cannot be accessed by this system.
- `git status --short --branch`
  - Failed because Git is not on PATH.

## Simulation Results This Session

No `GameSim` simulation results are available. The command was attempted and failed because Swift is unavailable in this Windows environment.

## Known Issues After This Session

- Core Gameplay Lock is partially complete, not done.
- No Swift compile/test proof is available for the new `GameCore` files until Swift is installed or a Mac runs the tests.
- No Xcode build, Simulator launch, screenshots, or video proof are available from this Windows environment.
- App-local SpriteKit traffic and road-event hazards now use seeded streams, but the app still needs Swift/Xcode proof and eventual direct rendering of `GameCore` committed plans.
- Presentation-only random calls remain in `GameScene` for scenery, camera shake, particles, speed-line recycling, and feedback effects; they should stay isolated from gameplay authority.
- The results/HUD/tutorial fixes need real compact and Dynamic Island simulator screenshots.
- Phase 5 source wiring now unlocks/selects the Starter Bike after first Sunset Merge escape, but it still needs Swift/Xcode/Simulator validation.
- `git` remains unavailable, so no commit was created and no normal diff/status check was possible here.

## Highest-Priority Next Task

On a machine with Swift and Xcode, run `swift test` in `GameCore`, run the Sunset Merge `GameSim` command plus `--traffic-stress`, then run `Tools/mac/verify_on_mac.sh` and capture clean-launch/tutorial/HUD/results screenshots. After compile proof, validate that seeded app traffic still plays fairly in Sunset Merge, then continue the deeper bridge from SpriteKit-local traffic plans to rendered `GameCore` committed plans.

## Previous Session Summary

Performed a focused first-run onboarding and police-pressure source pass for Traffic Getaway. The Windows environment still cannot run Git, Swift, Xcode, or iOS Simulator tools, so this session implemented the source fixes and saved validation artifacts, but did not complete the required iPhone SE screenshot/video proof.

## Files Changed This Session

- `Traffic Getaway/OnboardingScene.swift`
- `Traffic Getaway/GameScene.swift`
- `PlaytestArtifacts/onboarding-police-validation-log.md`
- `PlaytestArtifacts/onboarding-police-validation-report.md`
- `Docs/CODEX_HANDOFF.md`

## What Changed This Session

- Reworked first-run onboarding into 6 quick arcade beats, starting with `QUICK CHASE SCHOOL` and `Traffic is slower. Read the gaps.`
- Made the first onboarding frame build visible road, lane markers, player car, two traffic cars, and a highlighted gap immediately from existing procedural SpriteKit assets.
- Added compact/safe-area-aware onboarding layout so `SKIP`, progress, title, subtitle, tutorial art, pager dots, and bottom controls are separated on iPhone SE-sized screens.
- Added a post-first-update/read-time guard to onboarding. The first step cannot advance during the same update cycle that first builds the visible tutorial frame, and then waits 3.1 seconds; later steps have shorter minimum read times.
- Added static iPhone SE layout numbers to the validation log/report. On 320x568, `SKIP` bounds are approximately `512...544` while the title bounds are approximately `469...495`; simulator proof is still required.
- Added passive police pressure in `GameScene`: time since last lane change now ramps police closing pressure after a short grace period.
- Passive driving now produces earlier red warning pulse pressure, floating police-pressure copy, and wanted-level escalation.
- Source-constant estimate for a fully passive starter run has visible passive warning around 4 seconds and minimum police gap around 13.8 seconds, before traffic/frame/world details.
- Real delayed lane changes can relieve a small amount of police pressure, while rapid lane changes do not repeatedly farm large police pushback.
- Existing distinct failure copy for traffic collision and police catch was preserved.

## Tests And Checks Run This Session

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1`
  - Passed required project file and line-ending checks.
  - Reported Git not found on PATH.
  - Reported Swift not found on PATH.
  - Swift checks skipped.
  - Mac/Xcode build and simulator testing still required.
- Merge-marker scan: no conflict markers found.
- Non-ASCII scan for `Traffic Getaway/OnboardingScene.swift` and `Traffic Getaway/GameScene.swift`: no non-ASCII found.
- `swift --version`: failed because Swift is not on PATH.
- `cd GameCore && swift test`: failed because Swift is not on PATH.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`: failed because Swift is not on PATH.
- `xcodebuild -list`: failed because Xcode tools are not available on this Windows machine.
- `xcrun simctl shutdown all`: failed because Xcode tools are not available on this Windows machine.
- `xcrun simctl list devices`: failed because Xcode tools are not available on this Windows machine.

## Simulation Results This Session

No simulation results are available. `GameSim` could not run because Swift is unavailable in this Windows environment.

## Validation Artifacts This Session

- `PlaytestArtifacts/onboarding-police-validation-log.md`
- `PlaytestArtifacts/onboarding-police-validation-report.md`

Required iPhone SE screenshots and videos were not captured because no iOS Simulator tooling is available here.

## Git Notes This Session

Git is not available on PATH, so normal `git status`, `git log -1 --oneline`, and `git diff --stat` commands could not run. Direct `.git` inspection initially showed `main` at `5b77c129685abfae083ca39acb14be15ca0259ed`. During the session, `.git/logs/HEAD` showed an external commit `y1` moved `main` to `176fd573003085e3189b87069993dec313abc9f9`. Codex did not make a commit.

## Known Issues After This Session

- The requested fresh-install iPhone SE screenshots and videos are still missing.
- Normal, passive, and rapid lane-changing playtests still need real simulator validation.
- Swift compile/tests and `GameSim` still require Swift to be installed or added to PATH.
- Mac/Xcode build validation still requires a Mac with Xcode.
- Results screen bottom buttons received only a static source-position check; simulator tapability still needs confirmation.

## Highest-Priority Next Task

On a Mac with Xcode installed, run `Tools/mac/verify_on_mac.sh`, fresh-install Traffic Getaway on the smallest available iPhone SE simulator, and capture the required after-fix onboarding and police-pressure screenshots/video. Verify that the tutorial is visible immediately, `QUICK CHASE SCHOOL` and `SKIP` do not crowd, passive driving visibly raises police pressure or causes a police catch, normal lane changing remains playable, rapid lane changing does not break controls, and results buttons are tappable.

## Last Session Summary

Implemented Traffic Getaway Art Pass 3B: Three-City World Identity Correction. The previous six-world theme catalog was replaced with exactly three city identities, story progression was corrected to Los Angeles -> New York -> Miami, and city select was upgraded from compact tabs to three identity cards.

## Files Changed

- `Docs/ART_PASS_STATUS.md`
- `Docs/ASSET_AUDIT.md`
- `Docs/CODEX_HANDOFF.md`
- `Docs/BALANCE_TARGETS.md`
- `Docs/KNOWN_BUGS.md`
- `Docs/NEXT_STEPS.md`
- `Docs/PLAYTEST_NOTES.md`
- `AGENTS.md`
- `README.md`
- `WINDOWS_DEVELOPMENT.md`
- `GameCore/Sources/GameCore/GameModels.swift`
- `GameCore/Tests/GameCoreTests/GameCoreTests.swift`
- `GameSim/Sources/GameSim/main.swift`
- `Traffic Getaway/ArcadeArt.swift`
- `Traffic Getaway/AchievementManager.swift`
- `Traffic Getaway/ArtGalleryScene.swift`
- `Traffic Getaway/CarData.swift`
- `Traffic Getaway/DailyChallengeManager.swift`
- `Traffic Getaway/GameScene.swift`
- `Traffic Getaway/LevelSelectScene.swift`
- `Traffic Getaway/LevelData.swift`
- `Traffic Getaway/MainMenuScene.swift`
- `Traffic Getaway/MissionManager.swift`
- `Traffic Getaway/ResultsScene.swift`
- `Traffic Getaway/WorldTheme.swift`

## What Changed

- Rebuilt `WorldTheme.swift` around exactly three city themes: Los Angeles, New York, and Miami.
- Added theme fields for short description, lane style, shoulder style, skyline style, prop set, signage style, traffic color set, police flavor, lighting mood, exit sign style, difficulty flavor, and unlock requirement.
- Removed the old six-world level mapping so each story level now uses its own `RunCity` theme.
- Updated New York so it no longer inherits Los Angeles/Sunlit California colors.
- Updated Miami with tropical pastel/aqua/coral styling while keeping the shared low-detail arcade asset language.
- Routed legacy city palette calls through `WorldThemeCatalog` so old call sites use the city-specific theme data.
- Added city-colored police specs for cruisers, SUVs, and police motorcycles while keeping the existing procedural silhouettes.
- Updated gameplay road layout, skyline/backdrop treatment, road markings, props, HUD city code, pre-run overlay, game-over overlay, exits, and city transition banners.
- Updated level select into a three-city picker that opens on the next playable city.
- Replaced compact city tabs with city cards showing city name, short identity text, difficulty flavor, road preview, palette strip, and select/locked state.
- Reordered app and `GameCore` level catalogs so `la_01` / Sunset Merge is the first playable route.
- Moved the starter 42-second exit target to Sunset Merge and made New York unlock after the Los Angeles routes.
- Updated `RunCity.rank`, reach-city missions, daily challenge copy, achievements, and GameSim defaults for LA -> New York -> Miami progression.
- Updated main menu skyline and next-chase copy to reflect the next playable city.
- Updated results to show city and selected vehicle.
- Updated in-game startup defaults so the first story scene initializes on the selected/current level's city instead of briefly defaulting to New York.
- Updated the in-game settings/pause overlay to show the active city and use the active city accent.
- Updated the results screen backdrop, panel/buttons, and next-city unlock summary to use the run city's theme.
- Updated the developer art gallery city theme page.
- Updated `Docs/ART_PASS_STATUS.md` with the required Three-City World Identity Pass audit.

## Three-City Theme Notes

- Los Angeles: bright Sunlit California palette, warm asphalt, cream/yellow markings, ocean/turquoise accents, palms, low-rise coastal backdrop, green freeway exits, highway patrol flavor.
- New York: cool gray/navy/steel palette, taxi-yellow accents, tighter urban expressway feel, vertical block skyline, building/steam props, heavier urban police flavor, expressway/tunnel exits.
- Miami: aqua/coral/pink pastel palette, bright coastal road treatment, hotel/neon/palm props, sportier tropical traffic colors, flashy police accents, beach-style exits.

## Tests Run

Ran the Windows handoff checker:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1
```

Result:

- Required project files were present.
- 52 Swift files were found.
- Swift line endings look PC-safe.
- Git was not found on PATH.
- Swift was not found on PATH.
- Swift checks were skipped.
- Mac/Xcode build and simulator testing are still required.

Additional checks:

- `swift --version` failed because Swift is not on PATH.
- `git --version` failed because Git is not on PATH.
- `cd GameCore && swift test` was attempted and failed because Swift is not on PATH.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345` was attempted and failed because Swift is not on PATH.
- `cd GameSim && swift run GameSim --level all --vehicle starter_compact --runs 10000 --seed 12345` was attempted and failed because Swift is not on PATH.
- Merge-marker scan found no conflict markers.
- Removed six-world enum/raw-value scan found no old six-world source identifiers.
- Old six-world display-name scan found no remaining hits after this handoff rewrite.
- Non-ASCII scan across `Traffic Getaway` and `Docs` found no hits.
- Stale starter-route command/copy scan found no remaining hits.
- City-select source check confirms `LevelSelectScene` builds city cards from the three-theme catalog with road previews, palette strips, and locked/select state.
- UI source check confirms in-game settings shows the active city, results use `resultWorldTheme`, and newly crossed city unlocks are named in the results summary.
- Source evidence confirms `la_01` is first in both app and `GameCore` catalogs, and `RunCity.rank` maps Los Angeles to 1, New York to 2, Miami to 3.

## Simulation Results

No simulation results are available. `GameSim` was attempted for `la_01` and for all starter-car levels, but both commands failed because Swift is not available on this Windows desktop.

## Known Issues

- iOS build and Simulator visual validation still require Mac/Xcode.
- Swift is not available on this Windows desktop, so `GameCore` tests and `GameSim` were not run.
- Git is not available on this Windows desktop, so normal status/diff workflows were unavailable.
- City props and skyline elements are still procedural placeholder shapes, not final authored bitmap assets.
- Police variants are city-colored but still share base procedural silhouettes.
- Store, main-menu settings, onboarding, and some deeper overlays still need a broader visual cleanup pass.
- This pass changed story order and starter balance, so `GameCore` tests and `GameSim` remain required as soon as Swift is available.

## Highest-Priority Next Task

On Mac, run `Tools/mac/verify_on_mac.sh`, launch the app in iOS Simulator, and inspect Los Angeles, New York, and Miami gameplay from the city picker. Verify city-card layout, road/lane readability, traffic/police contrast, prop placement outside lanes, exit event clarity, results layout, and frame-rate/node-count health.

## Suggested Next Prompt

Read `Docs/CODEX_HANDOFF.md` and `Docs/ART_PASS_STATUS.md`. On Mac, run `Tools/mac/verify_on_mac.sh`, launch Traffic Getaway in Simulator, test the three city-select cards, Los Angeles, New York, and Miami gameplay plus one endless transition, and report readability, layout, and performance issues.
