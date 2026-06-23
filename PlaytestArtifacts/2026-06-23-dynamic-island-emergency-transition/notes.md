# Dynamic Island Emergency-Transition Matrix Notes

## Result

The iPhone 17 Pro Dynamic Island debug-autoplay matrix was rerun after adding a strict emergency transition fallback for debug autoplay. The fallback only activates when every strict transition candidate is rejected, staying in the current slot is predicted dangerous, and another reachable transition has lower predicted collision risk.

| Metric | Prior Dynamic Island tightened matrix | Emergency-transition matrix |
|---|---:|---:|
| Completed | 3/5 | 4/5 |
| Avg terminal time | 38.9s | 38.4s |
| Median terminal time | 42.3s | 42.4s |
| Avg first crash | 32.3s | 21.5s |
| Avg traffic waves | 33.6 | 31.4 |
| Avg near misses | 16.6 | 15.8 |
| Avg cash | 118 | 114 |
| Lane-change probes | 1039 | 1103 |
| Lane-change transitions | 198 | 191 |
| Lane-change intersection probes | 0 | 0 |
| Lane-change unsafe-path probes | 1 | 0 |
| `no_transition_safe_slots` decisions | 23 | 19 |
| `emergency_move` decisions | 0 | 1 |
| Terminal traffic collisions | 2 | 1 |

## Interpretation

The emergency fallback improved the sampled Dynamic Island result from 3/5 to 4/5 escapes without reintroducing lane-change intersection probes. The remaining traffic collision still follows a `no_transition_safe_slots` decision, so the first-minute model is not locked.

This is still debug-autoplay evidence. It should guide sim/live calibration and device-shape investigation, not replace human-controlled validation.

## Evidence

- Summary: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/summary.md`
- Telemetry: `PlaytestArtifacts/2026-06-23-dynamic-island-emergency-transition/telemetry/`
- Direct plist verification confirmed debug auto-start/autoplay keys were manually cleared after capture.
