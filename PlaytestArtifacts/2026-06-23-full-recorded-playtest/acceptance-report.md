# Acceptance Report

## Overall Result

PARTIAL.

The full recorded playtest has been scoped, the artifact structure has been created, automated validation passed, the iPhone 17e Los Angeles Starter Compact and Starter Bike slices have complete recorded evidence, failure/retry has recorded functional evidence, one iPhone 17 Pro Dynamic Island active sample has been captured, and fresh-install tutorial completion has recorded evidence. The required all-city/all-device recorded active-play matrix is not complete.

## Commit Range

- Starting commit: `3c2431d`
- Ending commit: pending

## Counts

- Planned tests: 73
- Passed: 19
- Failed: 1
- Partial: 4
- Blocked: 0
- Invalid: 3
- Not tested: 49
- Valid active-input runs: 11
- Valid complete-evidence runs counted for LA Starter Compact: 5
- Valid complete-evidence runs counted for LA Starter Bike: 3

## Coverage

- Device coverage: iPhone 17e has two completed recorded active-run slices plus one recorded retry functional session; iPhone 17 Pro has one Dynamic Island active sample that failed the safe-area check; no physical hardware.
- City coverage: Los Angeles has completed Starter Compact and Starter Bike active-run slices for `la_01`; New York and Miami have automated simulation only.
- Vehicle coverage: Starter Compact and Starter Bike each have one completed iPhone 17e Los Angeles city slice.
- Tutorial result: pass for recorded first-run onboarding completion without skip; launch-frame still capture is partial because the screenshot caught tutorial page 1 rather than the branded launch frame.
- First-minute result: fail/partial signal; six valid active Starter Compact LA01 runs all crashed before 10 seconds, and three complete-evidence Starter Bike LA01 runs all failed before completion.
- Control-feel result: partial; tap steering produced lane changes in eleven valid active-input runs, but other control modes are untested and the iPhone 17 Pro vehicle-specific sample is weakened by a vehicle identity mismatch.
- Difficulty-progression result: partial automated simulation plus one fresh-install tutorial-to-LA attempt; manual city progression is not validated because the gameplay portion had 0 lane changes and ended as police capture at 9.0s.
- Procedural-fairness result: partial; eleven active samples exist and the Dynamic Island active sample includes collision analysis, but broader levels/cities/vehicles are untested.
- City-differentiation result: not tested.
- Performance result: partial; build and multiple recorded runs succeeded, but frame pacing was not measured. Dynamic Island HUD layout failed on iPhone 17 Pro.

## Issue Counts

- P0: 0 confirmed in this artifact set.
- P1: 2 confirmed in this artifact set.
- P2: 2 confirmed in this artifact set.
- P3: 0 confirmed in this artifact set.

## Artifact Paths

- Root: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/`
- Matrix: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/test-matrix.md`
- Findings: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/findings.md`
- Bugs: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/bugs.md`
- Balance: `PlaytestArtifacts/2026-06-23-full-recorded-playtest/balance-observations.md`

## Exact Next Recommended Task

Capture a true active Los Angeles progression attempt next, using an input path that reliably records lane changes after the tutorial-to-run transition. Separately investigate the Dynamic Island HUD overlap and iPhone 17 Pro vehicle identity mismatch before relying on more iPhone 17 Pro vehicle-specific rows.

## Remote Alignment

Current setup began from `main` aligned with `origin/main` at `3c2431d`. Any new scaffold/documentation changes still need to be committed and pushed.
