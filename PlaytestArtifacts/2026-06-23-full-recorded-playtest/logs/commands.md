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
- xcrun simctl io <device> screenshot for start and result checkpoints
- Post-run cleanup after `--leave-app-running`: terminate app, clear debug defaults, then verify iPhone 17e preferences; output saved to `build-validation/post-run-debug-defaults-check.log` and confirmed `[]`
- python3 scripts/summarize_run_telemetry.py for Starter Compact runs 01-06 and counted Starter Bike runs 03-05
