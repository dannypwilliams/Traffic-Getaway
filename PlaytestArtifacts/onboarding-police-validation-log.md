# Onboarding + Police Validation Log

Date/time: 2026-06-22 13:22:20 -07:00
Branch at start: main
Commit observed at start: 5b77c129685abfae083ca39acb14be15ca0259ed
Current HEAD after external repo update: 176fd573003085e3189b87069993dec313abc9f9

## Environment Checks

- `pwd`: `C:\Users\danny\Documents\GitHub\Traffic-Getaway`
- `git status`: not available because Git is not on PATH in this Windows environment.
- `git log -1 --oneline`: not available because Git is not on PATH. `.git/logs/HEAD` shows the repo moved from `5b77c129...` to `176fd573...` with commit message `y1` during this session.
- `xcodebuild -list`: not available because Xcode tools are not installed on this Windows environment.
- `xcrun simctl shutdown all`: not available because Xcode tools are not installed on this Windows environment.
- `xcrun simctl list devices`: not available because Xcode tools are not installed on this Windows environment.
- `PlaytestArtifacts`: created.
- Windows handoff check: passed basic file and line-ending checks; Swift and Git checks were skipped because those tools are unavailable.

## Before Source Findings

- Fresh-install first-run flow presents `OnboardingScene` from `GameViewController` when `hasCompletedOnboarding` is false.
- `OnboardingScene` did not have a first-visible-frame guard before this pass.
- The first onboarding step had no traffic object in the road illustration because tutorial traffic was only added for later steps.
- The first onboarding step was action-complete immediately and could show a ready `NEXT` button without a rendered-frame/read-time gate.
- Title/skip crowding could not be visually reproduced here, but source layout placed top progress and `SKIP` on the same top row, with the main title positioned separately using fixed proportions.

## Required Before Captures

- `PlaytestArtifacts/before-01-launch.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/before-02-first-visible-frame.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/before-03-tutorial-after-5-seconds.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/before-first-run-tutorial.mp4`: not captured. Simulator unavailable.

## Tutorial Fix Notes

- First beat now shows `QUICK CHASE SCHOOL` and `Traffic is slower. Read the gaps.`
- First visible tutorial scene now builds a road, lane markers, player car, two traffic cars, and a highlighted gap immediately from SpriteKit shapes/procedural previews.
- Top layout now uses safe-area-aware offsets, with progress at top-left, skip at top-right, and the title on its own row below.
- Tutorial advancement is gated by `hasObservedFirstUpdate`, `didRenderVisibleFrame`, and per-step minimum read times. The first beat requires a first update to pass, then 3.1 seconds after the subsequent timer start before `NEXT` activates.
- Final `START RUN` is also gated by the same rendered-frame/read-time check.

## Static iPhone SE Layout Audit

Calculated from the current `OnboardingScene` layout formulas; this is not a replacement for simulator screenshots.

- 320x568 iPhone SE:
  - `SKIP` center: `(267, 528)`, approximate vertical bounds `512...544`.
  - `QUICK CHASE SCHOOL` title center y: `482`, approximate vertical bounds `469...495`.
  - Subtitle center y: `442`.
  - Tutorial road center y: `267`, vertical bounds `180...354`.
  - First two bullet rows: `141` and `115`.
  - Pager dots y: `98`.
  - Bottom button center y: `50`, approximate vertical bounds `28...72`.
- 375x667 iPhone SE:
  - `SKIP` center: `(322, 627)`, approximate vertical bounds `611...643`.
  - Title center y: `575`.
  - Subtitle center y: `529`.
  - Tutorial road center y: `300.15`, vertical bounds `213.15...387.15`.
  - First two bullet rows: `168` and `142`.
  - Pager dots y: `98`.
  - Bottom button center y: `50`, approximate vertical bounds `28...72`.

## Police Pressure Source Validation

- `GameScene` now tracks `timeSinceLastLaneChange` during play.
- After a 2 second grace period, passive police pressure ramps to full over the next 4 seconds.
- Passive pressure increases the police closing multiplier up to 2.42x.
- Passive pressure can trigger the red warning pulse even before the police car reaches the old gap-warning threshold.
- Sustained passivity raises visible wanted level to 2 after 3.5 seconds and 3 after 5.5 seconds.
- Delayed, real lane changes reduce police pressure slightly; rapid lane changes under the idle threshold do not repeatedly farm a large police pushback.
- Floating warnings show `MOVE - POLICE CLOSING` and then `CHANGE LANES NOW` as pressure rises.
- Source-constant estimate for a fully passive starter run: passive warning/cue begins around 4 seconds and the minimum police gap is reached around 13.8 seconds, before considering traffic, vehicle frame overlap, world multipliers, or player mistakes.
- Traffic spawning reserves the player lane and nearby lanes while traffic density is below the high-density threshold, which should help the passive-pressure signal appear before immediate unavoidable traffic in early play.

## Gameplay Tests

### Test A: Normal Lane-Changing Run

Not run. Simulator unavailable in this environment.

Source expectation after change: lane changes reset passive pressure; delayed lane changes can slightly increase police gap; near misses and lane splits still use existing `pushPoliceBack()` rewards.

### Test B: Passive Driving Run

Not run. Simulator unavailable in this environment.

Source expectation after change: passive players see earlier police warning feedback, wanted escalation, stronger police closing, and a possible police-caught failure before passive driving is hidden behind only traffic collisions.

### Test C: Rapid Lane-Changing Run

Not run. Simulator unavailable in this environment.

Source expectation after change: controls use the existing movement path; rapid lane changes reset passive time but do not get the delayed-lane-change pressure relief unless the player has actually waited at least 1.6 seconds.

## Results Screen Quick Check

Not run visually. Static iPhone SE source check suggests bottom buttons are not clipped: `GARAGE`, `LEVEL SELECT`, and `MENU` are centered at y=54 with 36-point button height, leaving their bottom edge around y=36 on a 320x568 screen. This still needs a simulator tap check.

## Required After Captures

- `PlaytestArtifacts/after-01-launch.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-02-first-visible-tutorial.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-03-tutorial-layout-se.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-04-game-start.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-05-passive-police-pressure.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-06-police-catch-or-passive-failure.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-07-normal-lane-changing.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-08-results.png`: not captured. Simulator unavailable.
- `PlaytestArtifacts/after-onboarding-police-validation.mp4`: not captured. Simulator unavailable.
