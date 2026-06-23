# USE BIKE Tap-Through - Starter Bike

This capture validates that the first Sunset Merge payoff primary action launches 405 Afterburn with the Starter Bike selected.

## Evidence

- Screenshot: `405-afterburn-starter-bike-active-input.png` (terminal result after the smoke run)
- Telemetry: `405-afterburn-starter-bike-telemetry.jsonl`
- Metadata: `metadata.json`

## Verified Telemetry

- `run_started.levelID = la_02`
- `run_started.vehicleID = starter_bike`
- `run_started.vehicleClass = motorcycle`
- Active input produced at least one `lane_changed` event into an interstitial motorcycle split slot.

## Read

This proves the real `USE BIKE` button transitions into the next story level with the unlocked motorcycle and accepts active input on split-slot motorcycle movement. The smoke run ended in a police capture, so this is not a full 405 Afterburn completion or balance matrix.
