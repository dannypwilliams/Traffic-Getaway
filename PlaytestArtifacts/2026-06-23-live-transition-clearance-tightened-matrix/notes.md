# Tightened Transition-Clearance Matrix Notes

## Result

The tightened debug-autoplay transition-clearance pass completed 5/5 iPhone 17e simulator runs for `la_01` + `starter_compact`.

Compared with the previous transition-clearance matrix:

| Metric | Previous transition clearance | Tightened transition clearance |
|---|---:|---:|
| Completed | 1/5 | 5/5 |
| Avg terminal time | 26.7s | 42.8s |
| Median terminal time | 30.0s | 42.7s |
| Avg traffic waves | 23.4 | 36.2 |
| Avg near misses | 6.4 | 14.0 |
| Avg cash | 58 | 115 |
| Lane-change probes | 742 | 1079 |
| Lane-change transitions | 121 | 183 |
| Lane-change intersection probes | 2 | 0 |
| Lane-change unsafe-path probes | 1 | 2 |
| `no_transition_safe_slots` decisions | 6 | 18 |
| Terminal traffic collisions | 4 | 0 |

## Interpretation

The longer transition horizon and small vertical padding on predicted traffic hitboxes closed the sampled live autoplay failure: the car now waits through marginal transition windows instead of moving through traffic that remains active during the SpriteKit lane-change animation.

This is still debug-autoplay evidence, not final balance evidence. Completion is now higher than the intended 40-60% Level 1 target, near misses are above the 3-8 target band, and GameSim still does not explicitly model animated lane-change path occupancy or live active-traffic lifetime.

## Recommended Next

Keep the tightened live safety adapter, capture a human-controlled iPhone 17e matrix, and then decide whether the same horizon/padding model should move into `GameCore`/`GameSim` before retuning Sunset Merge density, rewards, or near-miss payout.
