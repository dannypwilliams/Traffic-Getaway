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
