# Traffic Getaway Playtest Notes

Date: 2026-06-22 11:26 PDT

## Device and Build

- Build status: Debug iOS Simulator build succeeded with `Traffic Getaway.xcodeproj`, scheme `Traffic Getaway`, iOS Simulator SDK 26.5.
- Simulator tested: iPhone 17 Pro, iOS 26.5, device id `90D3514A-BDE2-412C-8238-8ECC17BD86B6`.
- Physical device: not tested. `xctrace` listed physical iPhones as offline during this pass.
- Fresh install: completed with uninstall/install before first-run validation.
- Launch polish: `simctl` screenshots sometimes captured a black transition/status-bar frame immediately after launch, but the live Simulator rendered the tutorial normally after a short wait. No white flash observed.

## Tutorial and First Run

- First experience opens directly into the playable `QUICK CHASE SCHOOL` tutorial.
- Tutorial is short, skippable, and teaches lane movement, traffic reading, near misses, boost, and exit direction.
- Found and fixed iPhone 17 Pro Dynamic Island collision: the tutorial title initially sat behind/too close to the cutout.
- Post-fix live check: title clears the Dynamic Island, prompt has readable spacing, and the Skip button remains reachable.

## Level 1 / Brooklyn Warmup

- Hands-on runs completed: 1 focused natural run plus screen-flow validation. The requested 5-run sample is still needed before final balance sign-off.
- Run 1 length observed: reached primary exit window at about 38 seconds.
- First crash time: no early crash in the first 25 seconds; the first exit was missed by the tester after entering the right-side ramp area too late/not far enough.
- Exit appeared: yes.
- Exit timing: around 38 seconds, matching the 35-45 second target.
- Exit readability: strong. Green lane glow, large `RIGHT EXIT`, arrows, countdown, and HUD state all agreed.
- Exit reachability: reachable, but the player must commit all the way into the far exit slots before the countdown expires.
- Fairness: first 25 seconds felt fair and readable. Heavier vehicles began appearing after the early safety window.
- HUD blocking traffic: HUD is compact and readable, but close to the Dynamic Island. It does not block most incoming traffic.
- Buddy dialogue blocking traffic: found an issue where forced exit/emergency buddy lines appeared near the upper read-ahead zone and wanted banner. Fixed by moving exit-related buddy callouts to the lower radio strip.
- Near misses: readable and satisfying when they triggered; needs more multi-run testing for haptic/audio feel under pressure.
- Boost: tutorial communicates Dodge Boost, but the Level 1 run did not produce enough repeated boost use to fully judge comprehension.
- Crash/explanation clarity: missed-exit buddy message was understandable; more crash cases should be sampled.

## UI and Layout

- Main menu: clear title, car card, daily card, Story Chase, Garage, Missions, Achievements, and Settings all fit on iPhone 17 Pro.
- Level select: `STORY CHASE` title clears the cutout, Level 1 is ready, locked levels explain requirements, and Endless Pursuit is visible.
- Settings: no Replay Tutorial / Controls overlap observed. Toggles, sliders, Replay Tutorial, Credits/Privacy/Support, Reset Save Data, and Back are separated and hittable.
- Garage: Cars/Bikes/Paint tabs are visible. First bike is visible on fresh save and clearly says `NEED $550 MORE`.
- Store: Store button is hidden from main navigation by `AppConfig.showStoreButton = false`; simulated purchase UI remains in code but is not release-facing.

## Controls, Haptics, and Audio

- Touch/tap lane movement feels responsive in Simulator.
- Tap controls are understandable and forgiving enough for the first run.
- Physical haptics were not validated because no iPhone was available.
- Audio configured and no runtime audio crash was observed; subjective audio mix should be checked on device.

## Bike Availability

- First motorcycle: `Starter Bike`, cost `$550`.
- Fresh-save garage clearly explains lane splitting with `Lane Split Enabled` and shows bike-specific stats.
- Bike is not available immediately on fresh install. It should be reachable after a few successful early runs, but economy timing still needs simulation/longer playtest confirmation.

## Release Blockers and Follow-Ups

- Complete the requested 5 natural Level 1 runs after this layout fix to collect a real pass/fail sample.
- Test on a physical iPhone for haptics, audio latency, notch/cutout rendering, and touch feel.
- Consider one more pass on exit completion affordance: the exit is readable, but the exact "far enough into the ramp" threshold should be unmistakable.
- Investigate the `simctl` black screenshot frame after launch; live Simulator is fine, but launch capture behavior should be checked before App Store screenshot automation.

## Pending Post-Merge Validation

The Mac pass above was performed before the three-city world identity merge. After resolving this merge, validate the new first route and city presentation:

- Build in Xcode.
- Launch in iOS Simulator.
- Play `la_01` / Sunset Merge at least 5 times.
- Record first crash time, exit appearance, exit reachability, and completion/missed-exit causes.
- Inspect Los Angeles, New York, and Miami city cards.
- Verify road/lane readability, traffic/police contrast, prop placement outside lanes, exit event clarity, results layout, and frame-rate/node-count health.
- Compare Simulator feel against a physical iPhone if available.
