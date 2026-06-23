# Passive Police Capture Matrix - iPhone 17e

This matrix validates the passive no-input first-minute outcome after adding the app-side passive police capture threshold.

## Setup

- Device: iPhone 17e simulator
- Level: `la_01`
- Vehicle: `starter_compact`
- Mode: `--manual`, direct-start telemetry capture
- Player input: none
- Runs: 5

## Result

- Completed: 0/5
- Terminal reasons: `police_caught` 5
- Average terminal time: 9.0s
- Median terminal time: 9.0s
- Autoplay decisions: 0
- Collision analyses: 0/5, expected because these runs ended by police capture rather than traffic overlap.

## Read

The passive-driver requirement is now green on iPhone 17e: no-input play consistently reads as police capture pressure before traffic or roadblocks can become the terminal outcome.
