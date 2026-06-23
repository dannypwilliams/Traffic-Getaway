# Live-Hazard Autoplay Matrix Notes

Date: 2026-06-22 local session.

Simulator: iPhone 17e, iOS 26.5.

Build: Debug simulator build from `Tools/mac/verify_on_mac.sh`, explicitly installed before capture.

## Purpose

Test whether debug autoplay survives longer when lane decisions use current on-screen hazard danger instead of relying only on the latest spawned traffic-wave safe-slot list.

## Summary

- Runs: 5.
- Completed: 0/5.
- Terminal reason: traffic collision in all 5 runs.
- Avg terminal time: 8.6s.
- Median terminal time: 4.5s.
- Avg traffic waves: 8.4.
- Avg near misses: 2.6.
- Autoplay decisions: 269.
- Autoplay move decisions: 41.
- Autoplay decision sources: `debug_autoplay_live_hazards` 176, `debug_autoplay_latest_wave` 93.
- Autoplay decision statuses: `already_at_target` 205, `move` 41, `no_reachable_slots` 23.
- One run reached 24.9s, but all 5 still ended in traffic collisions before the exit.

## Read

Using live hazards improved the average terminal time versus the corrected latest-wave matrix (8.6s versus 6.3s), but did not resolve the sim/live gap. The remaining mismatch is not simply stale latest-wave steering. The next comparison should inspect collision frames and no-reachable frames against the current active traffic roster, player hitbox, and GameSim's lack of active-traffic lifetime modeling.
