# Balance Observations

## Current Status

Six valid active-input LA01 Starter Compact manual runs are available, five with complete video/screenshot/telemetry evidence and one supplemental active run missing the result screenshot. Three complete-evidence active-input LA01 Starter Bike runs are also available, plus one supplemental failure/retry Bike session, one Dynamic Island-class active sample, and one existing-save active progression sample. Fresh-install tutorial-to-run, existing-save attempt 03, active-gameplay background/foreground, and pause/settings probe samples exist but are invalid for balance because each recorded 0 lane changes. Configured start-gate videos/screenshots exist for every remaining Starter Compact level, but they are start-screen-only and not balance evidence. A debug-assisted first-escape completion/reward result exists but is also not balance evidence because it is synthetic result UI, not a real active-input completion. Garage/vehicle browsing and relaunch restoration evidence exists, but it is not gameplay balance evidence; it shows the current save at `$443`, selected Sunset Cruiser, high score 741, and locked Starter Bike at `NEED $107 MORE`. No global balance conclusion should be drawn until the required city/vehicle matrix is captured, but the opening LA01 slices now show strong first-level completion concerns.

## Manual LA01 Starter Compact Slice

- Level/vehicle: `la_01` / Starter Compact.
- Device: iPhone 17e simulator.
- Runs: 6 active-input runs, 5 complete-evidence runs counted for the LA Starter Compact requirement.
- Result: 0/6 completed, traffic collision in all 6.
- Avg terminal time: 7.6s; median terminal time: 7.5s.
- Active input: 15 lane changes, 27 lane-change probes, 0 autoplay decisions.
- Near misses/cash: average 1.2 near misses and 18 cash.
- Fairness signal: collision analysis present in 6/6, 4 unsafe-path probes, 1 last pre-crash probe intersected traffic.
- Read: this is a strong P1 signal that active LA01 simulator play is currently collapsing much earlier than the intended first-minute target.

## Prior Reference Signals

- Previous GameSim evidence reports `la_01` / `starter_compact` around 99.1% completion with high near misses and high cash, suggesting Level 1 may be too easy and over-rewarding.
- Previous active-traffic diagnostic evidence is too punitive and is explicitly not a balance source.
- Previous debug autoplay evidence is useful for repeatability but is not a proxy for human difficulty.
- Previous ungated active manual iPhone 17e attempt is invalid for balance conclusions because only 1/5 runs had active input.
- Current LA01 active slices are valid evidence for first-level concerns, but they still cover only one level, one device, and one control mode.

## Manual LA01 Starter Bike Slice

- Level/vehicle: `la_01` / Starter Bike.
- Device: iPhone 17e simulator.
- Runs: 3 complete-evidence active-input runs counted for the LA Starter Bike requirement.
- Result: 0/3 completed; terminal reasons were traffic collision twice and roadblock once.
- Avg terminal time: 27.5s; median terminal time: 21.1s.
- Active input: 13 lane changes, 43 lane-change probes, 0 autoplay decisions.
- Near misses/cash: average 5.3 near misses and 51 cash.
- Fairness signal: collision analysis present in 3/3, 0 lane-change intersection probes, 0 unsafe-path probes in the counted set.
- Read: Starter Bike survives longer than Starter Compact and can reach exit countdown, but this slice still failed to complete LA01 in 3/3 complete-evidence samples.

## Supplemental Failure/Retry Session

- Level/vehicle: `la_01` / Starter Bike.
- Result: traffic collision at 26.2s, 8 near misses, 4 lane changes, 0 autoplay decisions.
- Functional read: `RETRY LEVEL` returned to the Los Angeles Starter Bike start screen.
- Balance use: supplemental only; this validates retry flow and adds one active bike sample, but it is not part of the three-run LA Starter Bike requirement.

## Supplemental Dynamic Island Sample

- Device: iPhone 17 Pro simulator, Dynamic Island-class.
- Level/requested vehicle: `la_01`; requested Starter Bike, telemetry reported Starter Compact, visible UI/result label showed Sunset Cruiser.
- Result: traffic collision at 23.7s, 5 near misses, 2 lane changes, 49 cash, wanted level 3, 0 autoplay decisions.
- Functional read: active input was recorded and controls remained usable, but the Dynamic Island overlaps the top HUD.
- Balance use: supplemental only. This is valid for safe-area/device evidence, but the vehicle identity mismatch means it should not drive vehicle-specific balance conclusions.

## Fresh-Install Tutorial/Progression Sample

- Device: iPhone 17e simulator.
- Flow: clean reinstall, tutorial pages 1-5 completed without skip, automatic transition into `la_01`.
- Result: police capture at 9.0s, 0 near misses, 0 lane changes, 12 cash, wanted level 3, 0 autoplay decisions.
- Functional read: valid first-run tutorial and progression-flow evidence.
- Balance use: invalid. The gameplay portion had 0 active lane changes and should not be used for active-run, fairness, or city-progression conclusions.

## Supplemental Existing-Save Progression Sample

- Device: iPhone 17e simulator.
- Flow: result screen to Level Select, selected Sunset Merge, played active `la_01` sample.
- Result: traffic collision at 8.5s, 3 near misses, 3 lane changes, 19 telemetry cash, wanted level 3, 0 autoplay decisions.
- Functional read: valid City Select / Level Select evidence and valid active-input navigation-to-gameplay sample.
- Balance use: supplemental only. It reinforces early LA01 failure pressure but is one short existing-save sample, not a complete city progression attempt.

## Invalid Existing-Save Progression Attempt 03

- Device: iPhone 17e simulator.
- Flow: result screen retry into `la_01`, then coordinate taps after the start gate.
- Result: police capture at 9.0s, 0 near misses, 0 lane changes, 12 telemetry cash, wanted level 3, 0 autoplay decisions.
- Functional read: result-screen rewards/progress were visible, including Level 2 progress, but the attempted input path did not produce telemetry-confirmed active steering.
- Balance use: invalid. Retain as evidence of an attempted progression run, but do not use for active-run, fairness, or balance conclusions.

## Invalid Pause/Settings Probe Session 01

- Device: iPhone 17e simulator.
- Flow: start-gated `la_01`; recorded start-screen Settings, Settings Back return, active HUD, and result screen.
- Result: police capture at 9.0s, 0 near misses, 0 lane changes, 12 telemetry cash, wanted level 3, 0 autoplay decisions.
- Functional read: pre-game Settings works, but active gameplay exposes no app-level pause/resume/restart-after-pause path.
- Balance use: invalid. Retain as functional pause/restart evidence only; do not use for active-run, fairness, or balance conclusions.

## Debug-Assisted Completion/Reward Session 01

- Device: iPhone 17e simulator.
- Flow: debug-only `first_escape_starter_bike` scenario opened the real `ResultsScene` after processing a synthetic completed `la_01` run.
- Result UI: `ESCAPED`, `$423`, `213 XP`, `Level 1 -> 2`, `Starter Bike unlocked: split lanes`, and primary `USE BIKE`.
- Functional read: valid completion/reward/unlock presentation evidence.
- Balance use: invalid. It is not a real active-input completion, has no raw run telemetry, and should not inform completion rate, reward tuning, or fairness conclusions.

## City And Level Start-Gate Reference

- Scope: every non-`la_01` Starter Compact level has configured start-gate video/screenshot evidence under `videos/city-*/*starter-compact_start-gate.mp4` and `screenshots/city-*/*starter-compact_start-gate.png`.
- Functional read: these prove the debug direct-start path can present Los Angeles, New York, and Miami start screens on iPhone 17e with `waitForStartTap`.
- Limitation: the visible start screen shows city and vehicle, not the exact level name, so level-specific proof depends on the corresponding debug-default probe log.
- Balance use: invalid. No start tap, active input, raw run telemetry, result screen, traffic sample, or terminal outcome was captured.

## Simulation Comparison

- Default GameSim previously reported LA01 Starter Compact completion around 99% with high near misses and high cash.
- Recorded iPhone 17e active Starter Compact play now shows 0/6 completion and sub-10-second traffic terminals.
- Recorded iPhone 17e active Starter Bike play shows 0/3 completion in the counted complete-evidence set, with one run reaching the exit countdown at 50.2s before traffic collision.
- Recorded iPhone 17 Pro Dynamic Island active play shows 0/1 completion in the supplemental sample, with a traffic collision at 23.7s and a vehicle identity mismatch.
- Interpretation: sim/live/manual difficulty are not reconciled. Do not tune from simulation alone.

## Required Next Evidence

- Start-gated active iPhone 17e runs for every city.
- Additional start-gated Dynamic Island-class coverage after the top-HUD overlap and vehicle identity mismatch are understood.
- Starter Compact and Starter Bike runs with complete video, telemetry, summary, and observations.
- City progression attempts that show whether rewards/unlocks are understandable and whether grinding is required.

## Recommendations

Do not tune rewards, traffic density, city difficulty, or progression from this scaffold alone. Capture the required active-run evidence first.
