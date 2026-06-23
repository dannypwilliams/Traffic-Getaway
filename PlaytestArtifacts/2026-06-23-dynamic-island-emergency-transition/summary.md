# Run Telemetry Summary

- Runs: 5
- Completed: 4/5 (80.0%)
- Avg terminal time: 38.4s
- Median terminal time: 42.4s
- Avg first crash: 21.5s
- Median first crash: 21.5s
- Avg traffic waves: 31.4
- Avg near misses: 15.8
- Avg cash: 114
- Autoplay decisions: 1216
- Autoplay move decisions: 190
- Autoplay target mismatches: 852
- Autoplay move-target mismatches: 36
- Autoplay applied-slot mismatches: 36
- Collision analyses: 1/5
- Avg collision overlap area: 1.9
- Avg active traffic at collision: 3.0
- Lane-change probes: 1103
- Lane-change transitions: 191
- Lane-change intersection probes: 0
- Lane-change unsafe-path probes: 0
- Max lane-change path danger: 0.5
- Last pre-crash probe intersected traffic: 0/5
- Collision last-decision sources: {'debug_autoplay_live_hazards': 1}
- Collision last-decision statuses: {'no_transition_safe_slots': 1}
- Autoplay decision sources: {'debug_autoplay_latest_wave': 272, 'debug_autoplay_live_hazards': 944}
- Autoplay decision statuses: {'already_at_target': 922, 'emergency_move': 1, 'move': 190, 'no_reachable_slots': 84, 'no_transition_safe_slots': 19}
- Terminal reasons: {'escaped': 4, 'traffic': 1}
- Pattern mix: {'denseClusters': 54, 'recoveryWave': 2, 'sparseLanes': 55, 'staggeredCars': 46}

| File | Level | Vehicle | Seed | Terminal | Completed | Time | Waves | Near misses | Cash | Wanted | Collision rects | Collision analysis | Active traffic | Lane probes | Probe intersections | Decisions | Target mismatch | Applied mismatch |
|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---:|---:|---:|---:|---:|
| 01-2026-06-22_21-13-44-la_01-starter_compact-17033032432948232551.jsonl | la_01 | starter_compact | 17033032432948232551 | escaped | true | 42.4 | 32 | 18 | 129 | 3 | false | false | true | 276 | 0 | 261 | 183 | 5 |
| 02-2026-06-22_21-14-31-la_01-starter_compact-17033032432948240470.jsonl | la_01 | starter_compact | 17033032432948240470 | escaped | true | 42.5 | 41 | 15 | 113 | 3 | false | false | true | 212 | 0 | 275 | 196 | 4 |
| 03-2026-06-22_21-15-18-la_01-starter_compact-17033032432948248389.jsonl | la_01 | starter_compact | 17033032432948248389 | escaped | true | 42.4 | 35 | 16 | 122 | 3 | false | false | true | 245 | 0 | 269 | 195 | 4 |
| 04-2026-06-22_21-16-06-la_01-starter_compact-17033032432948256308.jsonl | la_01 | starter_compact | 17033032432948256308 | traffic | false | 21.5 | 17 | 12 | 80 | 2 | true | true | true | 149 | 0 | 131 | 72 | 10 |
| 05-2026-06-22_21-16-33-la_01-starter_compact-17033032432948264227.jsonl | la_01 | starter_compact | 17033032432948264227 | escaped | true | 43.3 | 32 | 18 | 125 | 3 | false | false | true | 221 | 0 | 280 | 206 | 13 |
