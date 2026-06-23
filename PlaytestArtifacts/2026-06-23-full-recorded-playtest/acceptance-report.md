# Acceptance Report

## Overall Result

PARTIAL.

The full recorded playtest has been scoped, the artifact structure has been created, automated validation passed, the iPhone 17e Los Angeles Starter Compact and Starter Bike slices have complete recorded evidence, failure/retry has recorded functional evidence, one iPhone 17 Pro Dynamic Island active sample has been captured, fresh-install tutorial completion has recorded evidence, City Select / Level Select progression has recorded evidence, Garage/vehicle browsing has partial recorded evidence, relaunch/save restoration has partial recorded evidence, pause/restart-after-pause has recorded negative evidence, completion/reward UI has debug-assisted result evidence, and New York/Miami start gates have start-screen-only evidence. The required all-city/all-device recorded active-play matrix is not complete.

## Commit Range

- Starting commit: `3c2431d`
- Ending commit: `aab6198`

## Counts

- Planned tests: 73
- Passed: 20
- Failed: 3
- Partial: 10
- Blocked: 0
- Invalid: 6
- Not tested: 40
- Valid active-input runs: 12
- Valid complete-evidence runs counted for LA Starter Compact: 5
- Valid complete-evidence runs counted for LA Starter Bike: 3

## Coverage

- Device coverage: iPhone 17e has two completed recorded active-run slices plus one recorded retry functional session; iPhone 17 Pro has one Dynamic Island active sample that failed the safe-area check; no physical hardware.
- City coverage: Los Angeles has completed Starter Compact and Starter Bike active-run slices for `la_01`; New York and Miami now have start-gate-only simulator evidence for `ny_01` and `mia_01`, but no active human-play runs, city progression, stress runs, or balance evidence.
- Vehicle coverage: Starter Compact and Starter Bike each have one completed iPhone 17e Los Angeles city slice. Garage browsing is partially recorded: selected Sunset Cruiser, Cars/Bikes tab switching, and locked Starter Bike messaging are proven, but alternate unlocked-vehicle selection is still unproven.
- Save/relaunch coverage: partial. App termination/relaunch, true Home-screen background/foreground, and active-gameplay background/foreground are recorded. Active-gameplay foreground returned to a terminal `CAPTURED` result with telemetry, but the sample had 0 lane changes and full main-menu Level 2 XP restoration remains unproven.
- Pause/restart-after-pause coverage: fail. Pre-game Settings opens and returns, but active gameplay exposes no app-level pause/resume/restart-after-pause path on iPhone 17e.
- Tutorial result: pass for recorded first-run onboarding completion without skip; launch-frame still capture is partial because the screenshot caught tutorial page 1 rather than the branded launch frame.
- Completion/reward result: partial. A debug-assisted first-escape scenario recorded the real result UI with `ESCAPED`, rewards, progression, Starter Bike unlock copy, and `USE BIKE`, but no real active-input completion has been recorded.
- First-minute result: fail/partial signal; six valid active Starter Compact LA01 runs all crashed before 10 seconds, and three complete-evidence Starter Bike LA01 runs all failed before completion.
- Control-feel result: partial; tap steering produced lane changes in twelve valid active-input runs, but other control modes are untested and the iPhone 17 Pro vehicle-specific sample is weakened by a vehicle identity mismatch.
- Difficulty-progression result: partial automated simulation plus recorded tutorial-to-LA and Level Select-to-LA attempts. Manual city progression is not validated because the fresh-install gameplay portion had 0 lane changes, the existing-save active attempt ended as traffic collision at 8.5s, and the follow-up existing-save attempt 03 recorded 0 lane changes and ended as police capture at 9.0s.
- Procedural-fairness result: partial; twelve active samples exist and the Dynamic Island and existing-save active progression samples include collision analysis, but broader levels/cities/vehicles are untested.
- City-differentiation result: partial visual start-gate signal only; active gameplay differences across New York and Miami are not tested.
- Performance result: partial; build and multiple recorded runs succeeded, but frame pacing was not measured. Dynamic Island HUD layout failed on iPhone 17 Pro.

## Issue Counts

- P0: 0 confirmed in this artifact set.
- P1: 2 confirmed in this artifact set.
- P2: 3 confirmed in this artifact set.
- P3: 0 confirmed in this artifact set.

## Artifact Paths

- Root: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/`
- Matrix: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/test-matrix.md`
- Findings: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/findings.md`
- Bugs: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/bugs.md`
- Balance: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/balance-observations.md`

## Exact Next Recommended Task

Capture a real active-input completion to replace the debug-assisted `FUNC-09` partial with full evidence. Also investigate and add an active-gameplay pause/resume/restart path, then re-run `FUNC-06` and `FUNC-07`. After that, capture a valid longer active Los Angeles progression attempt using a verified input method that telemetry confirms as lane-changing before relying on the run for active coverage. Separately investigate the Dynamic Island HUD overlap and iPhone 17 Pro vehicle identity mismatch before relying on more iPhone 17 Pro vehicle-specific rows.

## Remote Alignment

Current setup began from `main` aligned with `origin/main` at `3c2431d`. Production `main` has been pushed through `aab6198`.
