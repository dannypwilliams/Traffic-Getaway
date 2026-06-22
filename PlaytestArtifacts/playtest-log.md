# Traffic Getaway Playtest Log

## Environment
- Date/time: 2026-06-22 13:05:41 PDT
- Git commit: dc52f0e Chase
- Branch: final
- Mac model if visible: MacBook Air, Apple M2, 8 GB memory
- Simulator device: RiggedShoe-SE-Layout-Test, iPhone SE (3rd generation) device type, UDID 6590A5F4-E23F-4F58-A86D-21346721F429
- iOS runtime: iOS 26.5 (23F77)
- Xcode version: Xcode 26.5, build 17F42
- Scheme: Traffic Getaway
- Build configuration: Debug

## Launch Notes
- Did the app build? Yes. `xcodebuild` succeeded with `CODE_SIGNING_ALLOWED=NO`.
- Did the app launch? Yes. Bundle id `com.danielwilliams.TrafficGetaway` launched in the booted iPhone SE simulator.
- Time from launch to first usable screen: The first capture was a black app screen with status bar while tutorial accessibility elements already existed. A fresh reinstall/relaunch showed the tutorial rendering after roughly 4 seconds, but by then the prompt had already advanced from the first stage.
- Any launch warnings/errors: Build warning only: run script phase `Strip Signing Metadata` runs every build because dependency analysis is unchecked. No launch crash observed.

## Chronological Gameplay Notes
1. 00:00 - App launched after install. Screenshot `01-launch.png` showed a mostly black app screen with only the system status bar visible.
2. 00:02 - Accessibility showed first-run tutorial content, including `QUICK CHASE SCHOOL`, `SKIP`, and `Swipe or tap to cut across lanes`, but screenshot `02-tutorial-black-screen.png` still looked black.
3. 00:05 - Tapped accessible `SKIP`. The app moved to a visible Story Chase level select screen. Screenshot `03-story-chase-menu.png`.
4. 00:10 - Started recording `gameplay-recording.mp4`.
5. 00:12 - Tapped `ENDLESS PURSUIT`. Gameplay started immediately in New York. HUD showed score, wanted level, and distance. Screenshot `04-game-start.png`.
6. 00:18 - Swiped left. Player car changed lanes responsively. Traffic appeared in multiple lanes with readable gaps and distinct vehicle colors. Screenshot `05-first-lane-change-traffic.png`.
7. 00:28 - Swiped right during traffic. First run ended in a `WRECKED` modal with `TRAFFIC COLLISION`, `FREE REVIVE`, and `NO THANKS`. Score around 754, distance around 683. Screenshot `06-wrecked-collision.png`.
8. 00:32 - Tapped `NO THANKS`. A short red collision banner appeared over the playfield saying the chase was done. Screenshot `07-post-no-thanks-stuck.png` captured this transition state.
9. 00:35 - Run Complete screen appeared with score, distance, cash, XP, near misses, wanted level, next unlock progress, and buttons for Double Cash, Play Again, Garage, Level Select, and Menu. Screenshot `08-run-complete-results.png`.
10. 00:42 - Tapped `PLAY AGAIN`. Second run started cleanly. I deliberately avoided steering for several seconds.
11. 00:52 - Passive play produced visible police pressure: a red danger border and police car near the bottom of the screen. Traffic was still the immediate threat. Screenshot `09-passive-driving-pressure.png`.
12. 01:00 - Second run ended in another `TRAFFIC COLLISION`, score around 732 and distance around 677, before a police-caught failure could happen. Screenshot `10-police-catch-or-late-pressure.png`.
13. 01:05 - Tapped `NO THANKS`. Results appeared again and progression totals increased to $134 and 70/150 XP. Screenshot `11-second-run-results.png`.
14. 01:10 - Stopped video recording cleanly. Reinstalled once more to verify the first-run tutorial. Screenshot `13-repro-first-run-black-tutorial.png` shows the tutorial is visible after a wait, but the first prompt had already advanced.

## Controls Feel
- Are lane changes responsive? Yes. Swipes caused immediate lane movement with clear visual feedback.
- Are swipes/taps/drag inputs recognized correctly? Swipes worked. I did not deeply test tap-to-lane behavior beyond button taps.
- Does input ever feel delayed, sticky, reversed, too sensitive, or ignored? No obvious delay or reversal observed in two short runs.
- Can the player recover from mistakes? Recovery felt possible if moving early. Collision text explicitly told me to commit to gaps earlier.
- Does the game encourage lane changes? Yes through traffic layout, near miss feedback, and police pressure, though the first short runs were dominated by traffic collision rather than a police catch.

## Traffic Behavior
- Does traffic feel deterministic, readable, and fair? Early traffic was readable and used varied vehicle colors/sizes. I saw no impossible wall during this short test.
- Does the game punish sitting still in one lane? Yes. Passive driving quickly produced pressure and a traffic collision.
- Are cars spawning visibly, fairly, and with enough warning? Mostly yes in the observed short runs. Vehicles entered with enough screen distance to react, but dense SE-screen traffic demands early commitment.
- Are there impossible patterns? None confirmed.
- Are there empty/dead stretches? No. The run was active from the first seconds.
- Is traffic density appropriate? Good for an arcade prototype, but early density may be a touch high for brand-new players if the tutorial first frame is delayed.

## Police Behavior
- Does police pressure feel visible and understandable? The red border and police car are understandable once they appear. The HUD-only `WANTED *` indicator is small and easy to miss before that.
- Can police catch the player if the player stops changing lanes? I did not reach a police catch; passive play ended in traffic collision first.
- Does police pressure ramp over time? Yes visually, through the red frame and pursuing car.
- Does the player understand why they were caught? Not tested for police catch. Traffic collision explanations are clear.

## UI / UX Notes
- Is the start flow obvious? Story Chase is understandable after tutorial skip. The first-run tutorial can appear black for the first moments, which makes the start feel broken.
- Is text readable on iPhone SE? Mostly yes. Results text is dense but still readable.
- Are buttons too small? Main buttons are tappable. Results bottom row is crowded on SE.
- Are important elements hidden under safe areas? No critical controls were hidden. The tutorial `SKIP` sits near the title and looks cramped in `13-repro-first-run-black-tutorial.png`.
- Is the HUD understandable during gameplay? Score and distance are readable. Wanted state is less clear until the red pressure frame appears.
- Are score/speed/police indicators visible without distracting? Score/distance are good. Wanted star is understated.
- Are results/restart flows clear? Yes. `PLAY AGAIN`, `LEVEL SELECT`, `GARAGE`, and `MENU` are clear, but packed near the bottom.

## Visual / Asset Notes
- Missing assets: None obvious in the tested screens.
- Placeholder assets: Vehicle art is stylized and functional; no obvious broken placeholder seen.
- Bad scaling: First-run tutorial title and skip button crowd each other on SE after the delayed render. Results bottom controls are dense.
- Clipping: No hard clipping observed, but results screen lower controls are close to the bottom edge.
- Bad colors/contrast: High contrast overall. The early black launch/tutorial screen is the biggest contrast/usability issue.
- Inconsistent art style: The game has a coherent neon arcade city style. It does not yet strongly read as distinct LA/New York/Miami beyond labels in this short New York run.
- Anything that does not match the intended 32-bit Sunlit California / city identity style: The tested New York scene leans dark neon/rain rather than sunlit California. City differentiation should be reviewed later, not fixed in this pass.

## Performance Notes
- Any stutter? No obvious stutter observed on the M2 MacBook Air simulator.
- Any freezes? No.
- Any memory warnings? None observed.
- Any frame drops? None obvious by eye.
- Any simulator slowdowns? No significant slowdown.
- Any runaway spawning or excessive object count? No.

## Bugs Observed

### Bug 1
- Title: First-run tutorial can initially appear as a black screen
- Severity: Medium
- Screenshot/video reference: `01-launch.png`, `02-tutorial-black-screen.png`, `13-repro-first-run-black-tutorial.png`
- Steps to reproduce: Fresh install, launch app, observe first few seconds before interacting.
- Expected: The `QUICK CHASE SCHOOL` tutorial should be visible immediately with the first instruction.
- Actual: Initial screenshots showed a black app screen while accessibility already exposed tutorial elements. On reinstall, the tutorial rendered after waiting, but the prompt had already advanced.
- Suspected cause: Initial SpriteKit scene presentation/render timing or tutorial stage timer starting before the first visible frame.
- Suspected files/functions: `GameViewController.presentInitialSceneIfNeeded()` lines 29-42; `TutorialScene.buildScene()` lines 89-101; `TutorialScene.update(_:)` stage timing after line 132.

### Bug 2
- Title: Tutorial title and skip button overlap/crowd on iPhone SE
- Severity: Medium
- Screenshot/video reference: `13-repro-first-run-black-tutorial.png`
- Steps to reproduce: Fresh install, wait for tutorial to render on iPhone SE.
- Expected: Title and skip button should have their own clear space.
- Actual: `SKIP` is tucked into the right side of the title area.
- Suspected cause: Tutorial title uses nearly full screen width while skip is placed at `size.width - 54`.
- Suspected files/functions: `TutorialScene.buildScene()` lines 95-101.

### Bug 3
- Title: Results action row is crowded on iPhone SE
- Severity: Low
- Screenshot/video reference: `08-run-complete-results.png`, `11-second-run-results.png`
- Steps to reproduce: Complete or fail a run and view results on iPhone SE.
- Expected: Bottom actions should have comfortable spacing.
- Actual: `GARAGE`, `LEVEL SELECT`, and `MENU` fit, but feel packed close to the bottom edge.
- Suspected cause: Fixed y positions and fixed button widths for SE layout.
- Suspected files/functions: `ResultsScene.buildResults()` lines 92-128.

### Bug 4
- Title: Police catch condition was not observed before traffic failures
- Severity: Low
- Screenshot/video reference: `09-passive-driving-pressure.png`, `10-police-catch-or-late-pressure.png`
- Steps to reproduce: Start Endless Pursuit, avoid steering for around 10-20 seconds.
- Expected: Police should be able to visibly catch a passive player or explain police failure.
- Actual: Police pressure became visible, but traffic collision ended both short runs first.
- Suspected cause: Early traffic collision remains the dominant fail condition; police may need separate balance validation.
- Suspected files/functions: `GameScene` police/pressure/failure logic; exact function not changed in this pass.

## Final Verdict
- Is the current build playable? Yes. It builds, launches, starts gameplay, handles lane changes, fails, records progression, and restarts.
- What is the biggest blocker? First-run tutorial visibility/startup timing on iPhone SE. It can make the app look broken before the player gets to the menu or game.
- What should be fixed first? Make first-run tutorial visible immediately and keep the first instruction from advancing before the first visible player interaction/window.
- What should not be touched yet? Do not redesign gameplay, add multiplayer, or rebalance traffic broadly until the first-run/tutorial presentation issue is resolved and a longer gameplay session confirms police catch behavior.
