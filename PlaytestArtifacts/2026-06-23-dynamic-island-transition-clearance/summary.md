# Run Telemetry Summary

- Runs: 5
- Completed: 3/5 (60.0%)
- Avg terminal time: 38.9s
- Median terminal time: 42.3s
- Avg first crash: 32.3s
- Median first crash: 32.3s
- Avg traffic waves: 33.6
- Avg near misses: 16.6
- Avg cash: 118
- Autoplay decisions: 1182
- Autoplay move decisions: 198
- Autoplay target mismatches: 833
- Autoplay move-target mismatches: 21
- Autoplay applied-slot mismatches: 21
- Collision analyses: 2/5
- Avg collision overlap area: 10.3
- Avg active traffic at collision: 5.6
- Lane-change probes: 1039
- Lane-change transitions: 198
- Lane-change intersection probes: 0
- Lane-change unsafe-path probes: 1
- Max lane-change path danger: 1.0
- Last pre-crash probe intersected traffic: 0/5
- Collision last-decision sources: {'debug_autoplay_live_hazards': 2}
- Collision last-decision statuses: {'no_transition_safe_slots': 2}
- Autoplay decision sources: {'debug_autoplay_latest_wave': 254, 'debug_autoplay_live_hazards': 928}
- Autoplay decision statuses: {'already_at_target': 918, 'move': 198, 'no_reachable_slots': 43, 'no_transition_safe_slots': 23}
- Terminal reasons: {'escaped': 3, 'traffic': 2}
- Pattern mix: {'denseClusters': 66, 'recoveryWave': 1, 'sparseLanes': 49, 'staggeredCars': 52}

| File | Level | Vehicle | Seed | Terminal | Completed | Time | Waves | Near misses | Cash | Wanted | Collision rects | Collision analysis | Active traffic | Lane probes | Probe intersections | Decisions | Target mismatch | Applied mismatch |
|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---:|---:|---:|---:|---:|
| 01-2026-06-22_21-03-13-la_01-starter_compact-17033032432948192956.jsonl | la_01 | starter_compact | 17033032432948192956 | traffic | false | 23.4 | 20 | 13 | 70 | 3 | true | true | true | 133 | 0 | 147 | 96 | 2 |
| 02-2026-06-22_21-04-06-la_01-starter_compact-17033032432948200875.jsonl | la_01 | starter_compact | 17033032432948200875 | escaped | true | 42.3 | 32 | 21 | 148 | 3 | false | false | true | 239 | 0 | 256 | 173 | 7 |
| 03-2026-06-22_21-05-17-la_01-starter_compact-17033032432948208794.jsonl | la_01 | starter_compact | 17033032432948208794 | escaped | true | 43.2 | 36 | 27 | 173 | 3 | false | false | true | 176 | 0 | 259 | 191 | 6 |
| 04-2026-06-22_21-06-17-la_01-starter_compact-17033032432948216713.jsonl | la_01 | starter_compact | 17033032432948216713 | escaped | true | 44.5 | 41 | 13 | 103 | 3 | false | false | true | 272 | 0 | 262 | 183 | 4 |
| 05-2026-06-22_21-07-17-la_01-starter_compact-17033032432948224632.jsonl | la_01 | starter_compact | 17033032432948224632 | traffic | false | 41.2 | 39 | 9 | 94 | 3 | true | true | true | 219 | 0 | 258 | 190 | 2 |
