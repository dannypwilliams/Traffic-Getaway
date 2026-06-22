# Traffic Getaway Onboarding + Police Validation Report

## Environment
- Date/time: 2026-06-22 13:22:20 -07:00
- Git commit before: 5b77c129685abfae083ca39acb14be15ca0259ed, observed from `.git` before edits
- Git commit after, if changed: 176fd573003085e3189b87069993dec313abc9f9, observed after an external `y1` commit moved `main` during this session
- Branch: main
- Simulator: unavailable in this Windows environment
- iOS runtime: unavailable in this Windows environment
- Xcode version: unavailable; `xcodebuild` is not on PATH

## Files Changed
- `Traffic Getaway/OnboardingScene.swift`: Reworked first-run onboarding copy, post-first-update/read-time gating, immediate road/car/traffic visuals, and compact safe-area-aware top layout.
- `Traffic Getaway/GameScene.swift`: Added passive lane-idle police pressure, passive warning cues, wanted escalation from passivity, and small pressure relief after real delayed lane changes.
- `PlaytestArtifacts/onboarding-police-validation-log.md`: Captures environment limits, source findings, and required evidence gaps.
- `PlaytestArtifacts/onboarding-police-validation-report.md`: This report.
- `Docs/CODEX_HANDOFF.md`: Updated session handoff with the implementation and remaining Mac validation need.

## First-Run Tutorial Before
- Was black screen reproduced? No. Simulator launch was blocked because `xcodebuild` and `xcrun` are unavailable here.
- How long until visible tutorial? Not measured. Source review showed `OnboardingScene` is presented from `GameViewController` after nonzero `SKView` bounds.
- Did tutorial advance too early? Source review showed the first step was action-complete immediately, with no rendered-frame/read-time guard before `NEXT`.
- Screenshot/video references: Required before screenshots and video were not captured because no simulator is available in this environment.

## First-Run Tutorial After
- Is the first visible frame clear? Source-level implementation now builds a nonblack road scene with lane markers, player car, two traffic cars, highlighted gap, `QUICK CHASE SCHOOL`, first instruction text, and `SKIP` immediately in `didMove`.
- Does the first instruction remain long enough? Source-level implementation gates `NEXT` until after the first update has passed, a later update starts the read timer, and 3.1 seconds elapse on the first beat.
- Does title/skip layout work on iPhone SE? Source-level layout separates `SKIP` onto a safe top-right row and places the title below it with compact font sizing. Simulator visual confirmation is still required.
- Screenshot/video references: Required after screenshots and video were not captured because no simulator is available in this environment.

## Tutorial Changes Made
- Replaced the long 7-step onboarding copy with 6 short arcade beats.
- Changed the first beat to `QUICK CHASE SCHOOL` and `Traffic is slower. Read the gaps.`
- Added immediate traffic cars and a highlighted gap to the first tutorial illustration.
- Added safe-area-aware top/bottom spacing and compact sizing for small iPhone screens.
- Added `hasObservedFirstUpdate`, `didRenderVisibleFrame`, `stepPresentedAt`, and per-step `minimumReadTime` gating so step advancement cannot occur during the same update cycle that first builds the visible tutorial frame.

## Static iPhone SE Layout Audit
- 320x568 source-coordinate check: `SKIP` vertical bounds are approximately `512...544`; `QUICK CHASE SCHOOL` title bounds are approximately `469...495`, leaving separation between the top button row and title row.
- 320x568 source-coordinate check: road bounds are approximately `180...354`, bullet rows are around `141` and `115`, pager y is `98`, and bottom controls are around `28...72`.
- 375x667 source-coordinate check: `SKIP` bounds are approximately `611...643`, title center y is `575`, subtitle center y is `529`, and road bounds are approximately `213...387`.
- This audit is only source math; iPhone SE screenshots remain required.

## Police / Passive Driving Validation
### Test A: Normal Lane-Changing
- What happened: Not run; simulator unavailable.
- Survived how long: Not measured.
- Police behavior: Source expectation is manageable pressure because lane changes reset passive time and existing near-miss/lane-split rewards still push police back.
- Traffic behavior: Not visually tested.
- Screenshot/video references: Not captured.

### Test B: Passive Driving
- What happened: Not run; simulator unavailable.
- Did police pressure rise: Source implementation now ramps passive pressure after 2 seconds idle, reaches full passive pressure after 6 seconds idle, and increases police closing speed.
- Did police catch happen: Not measured. Source-constant estimate reaches the minimum police gap around 13.8 seconds of full passivity before accounting for traffic, vehicle frame overlap, or world multipliers.
- Did traffic collision happen first: Not measured.
- Screenshot/video references: Not captured.

### Test C: Rapid Lane-Changing
- What happened: Not run; simulator unavailable.
- Any control instability: Not measured.
- Any exploit: Source implementation avoids large police relief for rapid lane changes by only applying relief after at least 1.6 seconds idle.
- Screenshot/video references: Not captured.

## Results Screen Quick Check
- Visual/tap test: Not run; simulator unavailable.
- Static iPhone SE source check: Bottom action buttons are positioned above the screen bottom (`DOUBLE CASH` y=150, primary action y=102, bottom row y=54 with 36-point height), so they do not appear clipped by source coordinates on a 320x568 layout.
- Remaining risk: Button crowding/tapability still needs real simulator confirmation.

## Gameplay Verdict
- Is the game more understandable in the first 30 seconds? Source-level onboarding is clearer and shorter, but visual proof is still missing.
- Does passive driving feel punished? Source-level police pressure now punishes passivity, but playtest confirmation is still missing.
- Does lane changing feel meaningfully rewarded? Source-level lane changing now resets passive pressure and can slightly relieve pressure after a real idle period; near-miss/lane-split rewards remain.
- Are traffic and police failure states distinct enough? Existing failure copy/results already distinguish traffic collision and police caught; passive pressure should make police catch easier to observe, but simulator evidence is still required.

## Remaining Issues
1. P0 - Required iPhone SE simulator screenshots and video are missing because this Windows environment has no Xcode simulator tools.
2. P0 - Passive, normal, and rapid lane-changing gameplay tests still need real simulator execution.
3. P1 - Swift compile, `GameCore` tests, and `GameSim` are blocked because Swift is not installed or not on PATH.
4. P1 - Git status/diff commands are blocked because Git is not installed or not on PATH.
5. P2 - Results screen bottom buttons passed only a static source-position check; tapability still needs simulator confirmation.

## Recommended Next Prompt
On a Mac with Xcode installed, continue the Traffic Getaway first-run onboarding and police pressure validation pass. Read `PlaytestArtifacts/onboarding-police-validation-report.md` and `PlaytestArtifacts/onboarding-police-validation-log.md`, then run `Tools/mac/verify_on_mac.sh`. Use a fresh install on the smallest available iPhone SE simulator and capture the requested before/after screenshots if possible, prioritizing after-fix proof. Confirm that `QUICK CHASE SCHOOL`, the first instruction, road, player car, traffic, and `SKIP` are visible immediately. Run normal lane-changing, passive driving, and rapid lane-changing tests, and record whether passive police pressure produces a visible warning or police-caught failure before traffic becomes the only failure mode. Check the results screen bottom buttons for clipping and tapability on iPhone SE. Update this report with real screenshot/video references, measured survival times, and any remaining gameplay issues.
