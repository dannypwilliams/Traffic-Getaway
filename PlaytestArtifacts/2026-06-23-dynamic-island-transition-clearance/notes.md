# Dynamic Island Transition-Clearance Matrix Notes

## Result

The tightened transition-clearance build was captured on an iPhone 17 Pro simulator, iOS 26.5, using debug autoplay for `la_01` + `starter_compact`.

| Metric | iPhone 17e tightened matrix | iPhone 17 Pro Dynamic Island matrix |
|---|---:|---:|
| Completed | 5/5 | 3/5 |
| Avg terminal time | 42.8s | 38.9s |
| Median terminal time | 42.7s | 42.3s |
| Avg first crash | n/a | 32.3s |
| Avg traffic waves | 36.2 | 33.6 |
| Avg near misses | 14.0 | 16.6 |
| Avg cash | 115 | 118 |
| Lane-change probes | 1079 | 1039 |
| Lane-change transitions | 183 | 198 |
| Lane-change intersection probes | 0 | 0 |
| Lane-change unsafe-path probes | 2 | 1 |
| `no_transition_safe_slots` decisions | 18 | 23 |
| Terminal traffic collisions | 0 | 2 |

## Interpretation

The Dynamic Island-class simulator did not reproduce the earlier animated lane-change intersection failure: lane-change intersection probes stayed at 0 across 198 transitions. However, it did produce 2/5 traffic-collision terminals after `no_transition_safe_slots` decisions, so the tightened live adapter is not fully device-shape invariant yet.

This remains debug-autoplay evidence. It is useful for layout/input-shape comparison, but it does not replace the required human-controlled iPhone 17e and Dynamic Island validation matrices.

## Evidence

- Summary: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/summary.md`
- Telemetry: `PlaytestArtifacts/2026-06-23-dynamic-island-transition-clearance/telemetry/`
- Direct plist verification confirmed the debug auto-start/autoplay keys were manually cleared after capture.
