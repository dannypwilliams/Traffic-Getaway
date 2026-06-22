# Traffic Getaway Bug Report

## Summary
Traffic Getaway is playable in the iPhone SE simulator. The game builds, launches, enters Endless Pursuit, recognizes swipe lane changes, spawns readable traffic, shows police pressure, reaches collision/fail states, and returns to a clear results/restart loop. The biggest issue found is first-run tutorial presentation: the app can initially look like a black screen even though tutorial elements exist, and the tutorial may advance before the player sees the first instruction.

No source fixes were made in this pass because the game was playable and the visible issues need small UI/timing follow-up rather than an obvious safe blocker patch.

## Critical Bugs
None observed. No build failure, launch crash, blank permanent gameplay screen, missing start path, broken controls, or missing restart path.

## High Priority Bugs
None observed.

## Medium Priority Bugs
- First-run tutorial can initially appear as a black screen.
  - Evidence: `01-launch.png`, `02-tutorial-black-screen.png`, `13-repro-first-run-black-tutorial.png`
  - Impact: New players may think the app failed to load.
  - Suspected files: `Traffic Getaway/GameViewController.swift`, `Traffic Getaway/TutorialScene.swift`

- Tutorial title and `SKIP` control crowd each other on iPhone SE.
  - Evidence: `13-repro-first-run-black-tutorial.png`
  - Impact: First-run UI feels cramped and less polished on the target small device.
  - Suspected file: `Traffic Getaway/TutorialScene.swift`

## Low Priority Bugs
- Results bottom action row is crowded on iPhone SE.
  - Evidence: `08-run-complete-results.png`, `11-second-run-results.png`
  - Impact: Usable but visually tight.
  - Suspected file: `Traffic Getaway/ResultsScene.swift`

- Police catch behavior needs longer validation.
  - Evidence: `09-passive-driving-pressure.png`, `10-police-catch-or-late-pressure.png`
  - Impact: Police pressure is visible, but traffic collision ended both short runs before a police-caught state appeared.
  - Suspected file: `Traffic Getaway/GameScene.swift`

## Screenshot / Video Index
- `01-launch.png` - Initial launch capture; mostly black app screen with status bar.
- `02-tutorial-black-screen.png` - Second early tutorial capture; still visually black while tutorial accessibility elements existed.
- `03-story-chase-menu.png` - Story Chase menu after tapping accessible `SKIP`.
- `04-game-start.png` - Endless Pursuit start in New York.
- `05-first-lane-change-traffic.png` - First successful lane change with traffic visible.
- `06-wrecked-collision.png` - First run collision modal with revive/no-thanks choices.
- `07-post-no-thanks-stuck.png` - Short post-no-thanks collision banner transition.
- `08-run-complete-results.png` - First run results/progression screen.
- `09-passive-driving-pressure.png` - Second run passive driving with red police pressure frame and police car.
- `10-police-catch-or-late-pressure.png` - Second run collision after passive/late-pressure test.
- `11-second-run-results.png` - Second run results with accumulated cash/XP.
- `12-current-results-before-reinstall.png` - State before reinstalling to reproduce first-run behavior.
- `13-repro-first-run-black-tutorial.png` - Fresh reinstall first-run tutorial after waiting; visible but already advanced and cramped near title/skip.
- `gameplay-recording.mp4` - Simulator video from menu into gameplay, first failure, results, second run, passive pressure, second failure, and results.

## Recommended Fix Order
1. First fix: Ensure the first-run tutorial renders visibly before its stage timer starts, or present the initial scene only after the SKView/window is fully ready.
2. Second fix: Reposition `SKIP` below or away from the `QUICK CHASE SCHOOL` title on iPhone SE.
3. Third fix: Add a very small first-run grace period so the opening prompt does not advance before the player sees or touches the tutorial.
4. Fourth fix: Loosen or stack the bottom results buttons on SE if future screenshots show clipping across devices.
5. Fifth fix: Run a longer police-specific playtest to confirm whether passive players can be caught by police before traffic collisions dominate.

## Notes for Next Codex Session
Focus on first-run tutorial timing and iPhone SE layout only. Reproduce with a fresh install, capture the first 5 seconds, then make a small fix in `GameViewController.swift` and/or `TutorialScene.swift`. After the fix, reinstall and verify that the first visible frame shows the tutorial title, first instruction, road, and car immediately, with no title/skip overlap.
