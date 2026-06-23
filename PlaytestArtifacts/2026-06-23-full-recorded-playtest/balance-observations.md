# Balance Observations

## Current Status

Six valid active-input LA01 Starter Compact manual runs are available, five with complete video/screenshot/telemetry evidence and one supplemental active run missing the result screenshot. Three complete-evidence active-input LA01 Starter Bike runs are also available. No global balance conclusion should be drawn until the required city/vehicle matrix is captured, but the opening LA01 slices now show strong first-level completion concerns.

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
- Current LA01 active slices are valid evidence for first-level concerns, but they still cover only one level, one device, and one control mode.

## Manual LA01 Starter Bike Slice

- Level/vehicle: `la_01` / Starter Bike.
- Device: iPhone 17e simulator.
- Runs: 3 complete-evidence active-input runs counted for the LA Starter Bike requirement.
- Result: 0/3 completed; terminal reasons were traffic collision twice and roadblock once.
- Avg terminal time: 27.5s; median terminal time: 21.1s.
- Active input: 13 lane changes, 43 lane-change probes, 0 autoplay decisions.
- Near misses/cash: average 5.3 near misses and 51 cash.
- Fairness signal: collision analysis present in 3/3, 0 lane-change intersection probes, 0 unsafe-path probes in the counted set.
- Read: Starter Bike survives longer than Starter Compact and can reach exit countdown, but this slice still failed to complete LA01 in 3/3 complete-evidence samples.

## Simulation Comparison

- Default GameSim previously reported LA01 Starter Compact completion around 99% with high near misses and high cash.
- Recorded iPhone 17e active Starter Compact play now shows 0/6 completion and sub-10-second traffic terminals.
- Recorded iPhone 17e active Starter Bike play shows 0/3 completion in the counted complete-evidence set, with one run reaching the exit countdown at 50.2s before traffic collision.
- Interpretation: sim/live/manual difficulty are not reconciled. Do not tune from simulation alone.

## Required Next Evidence

- Start-gated active iPhone 17e runs for every city.
- Start-gated Dynamic Island-class control/safe-area coverage.
- Starter Compact and Starter Bike runs with complete video, telemetry, summary, and observations.
- City progression attempts that show whether rewards/unlocks are understandable and whether grinding is required.

## Recommendations

Do not tune rewards, traffic density, city difficulty, or progression from this scaffold alone. Capture the required active-run evidence first.
