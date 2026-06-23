# Progression Payoff - Starter Bike

This capture validates the first Sunset Merge escape payoff path with a debug-only synthetic first-escape result scenario.

## Setup

- Device: iPhone 17e simulator
- Scenario: `TrafficGetaway.debug.resultScenario = first_escape_starter_bike`
- Build: Debug simulator build from `Tools/mac/verify_on_mac.sh`
- Script: `python3 scripts/capture_progression_payoff.py --device 8EEF99A1-91E9-4DAA-97E8-5BFA68F2641E --output-dir PlaytestArtifacts/2026-06-23-progression-payoff-starter-bike`

## Evidence

- Screenshot: `starter-bike-use-bike-results.png`
- Metadata: `metadata.txt`

The screenshot shows `ESCAPED`, `Starter Bike unlocked: split lanes`, and the primary action `USE BIKE`.

## Save-State Verification

After capture, the simulator save state contained:

- `selectedCarID = starter_bike`
- `unlockedCarIDs = [starter_compact, starter_bike]`
- `completedLevelIDs = [la_01]`
- `totalRuns = 1`
- Debug defaults cleared: `[]`

## Read

The app-side payoff path now has visual evidence for the first Sunset Merge escape result screen. This proves the unlock/select/result-copy portion of the payoff. It does not yet prove a tapped `USE BIKE` button launches and plays through 405 Afterburn under active input.
