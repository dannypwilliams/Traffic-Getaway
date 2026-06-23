# Test Matrix

Statuses: `pass`, `fail`, `partial`, `blocked`, `not tested`, `invalid`.

## Summary Counts

- Planned tests: 73
- Passed: 17
- Failed: 0
- Partial: 1
- Blocked: 0
- Invalid: 1
- Not tested: 55
- Valid active-input runs in this artifact set: 10
- Valid complete-evidence runs counted for LA Starter Compact requirement: 5
- Valid complete-evidence runs counted for LA Starter Bike requirement: 3

## Preparation And Automated Validation

| ID | Test | Status | Evidence | Notes |
|---|---|---|---|---|
| PREP-01 | Inspect current repo state, commit, tools, docs, levels, vehicles, devices, and known issues | pass | `metadata.json`, `README.md`, `logs/commands.md` | Inventory recorded for commit `3c2431d`, levels, vehicles, controls, devices, and known limitations. |
| PREP-02 | Build current debug/playtest configuration | pass | `build-validation/verify-on-mac.log` | iOS Simulator Debug build succeeded. |
| PREP-03 | Verify no unintended debug defaults alter gameplay | pass | `build-validation/install-and-debug-defaults-check.log` | Verified installed build on iPhone 17e and iPhone 17 Pro has `debug defaults=[]`. |
| AUTO-01 | Python compilation checks | pass | `build-validation/python-py-compile.log` | Empty log with zero exit means compile check passed. |
| AUTO-02 | PBX project ID validation | pass | `build-validation/pbxproj-validation.log` | 99 unique PBX object identifiers. |
| AUTO-03 | `git diff --check` | pass | `build-validation/git-diff-check.log` | Empty log with zero exit means whitespace check passed. |
| AUTO-04 | GameCore tests | pass | `build-validation/gamecore-swift-test.log` | 22 tests, 0 failures. |
| AUTO-05 | Mac/iOS Simulator build verification | pass | `build-validation/verify-on-mac.log` | Build succeeded. |
| AUTO-06 | Telemetry summary regeneration | pass | `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md`, `telemetry/summaries/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_runs03-05-summary.md`, `telemetry/summaries/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01-summary.md` | Summaries generated from raw telemetry. |
| AUTO-07 | Representative GameSim runs for all levels with starter vehicle | pass | `build-validation/gamesim-all-levels-starter-compact.log` | 15 levels x 1,000 runs. |
| AUTO-08 | Representative GameSim runs for all levels with Starter Bike | pass | `build-validation/gamesim-all-levels-starter-bike.log` | 15 levels x 1,000 runs. |
| AUTO-09 | Traffic stress/procedural fairness validation | pass | `build-validation/gamecore-swift-test.log`, `build-validation/gamesim-all-levels-starter-compact.log`, `build-validation/gamesim-all-levels-starter-bike.log` | Automated stress/fairness signals exist; manual fairness remains unproven. |
| AUTO-10 | Save/load, tutorial, progression, and unlock validation | partial | `build-validation/gamecore-swift-test.log` | Unit tests cover progression pieces; full tutorial/save/restore manual coverage remains open. |

## Required Manual Functional Tests

| ID | Test | Device | Status | Video | Telemetry | Notes |
|---|---|---|---|---|---|---|
| FUNC-01 | Launch screen screenshot/video | iPhone 17e | not tested | | | |
| FUNC-02 | Tutorial instructions | iPhone 17e | not tested | | | |
| FUNC-03 | Tutorial completion without skip | iPhone 17e | not tested | | | |
| FUNC-04 | City/progression screen | iPhone 17e | not tested | | | |
| FUNC-05 | Vehicle selection | iPhone 17e | not tested | | | |
| FUNC-06 | Pause and resume | iPhone 17e | not tested | | | |
| FUNC-07 | Restart after pause | iPhone 17e | not tested | | | |
| FUNC-08 | Failure screen and retry | iPhone 17e | pass | `videos/progression/2026-06-23_iphone17e_la01_starter-bike_swipe-tap_failure-retry_session01.mp4` | `telemetry/raw/01-2026-06-23_09-42-21-la_01-starter_bike-16090129143462938849.jsonl` | Failure screen captured, `RETRY LEVEL` tapped, and retry returned to the Los Angeles Starter Bike start screen. |
| FUNC-09 | Completion screen and reward screen | iPhone 17e | not tested | | | |
| FUNC-10 | Background and relaunch restoration | iPhone 17e | not tested | | | |
| FUNC-11 | Existing-save progression restoration | iPhone 17e | not tested | | | |
| FUNC-12 | Dynamic Island safe-area/control obstruction check | iPhone 17 Pro | not tested | | | |

## Control Mode Coverage

| ID | Control Mode | Device | Level | Vehicle | Status | Evidence |
|---|---|---|---|---|---|---|
| CTRL-01 | SWIPE + TAP | iPhone 17e | la_01 | starter_compact | pass | `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run01.mp4`, `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run02.mp4`, `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run04.mp4`, `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run05.mp4`, `videos/city-1/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_run06.mp4`, `telemetry/summaries/2026-06-23_iphone17e_la01_starter-compact_swipe-tap_runs01-06-summary.md` |
| CTRL-02 | SWIPE ONLY | iPhone 17e | la_01 | starter_compact | not tested | |
| CTRL-03 | TAP ONLY | iPhone 17e | la_01 | starter_compact | not tested | |
| CTRL-04 | SWIPE + TAP | iPhone 17 Pro | la_01 | starter_compact | not tested | |
| CTRL-05 | SWIPE ONLY | iPhone 17 Pro | la_01 | starter_compact | not tested | |
| CTRL-06 | TAP ONLY | iPhone 17 Pro | la_01 | starter_compact | not tested | |

## City Run Requirements

Each city requires at least five valid active-input starter-vehicle runs, three valid active-input Starter Bike runs, one complete recorded progression attempt through the city, and one stress run.

| ID | City | Requirement | Device | Status | Valid Runs | Evidence |
|---|---|---|---|---|---:|---|
| LA-STARTER | Los Angeles | Five valid active-input Starter Compact runs | iPhone 17e | pass | 5 | Runs 01, 02, 04, 05, and 06 have video, start/result screenshots, telemetry, summary, and observations. Run 03 is supplemental active evidence but is missing result screenshot. |
| LA-BIKE | Los Angeles | Three valid active-input Starter Bike runs | iPhone 17e | pass | 3 | Runs 03, 04, and 05 have video, start/result screenshots, telemetry, summary, and observations. Run 02 has telemetry/result evidence but is rejected from the complete-evidence count because the start screenshot and video are missing. |
| LA-PROGRESSION | Los Angeles | Complete recorded progression attempt | iPhone 17e | not tested | 0 | |
| LA-STRESS | Los Angeles | Deliberate difficult stress run | iPhone 17e | not tested | 0 | |
| NY-STARTER | New York | Five valid active-input Starter Compact runs | iPhone 17e | not tested | 0 | |
| NY-BIKE | New York | Three valid active-input Starter Bike runs | iPhone 17e | not tested | 0 | |
| NY-PROGRESSION | New York | Complete recorded progression attempt | iPhone 17e | not tested | 0 | |
| NY-STRESS | New York | Deliberate difficult stress run | iPhone 17e | not tested | 0 | |
| MIA-STARTER | Miami | Five valid active-input Starter Compact runs | iPhone 17e | not tested | 0 | |
| MIA-BIKE | Miami | Three valid active-input Starter Bike runs | iPhone 17e | not tested | 0 | |
| MIA-PROGRESSION | Miami | Complete recorded progression attempt | iPhone 17e | not tested | 0 | |
| MIA-STRESS | Miami | Deliberate difficult stress run | iPhone 17e | not tested | 0 | |

## Every Playable Level

| Level | City | Stage | Starter Compact Status | Starter Bike Status | Evidence |
|---|---|---|---|---|---|
| la_01 Sunset Merge | Los Angeles | early | pass | pass | Starter Compact requirement complete for iPhone 17e: five complete-evidence active runs plus one supplemental active run. Starter Bike requirement complete for iPhone 17e: three complete-evidence active runs. |
| la_02 405 Afterburn | Los Angeles | middle | not tested | not tested | |
| la_03 Valley Cut | Los Angeles | middle | not tested | not tested | |
| la_04 Freeway Riot | Los Angeles | late | not tested | not tested | |
| la_05 Last Exit West | Los Angeles | late | not tested | not tested | |
| ny_01 Brooklyn Warmup | New York | early | not tested | not tested | |
| ny_02 FDR Squeeze | New York | middle | not tested | not tested | |
| ny_03 Midtown Split | New York | middle | not tested | not tested | |
| ny_04 Queensboro Heat | New York | late | not tested | not tested | |
| ny_05 Tunnel Break | New York | late | not tested | not tested | |
| mia_01 Ocean Drive Run | Miami | early | not tested | not tested | |
| mia_02 Neon Causeway | Miami | middle | not tested | not tested | |
| mia_03 Thunder Strip | Miami | middle | not tested | not tested | |
| mia_04 Vice Lockdown | Miami | late | not tested | not tested | |
| mia_05 Crown Escape | Miami | late | not tested | not tested | |

## Invalid Runs

Starter Compact Run 03 is valid active telemetry/video evidence but is excluded from the five complete-evidence Starter Compact count because the result screenshot is missing.

Starter Bike Run 02 is rejected from the complete-evidence Starter Bike count because only telemetry and a result screenshot remain in the artifact directory; the start screenshot and video are missing. The valid complete-evidence Starter Bike set is Runs 03, 04, and 05.
