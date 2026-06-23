# Command Log

Date: 2026-06-23T15:45:33Z
Branch: main
Commit: 3c2431d

## Commands Captured
- python3 -m py_compile scripts/capture_live_telemetry.py scripts/summarize_run_telemetry.py scripts/capture_progression_payoff.py scripts/validate_use_bike_tap_through.py
- python3 scripts/validate_pbxproj_ids.py Traffic Getaway.xcodeproj/project.pbxproj
- git diff --check
- swift test (GameCore)
- swift run GameSim --level all --vehicle starter_compact --runs 1000 --seed 12345
- swift run GameSim --level all --vehicle starter_bike --runs 1000 --seed 12345
- bash Tools/mac/verify_on_mac.sh
- xcrun simctl io <device> recordVideo for LA01 Starter Compact runs 01-06
- xcrun simctl io <device> recordVideo for LA01 Starter Bike runs 03-05
- python3 -u scripts/capture_live_telemetry.py --manual --wait-for-start-tap for runs 01-03
- python3 -u scripts/capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running for runs 04-06
- python3 -u scripts/capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running --vehicle starter_bike for Bike runs 03-05
- python3 -u scripts/capture_live_telemetry.py --manual --wait-for-start-tap --leave-app-running for failure/retry session 01
- xcrun simctl io <device> screenshot for start and result checkpoints
- xcrun simctl io <device> screenshot for failure/retry session start, result, and retry-return checkpoints
- Post-run cleanup after `--leave-app-running`: terminate app, clear debug defaults, then verify iPhone 17e preferences; output saved to `build-validation/post-run-debug-defaults-check.log` and confirmed `[]`
- python3 scripts/summarize_run_telemetry.py for Starter Compact runs 01-06, counted Starter Bike runs 03-05, and failure/retry session 01
- xcrun simctl io <iPhone 17 Pro> recordVideo for Dynamic Island runs 01-02
- python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --runs 1 --level la_01 --vehicle starter_compact --manual --wait-for-start-tap --leave-app-running --output-dir PlaytestArtifacts/2026-06-23-full-recorded-playtest/telemetry/raw --timeout 120
- python3 -u scripts/capture_live_telemetry.py --device 90D3514A-BDE2-412C-8238-8ECC17BD86B6 --runs 1 --level la_01 --vehicle starter_bike --manual --wait-for-start-tap --leave-app-running --output-dir PlaytestArtifacts/2026-06-23-full-recorded-playtest/telemetry/raw --timeout 120
- xcrun simctl io <iPhone 17 Pro> screenshot for Dynamic Island start and result checkpoints
- python3 scripts/summarize_run_telemetry.py for Dynamic Island run 01 and run 02
- Post-run cleanup after Dynamic Island `--leave-app-running`: terminate app, clear debug defaults, then verify iPhone 17 Pro preferences; output confirmed `[]`
- Fresh-install tutorial/progression setup: terminate app, uninstall `com.danielwilliams.TrafficGetaway`, install the verified Debug simulator app on iPhone 17e, then launch from a reset save state
- xcrun simctl io <iPhone 17e> recordVideo for `2026-06-23_iphone17e_fresh-install_tutorial-la-progression_attempt01.mp4`
- Computer Use clicks through onboarding pages 1-5, completing lane-change, police-pressure, near-miss, and exit-ramp practice without using skip
- xcrun simctl io <iPhone 17e> screenshot for tutorial pages, completed practice states, and the result screen
- python3 scripts/summarize_run_telemetry.py for fresh-install tutorial/progression attempt 01
- avconvert --preset Preset960x540 compressed the original 107 MB simulator recording to a 42 MB evidence video before commit
- xcrun simctl io <iPhone 17e> recordVideo for `2026-06-23_iphone17e_existing-save_level-select-la01_active-progression_attempt02.mp4`
- Computer Use selected `LEVEL SELECT`, selected `1. SUNSET MERGE`, tapped `Tap to Start`, and used coordinate taps during gameplay for active lane changes
- xcrun simctl io <iPhone 17e> screenshot for City Select, start screen, and result screen checkpoints in existing-save active progression attempt 02
- python3 scripts/summarize_run_telemetry.py for existing-save active progression attempt 02
- xcrun simctl io <iPhone 17e> recordVideo for `2026-06-23_iphone17e_existing-save_la01_active-progression_attempt03.mp4`
- Computer Use tapped `RETRY LEVEL`, tapped `Tap to Start`, and OS-level coordinate taps were attempted during gameplay for existing-save active progression attempt 03
- xcrun simctl io <iPhone 17e> screenshot for start and result checkpoints in existing-save active progression attempt 03
- python3 scripts/summarize_run_telemetry.py for existing-save active progression attempt 03; telemetry recorded 0 lane changes and terminal `police_caught` at 9.0s, so the run was rejected from active/progression coverage
- xcrun simctl io <iPhone 17e> recordVideo for `2026-06-23_iphone17e_existing-save_garage-vehicle-selection_session01.mp4`
- Computer Use tapped `GARAGE` from the result screen, switched between Cars and Bikes tabs, observed selected `SUNSET CRUISER`, observed locked `STARTER BIKE` with `NEED $107 MORE`, then tapped `BACK` to return to the main menu
- xcrun simctl io <iPhone 17e> screenshot for Garage current-car, locked-bike, and menu-return checkpoints in vehicle-selection session 01
- xcrun simctl io <iPhone 17e> recordVideo for `2026-06-23_iphone17e_existing-save_relaunch-restoration_session01.mp4`
- xcrun simctl terminate / launch for `com.danielwilliams.TrafficGetaway` to test existing-save relaunch restoration from the visible save state
- xcrun simctl io <iPhone 17e> screenshot for relaunch restoration before-terminate and after-relaunch start-screen checkpoints
- Debug defaults cleanup attempted and logged at `build-validation/relaunch-restoration-debug-defaults-cleanup.log`; this first cleanup occurred while the app was alive, so cached debug defaults reappeared after launch
- Debug defaults cleanup after termination logged at `build-validation/relaunch-restoration-debug-defaults-cleanup-after-terminate.log`
- xcrun simctl io <iPhone 17e> recordVideo for clean relaunch cycle `2026-06-23_iphone17e_existing-save_relaunch-restoration-clean_session02.mp4`
- xcrun simctl io <iPhone 17e> screenshot for clean relaunch before-terminate and after-relaunch checkpoints
- Final post-capture debug-default cleanup logged at `build-validation/relaunch-restoration-debug-defaults-final-clean-after-capture.log`
