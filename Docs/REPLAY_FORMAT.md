# Replay Format

## Purpose

Replays are developer-facing proof that authoritative run logic can be reproduced from:

- Simulation version.
- Run configuration.
- Seed.
- Ordered input commands.

They are not a user-facing replay viewer in this milestone.

## Schema

`RunReplay` lives in `GameCore/Sources/GameCore/RunSimulation.swift`.

Fields:

- `simulationVersion`: integer version for compatibility.
- `configuration`: `RunConfigurationRecord`.
- `seed`: stable run seed.
- `commands`: ordered `RecordedCommand` values.
- `expectedOutcome`: terminal `RunOutcome`.
- `expectedScore`: terminal score.
- `stateHashes`: optional checkpoints as `RecordedStateHash`.

## Run Configuration

`RunConfigurationRecord` includes:

- Level ID.
- City ID.
- Vehicle ID.
- Seed.
- Simulation version.
- Traffic pattern library version.
- Fixed step.
- Exit side.
- Exit warning frame.
- Exit deadline frame.
- Capture pressure threshold.

## Commands

Commands are frame-indexed, not wall-clock timed:

- `moveLeft`
- `moveRight`
- `fastMoveLeft`
- `fastMoveRight`
- `beginHoldLeft`
- `beginHoldRight`
- `endHold`

If multiple commands are recorded on the same frame, preserve their order.

## Outcomes

`RunOutcome` currently supports:

- `running`
- `escaped`
- `crashed(cause:)`
- `captured`
- `missedExit`

Only terminal outcomes should be stored as replay expectations.

## State Hashing

`RunStateSnapshot.stableHash` uses a stable FNV-style mix over:

- Frame index.
- Player slot.
- Flow.
- Lane-stale effect.
- Pursuit pressure.
- Score.
- Outcome code.

Do not use Swift `Hasher` for replay compatibility because it is intentionally process-randomized.

## Compatibility Rules

- Increment `simulationVersion` when replay-affecting logic changes.
- Increment `trafficPatternLibraryVersion` when committed pattern behavior changes.
- Old replays may remain useful as migration fixtures, but should not be silently treated as current proof after a version change.

## Test Invocation

When Swift is available:

```bash
cd GameCore
swift test
```

The first fixed-step replay fixture is `testFixedStepReplayMatchesCleanExit` in `GameCore/Tests/GameCoreTests/GameCoreTests.swift`.
