# Traffic Getaway First Minute Lock

## Milestone Overview

Core Gameplay Lock / First Minute Fix is the production milestone for making the opening chase readable, fair, deterministic where practical, and rewarding before adding more cities, economy, multiplayer, or visual scope.

The player-facing loop to protect is:

Launch -> first-run onboarding -> city/level select -> Sunset Merge -> live pursuit -> exit -> escaped, crashed, captured, or missed-exit results -> rewards -> progression unlock -> 405 Afterburn.

## Current Architecture

- Xcode project: `Traffic Getaway.xcodeproj`.
- Shared scheme: `Traffic Getaway`.
- App target: `Traffic Getaway`.
- Workspace wrapper: `Traffic Getaway.xcodeproj/project.xcworkspace`.
- Deployment target: iOS 17.0 in `Traffic Getaway.xcodeproj/project.pbxproj`.
- Swift language version: Swift 5.0 for the iOS target, Swift tools 5.9 for `GameCore` and `GameSim`.
- App entry point: `AppDelegate.swift`, `SceneDelegate.swift`, and `GameViewController.swift`.
- Presentation layer: SpriteKit scenes in `Traffic Getaway/*.swift`.
- Pure rules layer: `GameCore` Swift package.
- Headless balance runner: `GameSim` Swift package.

The intended architecture is already documented in `Docs/DESIGN.md`: `GameCore` owns rules, while the iOS app owns rendering, input, haptics, audio, menus, StoreKit, analytics, and platform validation. The iOS app still contains app-local copies of several gameplay systems, so production adoption needs to be incremental.

## Scene And Flow Map

- Initial scene selection: `GameViewController.presentInitialSceneIfNeeded()`.
- First-run tutorial: `OnboardingScene.swift`.
- Main menu: `MainMenuScene.swift`.
- City and level selection: `LevelSelectScene.swift`.
- Gameplay: `GameScene.swift`.
- Results and rewards: `ResultsScene.swift`, backed by `ProgressionManager.swift` and `SaveManager.swift`.
- Garage and vehicle selection: `GarageScene.swift`, `CarData.swift`.
- Settings: `SettingsScene.swift` and in-game overlay code in `GameScene.swift`.

## Gameplay System Map

- Traffic spawning: app-local `TrafficPatternGenerator.swift` and `GameScene.spawnTrafficWave()`.
- Traffic safety checks: app-local `TrafficSafetyAnalyzer.swift`; pure equivalent in `GameCore/Sources/GameCore/TrafficSafety.swift`.
- Lane and slot rules: app-local `LaneManager.swift`; pure equivalent in `GameCore/Sources/GameCore/LaneModel.swift`.
- Player vehicle model: app-local `CarData.swift`; pure equivalent in `GameCore/Sources/GameCore/GameModels.swift`.
- Police pursuit: `GameScene.positionPolice()`, `passivePolicePressure`, and related warning helpers.
- Collision: `GameScene.checkCollisions()` and hitbox helpers; pure equivalent in `GameCore/Sources/GameCore/CollisionModel.swift`.
- Near misses: `GameScene.checkNearMiss(for:)`; pure helper in `GameCore/Sources/GameCore/CollisionModel.swift`.
- Combo: `GameScene.advanceCombo()`, `updateCombo(deltaTime:)`, and score multiplier logic.
- Wanted level: `GameScene.updateWantedLevel()`.
- Exit/ramp: `GameScene.updateStoryChase(deltaTime:)`, `activateExit(side:isEmergency:)`, `buildExitRamp(side:isEmergency:)`, `rebuildExitGuidance(side:)`, `completeLevelEscape()`, and `missExit()`.
- Results: `ResultsScene.swift`.
- Save/progression storage: `SaveManager.swift`, `ProgressionManager.swift`.
- Level definitions: app-local `LevelData.swift`; pure equivalent in `GameCore/Sources/GameCore/GameModels.swift`.
- Vehicle definitions: app-local `CarData.swift`; pure equivalent in `GameCore/Sources/GameCore/GameModels.swift`.
- Existing deterministic simulation: `GameCore/Sources/GameCore/ChaseSimulator.swift`.
- Existing tests: `GameCore/Tests/GameCoreTests/GameCoreTests.swift`.
- Debug flags: `AppConfig.swift`, `ScreenshotMode.swift`, and debug labels/heatmaps in `GameScene.swift`.

## Verified Defects And Current Evidence

- P0 Xcode duplicate object ID: locally repaired in the current project file. `2A6D0E002C21A00100A00001` is now only `ArcadeArt.swift in Sources`. The prior script-phase duplicate is not present.
- P1 black first frame: `GameViewController.loadView()` starts the `SKView` on pure black before initial scene selection.
- P2 tutorial safe-area conflict: `OnboardingScene` has a safe-area-aware pass from a prior session, but still needs simulator proof on notch/Dynamic Island devices.
- P2 unclear exit tutorial input: current onboarding says to survive and hit the ramp; it teaches swipe/tap movement but does not explicitly teach repeated movement toward the exit ramp.
- P1 HUD overlap: `GameScene` places score, wanted, combo, distance, and cash in one top panel; exit countdown is separate world/playfield text.
- P2 pursuing police clipping: `positionPolice()` maps logical pressure directly to `playerY - policeGap`, so the sprite can approach the unsafe bottom edge on compact devices.
- P1 results collision: `ResultsScene` uses a single fixed vertical stack and fixed bottom buttons; reward/progression/unlock text can collide on compact displays.

## Proposed Module Boundaries

- Keep SpriteKit nodes, layout, safe areas, haptics, audio, StoreKit, analytics, and scene transitions in `Traffic Getaway`.
- Keep deterministic gameplay models, RNG, lane topology, traffic planning, reachability, scoring, replay records, and progression helpers in `GameCore`.
- Keep command-line seed stress and tuning summaries in `GameSim`.
- During this milestone, prefer low-risk app-local adoption over a full iOS target dependency reshuffle unless Mac/Xcode validation is available.

## Phase Checklist

- Phase 0: project audit, PBX duplicate-ID regression check, Windows handoff gate, Mac build handoff.
- Phase 1: first frame, safe-area layout, tutorial copy/input, HUD zones, police visual placement, results layout.
- Phase 2: fixed-step/pure simulation interfaces, seeded authoritative randomness, explicit run configuration, input commands, replay.
- Phase 3: lane-stale, Flow, near-miss reliability, combo determinism, pursuit pressure, distinct terminal states.
- Phase 4: authored reachable exit set piece, exit lead time, ramp transition, missed-exit clarity.
- Phase 5: first escape progression payoff, motorcycle unlock/persistence, 405 Afterburn demonstration.

## File-Level Change Plan

- `scripts/validate_pbxproj_ids.py`: detect duplicate PBX object definitions.
- `Tools/windows/check_pc_handoff.ps1`: run a native PBX duplicate-ID check during Windows handoff.
- `Traffic Getaway/GameViewController.swift`: replace unexplained black initial view with a branded loading/launch frame before scene presentation.
- `Traffic Getaway/UIHelpers.swift` or a new app-local layout file: centralize SpriteKit safe-area layout metrics.
- `Traffic Getaway/OnboardingScene.swift`: ensure title/skip/header stay safe and align exit instruction with repeated lane movement.
- `Traffic Getaway/GameScene.swift`: split HUD zones, move transient combo/near-miss feedback out of the persistent top row, clamp police presentation above the bottom unsafe region, expose debug HUD bounds.
- `Traffic Getaway/ResultsScene.swift`: rebuild fixed header/action regions with scrollable middle content or compact rows.
- `GameCore/Sources/GameCore`: add deterministic run records, replay state, traffic director/reachability, lane-stale, Flow, and pursuit pressure in focused files.
- `GameCore/Tests/GameCoreTests`: add deterministic RNG, replay, reachability, flow/pursuit, exit, and progression tests.
- `GameSim/Sources/GameSim/main.swift`: add seeded stress outputs for wave rejection/fallback/impossible counts.
- `Docs/TRAFFIC_DIRECTOR.md`, `Docs/PLAYTEST_FIRST_MINUTE.md`, `Docs/REPLAY_FORMAT.md`, `Docs/CODEX_HANDOFF.md`: document implementation, validation, and remaining risks.

## Initial Tuning Values To Centralize

- Sunset Merge exit target: 42 seconds, 14-second window.
- Lane count: 12 lane centers, 23 slots.
- Starter car movement: one lane per tap or normal swipe, wider movement for fast swipes.
- Starter bike differentiator: split/interstitial slots are legal.
- Passive police pressure: warning begins after sustained inactivity and grows over roughly four seconds.
- Traffic safety: generated waves must retain reachable car and motorcycle slots, with protected exit lanes during active exits.

Exact final tuning values must be measured with `GameCore` tests, `GameSim`, and Simulator playtests before being treated as locked.

## Test Plan

- Windows handoff: `powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1`.
- PBX validator: `python scripts/validate_pbxproj_ids.py "Traffic Getaway.xcodeproj/project.pbxproj"` and `python scripts/validate_pbxproj_ids.py --self-test` when Python is available.
- GameCore: `cd GameCore && swift test` when Swift is available.
- GameSim: `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345` when Swift is available.
- Mac/Xcode: `Tools/mac/verify_on_mac.sh`.
- Simulator manual matrix: clean install, passive driver, skilled driver, collision, missed exit, extreme HUD pressure, first escape progression, replay.

## Acceptance Criteria

- Fresh project parses and builds without manual Xcode project repair.
- PBX object identifiers are unique and covered by a regression check.
- First in-app frame is intentional, not unexplained black.
- Tutorial header and skip control respect safe areas.
- Tutorial movement copy matches actual input.
- Wanted and exit information stay readable under pressure.
- Transient combo/near-miss feedback does not overlap persistent HUD.
- Police vehicle presentation is intentional above the bottom unsafe area.
- Results content is legible, bottom actions are fixed and reachable, and Next Level still launches 405 Afterburn.
- Same configuration, seed, and input log reproduce the same authoritative outcome.
- Traffic and exit waves are validated for reachability or replaced by deterministic fallback.
- Passive play predictably raises pursuit risk; skilled movement creates measurable advantage.
- Escaped, crashed, captured, and missed-exit outcomes remain distinct.
- First Sunset Merge escape grants one meaningful persisted progression payoff.

## Explicit Non-Goals

- New York/Miami content expansion.
- Multiplayer, leaderboards, online services, live operations.
- Storefront, ad SDK, or monetization redesign.
- Full Garage redesign or large vehicle roster expansion.
- Full art-style replacement or full audio production pass.
- Replacing SpriteKit.
- Broad codebase rewrite.

## Risks

- Windows environment lacks Git, Swift, Python, Xcode, and Simulator on PATH, so source edits need Mac validation before release claims.
- The iOS app and `GameCore` still duplicate core data; drift is possible until adoption is complete.
- `GameScene` is large, so presentation edits must stay scoped and avoid accidental gameplay regressions.
- App-local traffic currently uses unseeded Swift randomness; full determinism requires more than `GameCore` coverage.
- Results and HUD fixes need device screenshots because source-only geometry is not enough proof.

## Assumptions

- The first production calibration target is Los Angeles `la_01` / Sunset Merge.
- `405 Afterburn` remains the immediate Next Level target after Sunset Merge.
- The starter motorcycle remains the intended first meaningful vehicle payoff unless product docs are updated.
- On this Windows machine, Mac/Xcode proof will be documented as unavailable rather than claimed.
