# Mac Loop Validation Report - 2026-06-22

Validated commit `efe870f` (`Chase`) after pulling `origin/main` onto the Mac.

## Build And Test Results

- `cd GameCore && swift test`: failed.
  - `testSimulationIsDeterministic` produced different `ChaseRunResult` values for two runs with level `la_01`, vehicle `starter_compact`, seed `12345`.
  - `testSunsetMergeTrafficStressCommitsReachableWaves` found `136` impossible committed waves and `136` exit reachability failures.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`: passed.
  - Completion: `99.0%`.
  - Exit appeared: `99.3%`.
  - Exit reached: `99.0%`.
  - Average survival: `43.3s`; median `43.0s`.
  - Unfair collision estimate: `0.1%`.
  - Recommendation: Level 1 may be too easy; increase traffic only after 25s.
- `bash Tools/mac/verify_on_mac.sh`: passed.

## Simulator Evidence

Local captures were saved but not intended for Git because the video is large:

- `PlaytestArtifacts/mac-loop-2026-06-22/01-launch.png`
- `PlaytestArtifacts/mac-loop-2026-06-22/02-gameplay-hud.png`
- `PlaytestArtifacts/mac-loop-2026-06-22/03-after-passive-run.png`
- `PlaytestArtifacts/mac-loop-2026-06-22/traffic-getaway-validation.mp4`

Observed on compact `RiggedShoe-SE-Layout-Test` simulator (`iPhone14,6`):

- Fresh install opens directly to the six-step tutorial. First frame is visible, not black.
- Tutorial content is generally readable and advances through gap reading, lane movement, police pressure, near misses, revive, and exit movement.
- Several pressed or interactive button labels smear/clip on compact layout, including `TRY IT`, `READ`, and `NEXT`.
- Onboarding introduces `ONE REVIVE` and the result screen offers `FREE REVIVE`; confirm this is an intended first-minute mechanic before keeping it.
- Gameplay HUD is readable, but WANTED pressure appeared high almost immediately in the first playable run.
- Passive early run ended in a traffic-collision revive modal. The modal body text overflows horizontally past the panel edge.

## Next MoneyMaker Prompt

Traffic Getaway Mac validation pulled commit `efe870f` (`Chase`) and found the next blocker. Do not add menus, currencies, or new systems. Keep rules in `GameCore` when practical.

Fix the current `GameCore` and first-minute validation failures:

1. Make `ChaseSimulator.simulate(level:vehicle:seed:)` deterministic again. `swift test` currently fails because two calls with `la_01`, `starter_compact`, seed `12345` produce different results.
2. Fix Sunset Merge traffic safety generation so `testSunsetMergeTrafficStressCommitsReachableWaves` reports zero impossible committed waves and zero exit reachability failures. It currently reports `136` for both.
3. Re-run `cd GameCore && swift test`.
4. Re-run `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`.
5. Retune only after the safety/determinism bug is fixed. Current GameSim says Sunset Merge completion is `99.0%`, far above the `40-60%` target in `Docs/BALANCE_TARGETS.md`.
6. After the core is green, clean compact UI copy/layout without adding systems: fix smeared tutorial button labels, fix the revive modal body overflow, and either verify or remove the first-minute `ONE REVIVE`/`FREE REVIVE` mechanic if it was not explicitly intended.
7. Update `Docs/CODEX_HANDOFF.md` with tests, simulation results, known issues, and the next recommended task.

Acceptance checks for the pass:

- `GameCore` tests pass.
- Sunset Merge traffic stress has zero impossible committed waves and zero exit route failures.
- `GameSim` completion for `la_01` starter compact moves back toward the documented `40-60%` target without making the first 25 seconds unfair.
- `Tools/mac/verify_on_mac.sh` still passes after any app-layer changes.
