# CODEX_HANDOFF.md

## Current Session Summary

Performed a focused first-run onboarding and police-pressure source pass for Traffic Getaway. The Windows environment still cannot run Git, Swift, Xcode, or iOS Simulator tools, so this session implemented the source fixes and saved validation artifacts, but did not complete the required iPhone SE screenshot/video proof.

## Files Changed This Session

- `Traffic Getaway/OnboardingScene.swift`
- `Traffic Getaway/GameScene.swift`
- `PlaytestArtifacts/onboarding-police-validation-log.md`
- `PlaytestArtifacts/onboarding-police-validation-report.md`
- `Docs/CODEX_HANDOFF.md`

## What Changed This Session

- Reworked first-run onboarding into 6 quick arcade beats, starting with `QUICK CHASE SCHOOL` and `Traffic is slower. Read the gaps.`
- Made the first onboarding frame build visible road, lane markers, player car, two traffic cars, and a highlighted gap immediately from existing procedural SpriteKit assets.
- Added compact/safe-area-aware onboarding layout so `SKIP`, progress, title, subtitle, tutorial art, pager dots, and bottom controls are separated on iPhone SE-sized screens.
- Added a post-first-update/read-time guard to onboarding. The first step cannot advance during the same update cycle that first builds the visible tutorial frame, and then waits 3.1 seconds; later steps have shorter minimum read times.
- Added static iPhone SE layout numbers to the validation log/report. On 320x568, `SKIP` bounds are approximately `512...544` while the title bounds are approximately `469...495`; simulator proof is still required.
- Added passive police pressure in `GameScene`: time since last lane change now ramps police closing pressure after a short grace period.
- Passive driving now produces earlier red warning pulse pressure, floating police-pressure copy, and wanted-level escalation.
- Source-constant estimate for a fully passive starter run has visible passive warning around 4 seconds and minimum police gap around 13.8 seconds, before traffic/frame/world details.
- Real delayed lane changes can relieve a small amount of police pressure, while rapid lane changes do not repeatedly farm large police pushback.
- Existing distinct failure copy for traffic collision and police catch was preserved.

## Tests And Checks Run This Session

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1`
  - Passed required project file and line-ending checks.
  - Reported Git not found on PATH.
  - Reported Swift not found on PATH.
  - Swift checks skipped.
  - Mac/Xcode build and simulator testing still required.
- Merge-marker scan: no conflict markers found.
- Non-ASCII scan for `Traffic Getaway/OnboardingScene.swift` and `Traffic Getaway/GameScene.swift`: no non-ASCII found.
- `swift --version`: failed because Swift is not on PATH.
- `cd GameCore && swift test`: failed because Swift is not on PATH.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345`: failed because Swift is not on PATH.
- `xcodebuild -list`: failed because Xcode tools are not available on this Windows machine.
- `xcrun simctl shutdown all`: failed because Xcode tools are not available on this Windows machine.
- `xcrun simctl list devices`: failed because Xcode tools are not available on this Windows machine.

## Simulation Results This Session

No simulation results are available. `GameSim` could not run because Swift is unavailable in this Windows environment.

## Validation Artifacts This Session

- `PlaytestArtifacts/onboarding-police-validation-log.md`
- `PlaytestArtifacts/onboarding-police-validation-report.md`

Required iPhone SE screenshots and videos were not captured because no iOS Simulator tooling is available here.

## Git Notes This Session

Git is not available on PATH, so normal `git status`, `git log -1 --oneline`, and `git diff --stat` commands could not run. Direct `.git` inspection initially showed `main` at `5b77c129685abfae083ca39acb14be15ca0259ed`. During the session, `.git/logs/HEAD` showed an external commit `y1` moved `main` to `176fd573003085e3189b87069993dec313abc9f9`. Codex did not make a commit.

## Known Issues After This Session

- The requested fresh-install iPhone SE screenshots and videos are still missing.
- Normal, passive, and rapid lane-changing playtests still need real simulator validation.
- Swift compile/tests and `GameSim` still require Swift to be installed or added to PATH.
- Mac/Xcode build validation still requires a Mac with Xcode.
- Results screen bottom buttons received only a static source-position check; simulator tapability still needs confirmation.

## Highest-Priority Next Task

On a Mac with Xcode installed, run `Tools/mac/verify_on_mac.sh`, fresh-install Traffic Getaway on the smallest available iPhone SE simulator, and capture the required after-fix onboarding and police-pressure screenshots/video. Verify that the tutorial is visible immediately, `QUICK CHASE SCHOOL` and `SKIP` do not crowd, passive driving visibly raises police pressure or causes a police catch, normal lane changing remains playable, rapid lane changing does not break controls, and results buttons are tappable.

## Last Session Summary

Implemented Traffic Getaway Art Pass 3B: Three-City World Identity Correction. The previous six-world theme catalog was replaced with exactly three city identities, story progression was corrected to Los Angeles -> New York -> Miami, and city select was upgraded from compact tabs to three identity cards.

## Files Changed

- `Docs/ART_PASS_STATUS.md`
- `Docs/ASSET_AUDIT.md`
- `Docs/CODEX_HANDOFF.md`
- `Docs/BALANCE_TARGETS.md`
- `Docs/KNOWN_BUGS.md`
- `Docs/NEXT_STEPS.md`
- `Docs/PLAYTEST_NOTES.md`
- `AGENTS.md`
- `README.md`
- `WINDOWS_DEVELOPMENT.md`
- `GameCore/Sources/GameCore/GameModels.swift`
- `GameCore/Tests/GameCoreTests/GameCoreTests.swift`
- `GameSim/Sources/GameSim/main.swift`
- `Traffic Getaway/ArcadeArt.swift`
- `Traffic Getaway/AchievementManager.swift`
- `Traffic Getaway/ArtGalleryScene.swift`
- `Traffic Getaway/CarData.swift`
- `Traffic Getaway/DailyChallengeManager.swift`
- `Traffic Getaway/GameScene.swift`
- `Traffic Getaway/LevelSelectScene.swift`
- `Traffic Getaway/LevelData.swift`
- `Traffic Getaway/MainMenuScene.swift`
- `Traffic Getaway/MissionManager.swift`
- `Traffic Getaway/ResultsScene.swift`
- `Traffic Getaway/WorldTheme.swift`

## What Changed

- Rebuilt `WorldTheme.swift` around exactly three city themes: Los Angeles, New York, and Miami.
- Added theme fields for short description, lane style, shoulder style, skyline style, prop set, signage style, traffic color set, police flavor, lighting mood, exit sign style, difficulty flavor, and unlock requirement.
- Removed the old six-world level mapping so each story level now uses its own `RunCity` theme.
- Updated New York so it no longer inherits Los Angeles/Sunlit California colors.
- Updated Miami with tropical pastel/aqua/coral styling while keeping the shared low-detail arcade asset language.
- Routed legacy city palette calls through `WorldThemeCatalog` so old call sites use the city-specific theme data.
- Added city-colored police specs for cruisers, SUVs, and police motorcycles while keeping the existing procedural silhouettes.
- Updated gameplay road layout, skyline/backdrop treatment, road markings, props, HUD city code, pre-run overlay, game-over overlay, exits, and city transition banners.
- Updated level select into a three-city picker that opens on the next playable city.
- Replaced compact city tabs with city cards showing city name, short identity text, difficulty flavor, road preview, palette strip, and select/locked state.
- Reordered app and `GameCore` level catalogs so `la_01` / Sunset Merge is the first playable route.
- Moved the starter 42-second exit target to Sunset Merge and made New York unlock after the Los Angeles routes.
- Updated `RunCity.rank`, reach-city missions, daily challenge copy, achievements, and GameSim defaults for LA -> New York -> Miami progression.
- Updated main menu skyline and next-chase copy to reflect the next playable city.
- Updated results to show city and selected vehicle.
- Updated in-game startup defaults so the first story scene initializes on the selected/current level's city instead of briefly defaulting to New York.
- Updated the in-game settings/pause overlay to show the active city and use the active city accent.
- Updated the results screen backdrop, panel/buttons, and next-city unlock summary to use the run city's theme.
- Updated the developer art gallery city theme page.
- Updated `Docs/ART_PASS_STATUS.md` with the required Three-City World Identity Pass audit.

## Three-City Theme Notes

- Los Angeles: bright Sunlit California palette, warm asphalt, cream/yellow markings, ocean/turquoise accents, palms, low-rise coastal backdrop, green freeway exits, highway patrol flavor.
- New York: cool gray/navy/steel palette, taxi-yellow accents, tighter urban expressway feel, vertical block skyline, building/steam props, heavier urban police flavor, expressway/tunnel exits.
- Miami: aqua/coral/pink pastel palette, bright coastal road treatment, hotel/neon/palm props, sportier tropical traffic colors, flashy police accents, beach-style exits.

## Tests Run

Ran the Windows handoff checker:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Tools\windows\check_pc_handoff.ps1
```

Result:

- Required project files were present.
- 52 Swift files were found.
- Swift line endings look PC-safe.
- Git was not found on PATH.
- Swift was not found on PATH.
- Swift checks were skipped.
- Mac/Xcode build and simulator testing are still required.

Additional checks:

- `swift --version` failed because Swift is not on PATH.
- `git --version` failed because Git is not on PATH.
- `cd GameCore && swift test` was attempted and failed because Swift is not on PATH.
- `cd GameSim && swift run GameSim --level la_01 --vehicle starter_compact --runs 10000 --seed 12345` was attempted and failed because Swift is not on PATH.
- `cd GameSim && swift run GameSim --level all --vehicle starter_compact --runs 10000 --seed 12345` was attempted and failed because Swift is not on PATH.
- Merge-marker scan found no conflict markers.
- Removed six-world enum/raw-value scan found no old six-world source identifiers.
- Old six-world display-name scan found no remaining hits after this handoff rewrite.
- Non-ASCII scan across `Traffic Getaway` and `Docs` found no hits.
- Stale starter-route command/copy scan found no remaining hits.
- City-select source check confirms `LevelSelectScene` builds city cards from the three-theme catalog with road previews, palette strips, and locked/select state.
- UI source check confirms in-game settings shows the active city, results use `resultWorldTheme`, and newly crossed city unlocks are named in the results summary.
- Source evidence confirms `la_01` is first in both app and `GameCore` catalogs, and `RunCity.rank` maps Los Angeles to 1, New York to 2, Miami to 3.

## Simulation Results

No simulation results are available. `GameSim` was attempted for `la_01` and for all starter-car levels, but both commands failed because Swift is not available on this Windows desktop.

## Known Issues

- iOS build and Simulator visual validation still require Mac/Xcode.
- Swift is not available on this Windows desktop, so `GameCore` tests and `GameSim` were not run.
- Git is not available on this Windows desktop, so normal status/diff workflows were unavailable.
- City props and skyline elements are still procedural placeholder shapes, not final authored bitmap assets.
- Police variants are city-colored but still share base procedural silhouettes.
- Store, main-menu settings, onboarding, and some deeper overlays still need a broader visual cleanup pass.
- This pass changed story order and starter balance, so `GameCore` tests and `GameSim` remain required as soon as Swift is available.

## Highest-Priority Next Task

On Mac, run `Tools/mac/verify_on_mac.sh`, launch the app in iOS Simulator, and inspect Los Angeles, New York, and Miami gameplay from the city picker. Verify city-card layout, road/lane readability, traffic/police contrast, prop placement outside lanes, exit event clarity, results layout, and frame-rate/node-count health.

## Suggested Next Prompt

Read `Docs/CODEX_HANDOFF.md` and `Docs/ART_PASS_STATUS.md`. On Mac, run `Tools/mac/verify_on_mac.sh`, launch Traffic Getaway in Simulator, test the three city-select cards, Los Angeles, New York, and Miami gameplay plus one endless transition, and report readability, layout, and performance issues.
