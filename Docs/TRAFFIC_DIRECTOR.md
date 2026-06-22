# Traffic Director

## Current Model

Traffic Getaway currently has two traffic-planning implementations:

- App-local SpriteKit integration in `Traffic Getaway/TrafficPatternGenerator.swift` and `Traffic Getaway/TrafficSafetyAnalyzer.swift`.
- Pure Swift equivalents in `GameCore/Sources/GameCore/TrafficPatternGenerator.swift` and `GameCore/Sources/GameCore/TrafficSafety.swift`.

The production direction is for `GameCore` to own deterministic planning and validation, with the SpriteKit scene rendering committed wave plans.

## Deterministic Generation

The pure traffic path accepts a `SeededRNG` owned by the run. The same level, vehicle, seed, and ordered command stream must produce the same traffic plan sequence.

Do not use these as authoritative gameplay inputs:

- `Int.random`
- `Double.random`
- `Float.random`
- `arc4random`
- wall-clock time
- UUID ordering
- unordered set or dictionary traversal

Cosmetic randomness should use a derived stream, for example:

```swift
let trafficRNG = runRNG.derivedStream(named: "traffic")
let cosmeticRNG = runRNG.derivedStream(named: "cosmetic")
```

## Pattern Families

The current pattern family names are implementation-level and should be migrated toward production names:

- Sparse/open lanes -> Open Weave / Recovery Window.
- Staggered cars -> Staggered Traffic.
- Dense clusters / taxi swarm / compact pack -> Narrowing Squeeze.
- Sports burst / fast lane burst -> Moving Gap.
- Truck wall / hauler wall -> Split Decision with a required gap.
- Police pressure -> Pressure Wave.
- Exit-active protected lanes -> Exit Funnel.

Every new pattern must declare:

- Density band.
- Vehicle lanes and lane spans.
- Minimum safe slots for cars and motorcycles.
- Whether it supports an exit target.
- Required recovery afterward.
- Retry/fallback behavior.

## Reachability Algorithm

The current validator is a bounded slot-reachability check:

1. Convert planned traffic into occupied lanes and blocked slots.
2. Compute safe car slots and safe motorcycle slots.
3. Compute the reachable range from the current player slot.
4. Reject waves without enough safe slots.
5. Reject waves with no reachable safe slot.
6. During exits, reject waves without a reachable exit-side route.

The next production step is a graph validator across time slices:

- Node: legal road slot at a time slice.
- Edge: wait, move one slot/lane, fast move, or held movement.
- Invalid node: occupied by a traffic envelope or outside topology.
- Invalid edge: movement cannot complete before collision or violates cooldown.

## Fallback Behavior

When candidate generation fails, the director must use a known-safe recovery wave rather than committing an invalid wave and moving it after spawn.

Current behavior:

- Retry generation a bounded number of times.
- Commit the first valid plan.
- Use a recovery wave with fewer blockers if retries fail.
- Record the rejection reason on the returned plan.

## Adding A Pattern Safely

1. Add the pattern to the pure `GameCore` generator first.
2. Add a reachability test for cars.
3. Add a reachability test for motorcycles if the pattern can appear after the starter bike unlock.
4. Add an exit-target test if the pattern can appear during an exit.
5. Run the seeded stress command in `GameSim`.
6. Only then mirror or adopt the pattern in SpriteKit presentation.

## Debugging A Bad Seed

Record:

- Run seed.
- Level ID.
- Vehicle ID.
- Simulation frame.
- Player slot.
- Pattern name.
- Rejection reason.
- Occupied lanes.
- Safe car slots.
- Safe motorcycle slots.
- Exit side and target slots.

If a committed wave has no route, reduce it to the smallest failing pattern and add a regression test before tuning around it.
