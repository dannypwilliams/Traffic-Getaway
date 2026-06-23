# Next Steps

## Highest Priority

Fix the remaining transition-clearance/GameSim model mismatch before tuning Sunset Merge.

## Immediate Task List

1. Add transition-clearance checks to debug autoplay: the current-to-target path must stay clear for the lane-change duration, and the target slot needs a short post-move danger horizon.
2. Rerun `PlaytestArtifacts/2026-06-23-live-lane-change-parity-matrix/` after the parity fix and confirm lane-change intersections fall and live terminal time moves toward GameSim.
3. Decide whether the successful transition model belongs in GameSim, the live safety adapter, or both.
4. Capture one human-controlled iPhone 17e matrix and one Dynamic Island-class run.
5. Retune Level 1 completion, near misses, and rewards only after sim/live state agrees.

## Do Not Start Yet

- New routes.
- New vehicles.
- Broad art replacement.
- Rewarded ads/revives.
- Live multiplayer or backend features.
