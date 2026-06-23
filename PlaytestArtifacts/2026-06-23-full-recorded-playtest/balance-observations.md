# Balance Observations

## Current Status

Six valid active-input LA01 Starter Compact manual runs are available, five with complete video/screenshot/telemetry evidence and one supplemental active run missing the result screenshot. No global balance conclusion should be drawn until the required city/vehicle matrix is captured, but the opening LA01 slice now has a strong first-minute concern.

## Manual LA01 Starter Compact Slice

- Level/vehicle: `la_01` / Starter Compact.
- Device: iPhone 17e simulator.
- Runs: 6 active-input runs, 5 complete-evidence runs counted for the LA Starter Compact requirement.
- Result: 0/6 completed, traffic collision in all 6.
- Avg terminal time: 7.6s; median terminal time: 7.5s.
- Active input: 15 lane changes, 27 lane-change probes, 0 autoplay decisions.
- Near misses/cash: average 1.2 near misses and 18 cash.
- Fairness signal: collision analysis present in 6/6, 4 unsafe-path probes, 1 last pre-crash probe intersected traffic.
- Read: this is a strong P1 signal that active LA01 simulator play is currently collapsing much earlier than the intended first-minute target.

## Prior Reference Signals

- Previous GameSim evidence reports `la_01` / `starter_compact` around 99.1% completion with high near misses and high cash, suggesting Level 1 may be too easy and over-rewarding.
- Previous active-traffic diagnostic evidence is too punitive and is explicitly not a balance source.
- Previous debug autoplay evidence is useful for repeatability but is not a proxy for human difficulty.
- Previous ungated active manual iPhone 17e attempt is invalid for balance conclusions because only 1/5 runs had active input.
- Current LA01 active slice is valid evidence for a first-minute concern, but it still covers only one level, one vehicle, one device, and one control mode.

## Simulation Comparison

- Default GameSim previously reported LA01 Starter Compact completion around 99% with high near misses and high cash.
- Recorded iPhone 17e active play now shows 0/6 completion and sub-10-second traffic terminals.
- Interpretation: sim/live/manual difficulty are not reconciled. Do not tune from simulation alone.

## Required Next Evidence

- Start-gated active iPhone 17e runs for every city.
- Start-gated Dynamic Island-class control/safe-area coverage.
- Starter Compact and Starter Bike runs with complete video, telemetry, summary, and observations.
- City progression attempts that show whether rewards/unlocks are understandable and whether grinding is required.

## Recommendations

Do not tune rewards, traffic density, city difficulty, or progression from this scaffold alone. Capture the required active-run evidence first.
