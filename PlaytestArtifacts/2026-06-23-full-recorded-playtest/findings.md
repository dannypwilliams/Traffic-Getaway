# Findings

## Executive Summary

Status: `partial`.

The full recorded playtest has been scoped and scaffolded. Automated validation passed, the iPhone 17e Los Angeles Starter Compact slice has five complete-evidence active-input runs plus one supplemental active run, the Los Angeles Starter Bike slice has three complete-evidence active-input runs, failure/retry now has a recorded functional session, one iPhone 17 Pro Dynamic Island active sample has been captured, fresh-install tutorial completion has recorded evidence, City Select / Level Select progression has recorded evidence, Garage/vehicle browsing has partial recorded evidence, relaunch/save restoration has partial recorded evidence, pause/restart-after-pause has a recorded negative probe, completion/reward UI now has debug-assisted result evidence, and every non-`la_01` Starter Compact level now has configured start-gate-only video/screenshots. All six Starter Compact active runs ended in traffic collisions before 10 seconds. All three counted Starter Bike runs also failed before completion, although one reached the exit countdown at 50.2s. The iPhone 17 Pro sample failed the Dynamic Island safe-area check and exposed a vehicle identity mismatch. The fresh-install tutorial-to-run sample ended as passive police capture with 0 lane changes. The existing-save Level Select-to-LA sample recorded active input but still ended at 8.5s. A follow-up existing-save LA01 attempt and the pause/settings probe produced video, screenshots, and telemetry, but each recorded 0 lane changes and terminal police capture at 9.0s, so they are invalid for active/progression/balance coverage. The required all-city, all-level, multi-device recorded manual matrix is still mostly incomplete, so no release-readiness conclusion is possible yet.

## Control Feel

Partial. Tap steering produced lane changes in twelve valid active-input runs, with 37 lane-change events across the counted Starter Compact/Starter Bike slices, the retry functional session, the Dynamic Island active sample, and the existing-save progression sample. This proves the default `SWIPE + TAP` path can accept tap input on both sampled simulator classes, but it does not validate precision, consistency, frame-rate behavior, or every materially different control mode. The iPhone 17 Pro sample is partial for vehicle-specific coverage because the requested, visible, and telemetry vehicle identities did not agree.

## First-Minute Experience

Fail/partial signal. Six valid active LA01 Starter Compact runs started from the explicit start tap and all ended in traffic collisions before 10 seconds, far before exit activation. Three complete-evidence LA01 Starter Bike runs averaged 27.5s and 0/3 completion; Run 04 reached exit countdown but crashed before escape. The compact result is logged as `FTG-P1-001`; the bike failure set is logged as `FTG-P1-002`.

## Difficulty Progression

Partial. Automated all-level simulations were captured for Starter Compact and Starter Bike. Manual difficulty progression is not validated yet. The recorded LA01 Starter Compact and Starter Bike slices suggest opening live play is much harsher than default GameSim predicts.

## Procedural Fairness

Partial. The counted LA01 runs captured collision analysis, active traffic context, lane-change probes, and terminal reasons. Starter Compact aggregate telemetry shows 6/6 collision analyses, 27 lane-change probes, and 4 unsafe-path probes. Starter Bike counted telemetry shows 3/3 collision analyses, 43 lane-change probes, 0 lane-change intersection probes, and terminal reasons `traffic` twice and `roadblock` once. The failure/retry functional session, Dynamic Island active sample, and existing-save progression sample each add one more active collision-analysis sample. Broader fairness is still unproven.

## City Differentiation

Partial visual/configured start-gate evidence only. Every non-`la_01` Starter Compact level now has a configured start-gate recording, and representative Los Angeles, New York, and Miami screenshots visibly display distinct city labels/palettes. The start screen does not display the exact level name, so level-specific proof comes from the debug-default probe logs rather than visible UI. Active city gameplay identity is still untested: traffic behavior, road blockages, police pressure, decision strategy, difficulty ramp, and completion/reward differences must still be evaluated across recorded active city runs.

## Progression And Rewards

Partial. Starter Bike Runs 04 and 05 showed XP/progress advancement on failure screens, including Level 5 to 6 progress. The failure/retry session proved `RETRY LEVEL` returns to the ready start state after failure. A fresh-install tutorial-to-run recording proves onboarding can complete without skip and transition into Los Angeles gameplay, but its gameplay portion had 0 lane changes and ended as police capture at 9.0s. Existing-save Level Select-to-LA evidence proves the city/progression screen is reachable and the failed active run can level the player from Level 1 to 2, but it does not complete Sunset Merge. Existing-save attempt 03 produced an additional result-screen XP/progress sample at Level 2, but telemetry recorded 0 lane changes, so it is invalid for active progression coverage. No full city progression attempt has been completed. Previous reference evidence shows first Sunset Merge escape can unlock Starter Bike and `USE BIKE` can start 405 Afterburn, but the full progression pass remains open.

Garage/vehicle browsing is partially recorded from the existing-save result state. The Garage displayed selected Sunset Cruiser, Cars/Bikes tab switching, locked Starter Bike copy, cash `$443`, and return to the main menu. This supports progression understandability around vehicle availability, but it does not prove selecting an alternate unlocked vehicle.

Completion/reward UI is partially recorded through a debug-assisted first-escape result scenario. The real result screen showed `ESCAPED`, `$423`, `213 XP`, `Level 1 -> 2`, `Starter Bike unlocked: split lanes`, and primary `USE BIKE`. This proves the completion/reward/unlock presentation path, but it does not prove a real active-input completion and should not be used for balance conclusions.

Relaunch/save restoration is partially recorded. After app termination/relaunch and after Home-screen background/foreground, the app restored high score 741, cash `$443`, selected Sunset Cruiser, and Los Angeles start context. Active-gameplay Home/foreground was also recorded and returned to a terminal `CAPTURED` result with telemetry. The active-gameplay lifecycle sample had 0 lane changes, so it is not active-run or balance evidence, and relaunch did not restore to the richer main-menu view with Level 2 XP visible.

Pause and restart-after-pause coverage failed on iPhone 17e. Pre-game Settings opened and returned to the start screen, but active gameplay exposed only HUD/status labels and no app-level Pause, Resume, Settings, Back, or Restart control. The result screen did expose Retry Level, Garage, Level Select, and Menu after terminal police capture, but that is not a pause/restart flow. This is logged as `FTG-P2-003`.

## Performance

Partial. The Mac/iOS Simulator build passed and twelve valid active-input recordings succeeded while telemetry and video capture were active. No frame pacing or latency instrumentation has been reviewed yet. The required Dynamic Island-class sample revealed top-HUD clipping under the Dynamic Island.

## Release Readiness

Not release-ready. Required human-play evidence, all-city active coverage, complete progression coverage, and final matrix documentation are incomplete. Tutorial completion, completion/reward UI, and configured start gates for the remaining Starter Compact levels now have recorded evidence, but the current LA01 Starter Compact and Starter Bike evidence raises P1 first-level completion and first-minute concerns, the iPhone 17 Pro Dynamic Island sample adds a P2 top-HUD safe-area defect, and the iPhone 17e pause probe adds a P2 missing active pause/restart-after-pause defect.
