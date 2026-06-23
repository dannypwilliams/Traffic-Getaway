# Run Telemetry Summary

- Runs: 5
- Completed: 1/5 (20.0%)
- Avg terminal time: 26.7s
- Median terminal time: 30.0s
- Avg first crash: 22.3s
- Median first crash: 25.2s
- Avg traffic waves: 23.4
- Avg near misses: 6.4
- Avg cash: 58
- Autoplay decisions: 851
- Autoplay move decisions: 121
- Autoplay target mismatches: 620
- Autoplay move-target mismatches: 13
- Autoplay applied-slot mismatches: 13
- Collision analyses: 4/5
- Avg collision overlap area: 26.5
- Avg active traffic at collision: 11.2
- Lane-change probes: 742
- Lane-change transitions: 121
- Lane-change intersection probes: 2
- Lane-change unsafe-path probes: 1
- Max lane-change path danger: 0.8
- Last pre-crash probe intersected traffic: 2/5
- Collision last-decision sources: {'debug_autoplay_live_hazards': 4}
- Collision last-decision statuses: {'move': 4}
- Autoplay decision sources: {'debug_autoplay_latest_wave': 182, 'debug_autoplay_live_hazards': 669}
- Autoplay decision statuses: {'already_at_target': 675, 'move': 121, 'no_reachable_slots': 49, 'no_transition_safe_slots': 6}
- Terminal reasons: {'escaped': 1, 'traffic': 4}
- Pattern mix: {'denseClusters': 39, 'recoveryWave': 1, 'sparseLanes': 27, 'staggeredCars': 50}

| File | Level | Vehicle | Seed | Terminal | Completed | Time | Waves | Near misses | Cash | Wanted | Collision rects | Collision analysis | Active traffic | Lane probes | Probe intersections | Decisions | Target mismatch | Applied mismatch |
|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---:|---:|---:|---:|---:|
| 01-2026-06-22_20-27-48-la_01-starter_compact-17033032432948541392.jsonl | la_01 | starter_compact | 17033032432948541392 | traffic | false | 5.0 | 5 | 0 | 6 | 1 | true | true | true | 17 | 0 | 34 | 12 | 0 |
| 02-2026-06-22_20-27-57-la_01-starter_compact-17033032432948549311.jsonl | la_01 | starter_compact | 17033032432948549311 | traffic | false | 30.0 | 25 | 13 | 99 | 3 | true | true | true | 178 | 1 | 188 | 140 | 7 |
| 03-2026-06-22_20-28-31-la_01-starter_compact-17033032432948557230.jsonl | la_01 | starter_compact | 17033032432948557230 | traffic | false | 20.5 | 16 | 3 | 31 | 2 | true | true | true | 109 | 1 | 131 | 104 | 0 |
| 04-2026-06-22_20-28-55-la_01-starter_compact-17033032432948565149.jsonl | la_01 | starter_compact | 17033032432948565149 | traffic | false | 33.6 | 32 | 8 | 68 | 3 | true | true | true | 169 | 0 | 218 | 169 | 1 |
| 05-2026-06-22_20-29-31-la_01-starter_compact-17033032432948573068.jsonl | la_01 | starter_compact | 17033032432948573068 | escaped | true | 44.7 | 39 | 8 | 86 | 3 | false | false | true | 269 | 0 | 280 | 195 | 5 |
