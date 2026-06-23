# Next Steps

## Highest Priority

Fix the remaining live collision-timing/GameSim model mismatch before tuning Sunset Merge.

## Immediate Task List

1. Add collision-frame analysis for live telemetry: colliding vehicle, active traffic roster, player slot, safe slots, and last movement decision.
2. Decide whether GameSim should model live active-traffic lifetime/collision timing, or whether live safety selection needs a longer route horizon.
3. Rerun `PlaytestArtifacts/2026-06-22-live-autoplay-live-hazard-matrix/` after the parity fix and confirm live terminal time moves toward GameSim.
4. Capture one human-controlled iPhone 17e matrix and one Dynamic Island-class run.
5. Retune Level 1 completion, near misses, and rewards only after sim/live state agrees.

## Do Not Start Yet

- New routes.
- New vehicles.
- Broad art replacement.
- Rewarded ads/revives.
- Live multiplayer or backend features.
