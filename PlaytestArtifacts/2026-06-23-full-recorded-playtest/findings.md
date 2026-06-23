# Findings

## Executive Summary

Status: `partial`.

The full recorded playtest has been scoped and scaffolded. Automated validation passed, the iPhone 17e Los Angeles Starter Compact slice has five complete-evidence active-input runs plus one supplemental active run, the Los Angeles Starter Bike slice has three complete-evidence active-input runs, failure/retry now has a recorded functional session, one iPhone 17 Pro Dynamic Island active sample has been captured, fresh-install tutorial completion has recorded evidence, and City Select / Level Select progression has recorded evidence. All six Starter Compact active runs ended in traffic collisions before 10 seconds. All three counted Starter Bike runs also failed before completion, although one reached the exit countdown at 50.2s. The iPhone 17 Pro sample failed the Dynamic Island safe-area check and exposed a vehicle identity mismatch. The fresh-install tutorial-to-run sample ended as passive police capture with 0 lane changes. The existing-save Level Select-to-LA sample recorded active input but still ended at 8.5s. A follow-up existing-save LA01 attempt produced video, screenshots, and telemetry, but telemetry recorded 0 lane changes and terminal police capture at 9.0s, so it is invalid for active/progression coverage. The required all-city, all-level, multi-device recorded manual matrix is still mostly incomplete, so no release-readiness conclusion is possible yet.

## Control Feel

Partial. Tap steering produced lane changes in twelve valid active-input runs, with 37 lane-change events across the counted Starter Compact/Starter Bike slices, the retry functional session, the Dynamic Island active sample, and the existing-save progression sample. This proves the default `SWIPE + TAP` path can accept tap input on both sampled simulator classes, but it does not validate precision, consistency, frame-rate behavior, or every materially different control mode. The iPhone 17 Pro sample is partial for vehicle-specific coverage because the requested, visible, and telemetry vehicle identities did not agree.

## First-Minute Experience

Fail/partial signal. Six valid active LA01 Starter Compact runs started from the explicit start tap and all ended in traffic collisions before 10 seconds, far before exit activation. Three complete-evidence LA01 Starter Bike runs averaged 27.5s and 0/3 completion; Run 04 reached exit countdown but crashed before escape. The compact result is logged as `FTG-P1-001`; the bike failure set is logged as `FTG-P1-002`.

## Difficulty Progression

Partial. Automated all-level simulations were captured for Starter Compact and Starter Bike. Manual difficulty progression is not validated yet. The recorded LA01 Starter Compact and Starter Bike slices suggest opening live play is much harsher than default GameSim predicts.

## Procedural Fairness

Partial. The counted LA01 runs captured collision analysis, active traffic context, lane-change probes, and terminal reasons. Starter Compact aggregate telemetry shows 6/6 collision analyses, 27 lane-change probes, and 4 unsafe-path probes. Starter Bike counted telemetry shows 3/3 collision analyses, 43 lane-change probes, 0 lane-change intersection probes, and terminal reasons `traffic` twice and `roadblock` once. The failure/retry functional session, Dynamic Island active sample, and existing-save progression sample each add one more active collision-analysis sample. Broader fairness is still unproven.

## City Differentiation

Not tested through recorded active play. The content inventory confirms three cities and 15 levels, but gameplay identity must still be evaluated across recorded city runs.

## Progression And Rewards

Partial. Starter Bike Runs 04 and 05 showed XP/progress advancement on failure screens, including Level 5 to 6 progress. The failure/retry session proved `RETRY LEVEL` returns to the ready start state after failure. A fresh-install tutorial-to-run recording proves onboarding can complete without skip and transition into Los Angeles gameplay, but its gameplay portion had 0 lane changes and ended as police capture at 9.0s. Existing-save Level Select-to-LA evidence proves the city/progression screen is reachable and the failed active run can level the player from Level 1 to 2, but it does not complete Sunset Merge. Existing-save attempt 03 produced an additional result-screen XP/progress sample at Level 2, but telemetry recorded 0 lane changes, so it is invalid for active progression coverage. No full city progression attempt has been completed. Previous reference evidence shows first Sunset Merge escape can unlock Starter Bike and `USE BIKE` can start 405 Afterburn, but the full progression pass remains open.

## Performance

Partial. The Mac/iOS Simulator build passed and twelve valid active-input recordings succeeded while telemetry and video capture were active. No frame pacing or latency instrumentation has been reviewed yet. The required Dynamic Island-class sample revealed top-HUD clipping under the Dynamic Island.

## Release Readiness

Not release-ready. Required human-play evidence, all-city coverage, complete progression coverage, and final matrix documentation are incomplete. Tutorial completion now has recorded evidence, but the current LA01 Starter Compact and Starter Bike evidence raises P1 first-level completion and first-minute concerns, and the iPhone 17 Pro Dynamic Island sample adds a P2 top-HUD safe-area defect.
