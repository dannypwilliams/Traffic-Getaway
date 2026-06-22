import Foundation

public enum PlayerCommand: String, Codable, Equatable {
    case moveLeft
    case moveRight
    case fastMoveLeft
    case fastMoveRight
    case beginHoldLeft
    case beginHoldRight
    case endHold
}

public enum CrashCause: String, Codable, Equatable {
    case traffic
    case roadblock
}

public enum RunOutcome: Codable, Equatable {
    case running
    case escaped
    case crashed(cause: CrashCause)
    case captured
    case missedExit
}

public enum RunEvent: String, Codable, Equatable {
    case nearMiss
    case trafficCollision
    case roadblockCollision
}

public struct RecordedCommand: Codable, Equatable {
    public let frameIndex: UInt64
    public let command: PlayerCommand

    public init(frameIndex: UInt64, command: PlayerCommand) {
        self.frameIndex = frameIndex
        self.command = command
    }
}

public struct RecordedStateHash: Codable, Equatable {
    public let frameIndex: UInt64
    public let hash: UInt64

    public init(frameIndex: UInt64, hash: UInt64) {
        self.frameIndex = frameIndex
        self.hash = hash
    }
}

public struct RecordedRunEvent: Codable, Equatable {
    public let frameIndex: UInt64
    public let event: RunEvent

    public init(frameIndex: UInt64, event: RunEvent) {
        self.frameIndex = frameIndex
        self.event = event
    }
}

public struct RunConfigurationRecord: Codable, Equatable {
    public let levelID: String
    public let cityID: RunCity
    public let vehicleID: String
    public let seed: UInt64
    public let startingSlot: Int
    public let simulationVersion: Int
    public let trafficPatternLibraryVersion: Int
    public let fixedStep: Double
    public let exitSide: ExitSide
    public let exitWarningFrame: UInt64
    public let exitDeadlineFrame: UInt64
    public let capturePressureThreshold: Double

    public init(
        levelID: String,
        cityID: RunCity,
        vehicleID: String,
        seed: UInt64,
        startingSlot: Int = LaneModel.startSlot,
        simulationVersion: Int = 1,
        trafficPatternLibraryVersion: Int = 1,
        fixedStep: Double = 1.0 / 60.0,
        exitSide: ExitSide,
        exitWarningFrame: UInt64,
        exitDeadlineFrame: UInt64,
        capturePressureThreshold: Double = 1.0
    ) {
        self.levelID = levelID
        self.cityID = cityID
        self.vehicleID = vehicleID
        self.seed = seed
        self.startingSlot = startingSlot
        self.simulationVersion = simulationVersion
        self.trafficPatternLibraryVersion = trafficPatternLibraryVersion
        self.fixedStep = fixedStep
        self.exitSide = exitSide
        self.exitWarningFrame = exitWarningFrame
        self.exitDeadlineFrame = exitDeadlineFrame
        self.capturePressureThreshold = capturePressureThreshold
    }

    public init(level: LevelDefinition, vehicle: VehicleDefinition, seed: UInt64, fixedStep: Double = 1.0 / 60.0) {
        self.init(
            levelID: level.levelID,
            cityID: level.city,
            vehicleID: vehicle.id,
            seed: seed,
            fixedStep: fixedStep,
            exitSide: level.exitSide,
            exitWarningFrame: UInt64((level.durationBeforeExit / fixedStep).rounded()),
            exitDeadlineFrame: UInt64(((level.durationBeforeExit + level.exitWindowSeconds) / fixedStep).rounded())
        )
    }

    private enum CodingKeys: String, CodingKey {
        case levelID
        case cityID
        case vehicleID
        case seed
        case startingSlot
        case simulationVersion
        case trafficPatternLibraryVersion
        case fixedStep
        case exitSide
        case exitWarningFrame
        case exitDeadlineFrame
        case capturePressureThreshold
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        levelID = try container.decode(String.self, forKey: .levelID)
        cityID = try container.decode(RunCity.self, forKey: .cityID)
        vehicleID = try container.decode(String.self, forKey: .vehicleID)
        seed = try container.decode(UInt64.self, forKey: .seed)
        startingSlot = try container.decodeIfPresent(Int.self, forKey: .startingSlot) ?? LaneModel.startSlot
        simulationVersion = try container.decodeIfPresent(Int.self, forKey: .simulationVersion) ?? 1
        trafficPatternLibraryVersion = try container.decodeIfPresent(Int.self, forKey: .trafficPatternLibraryVersion) ?? 1
        fixedStep = try container.decode(Double.self, forKey: .fixedStep)
        exitSide = try container.decode(ExitSide.self, forKey: .exitSide)
        exitWarningFrame = try container.decode(UInt64.self, forKey: .exitWarningFrame)
        exitDeadlineFrame = try container.decode(UInt64.self, forKey: .exitDeadlineFrame)
        capturePressureThreshold = try container.decodeIfPresent(Double.self, forKey: .capturePressureThreshold) ?? 1.0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(levelID, forKey: .levelID)
        try container.encode(cityID, forKey: .cityID)
        try container.encode(vehicleID, forKey: .vehicleID)
        try container.encode(seed, forKey: .seed)
        try container.encode(startingSlot, forKey: .startingSlot)
        try container.encode(simulationVersion, forKey: .simulationVersion)
        try container.encode(trafficPatternLibraryVersion, forKey: .trafficPatternLibraryVersion)
        try container.encode(fixedStep, forKey: .fixedStep)
        try container.encode(exitSide, forKey: .exitSide)
        try container.encode(exitWarningFrame, forKey: .exitWarningFrame)
        try container.encode(exitDeadlineFrame, forKey: .exitDeadlineFrame)
        try container.encode(capturePressureThreshold, forKey: .capturePressureThreshold)
    }
}

public struct RunReplay: Codable, Equatable {
    public let simulationVersion: Int
    public let configuration: RunConfigurationRecord
    public let seed: UInt64
    public let commands: [RecordedCommand]
    public let events: [RecordedRunEvent]
    public let expectedOutcome: RunOutcome
    public let expectedScore: Int
    public let stateHashes: [RecordedStateHash]

    public init(
        simulationVersion: Int,
        configuration: RunConfigurationRecord,
        seed: UInt64,
        commands: [RecordedCommand],
        events: [RecordedRunEvent] = [],
        expectedOutcome: RunOutcome,
        expectedScore: Int,
        stateHashes: [RecordedStateHash]
    ) {
        self.simulationVersion = simulationVersion
        self.configuration = configuration
        self.seed = seed
        self.commands = commands
        self.events = events
        self.expectedOutcome = expectedOutcome
        self.expectedScore = expectedScore
        self.stateHashes = stateHashes
    }

    private enum CodingKeys: String, CodingKey {
        case simulationVersion
        case configuration
        case seed
        case commands
        case events
        case expectedOutcome
        case expectedScore
        case stateHashes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simulationVersion = try container.decode(Int.self, forKey: .simulationVersion)
        configuration = try container.decode(RunConfigurationRecord.self, forKey: .configuration)
        seed = try container.decode(UInt64.self, forKey: .seed)
        commands = try container.decode([RecordedCommand].self, forKey: .commands)
        events = try container.decodeIfPresent([RecordedRunEvent].self, forKey: .events) ?? []
        expectedOutcome = try container.decode(RunOutcome.self, forKey: .expectedOutcome)
        expectedScore = try container.decode(Int.self, forKey: .expectedScore)
        stateHashes = try container.decode([RecordedStateHash].self, forKey: .stateHashes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(simulationVersion, forKey: .simulationVersion)
        try container.encode(configuration, forKey: .configuration)
        try container.encode(seed, forKey: .seed)
        try container.encode(commands, forKey: .commands)
        try container.encode(events, forKey: .events)
        try container.encode(expectedOutcome, forKey: .expectedOutcome)
        try container.encode(expectedScore, forKey: .expectedScore)
        try container.encode(stateHashes, forKey: .stateHashes)
    }
}

public struct LaneStaleConfiguration: Codable, Equatable {
    public let warningThreshold: Double
    public let penaltyThreshold: Double
    public let recoveryRate: Double
    public let maximumEffect: Double
    public let meaningfulMovementSlots: Int

    public init(
        warningThreshold: Double = 2.0,
        penaltyThreshold: Double = 4.0,
        recoveryRate: Double = 1.6,
        maximumEffect: Double = 1.0,
        meaningfulMovementSlots: Int = 2
    ) {
        self.warningThreshold = warningThreshold
        self.penaltyThreshold = penaltyThreshold
        self.recoveryRate = recoveryRate
        self.maximumEffect = maximumEffect
        self.meaningfulMovementSlots = meaningfulMovementSlots
    }
}

public struct LaneStaleState: Codable, Equatable {
    public private(set) var currentSlot: Int
    public private(set) var timeInSlotRegion: Double
    public private(set) var effect: Double

    public init(currentSlot: Int = LaneModel.startSlot, timeInSlotRegion: Double = 0, effect: Double = 0) {
        self.currentSlot = currentSlot
        self.timeInSlotRegion = timeInSlotRegion
        self.effect = effect
    }

    public var isWarningActive: Bool {
        timeInSlotRegion >= LaneStaleConfiguration().warningThreshold
    }

    public mutating func step(slot: Int, previousSlot: Int, deltaTime: Double, configuration: LaneStaleConfiguration = LaneStaleConfiguration()) {
        let movedMeaningfully = abs(slot - previousSlot) >= configuration.meaningfulMovementSlots
        if movedMeaningfully {
            currentSlot = slot
            timeInSlotRegion = max(0, timeInSlotRegion - configuration.recoveryRate)
            effect = max(0, effect - configuration.recoveryRate * 0.4)
            return
        }

        timeInSlotRegion += deltaTime
        if timeInSlotRegion >= configuration.penaltyThreshold {
            let excess = timeInSlotRegion - configuration.penaltyThreshold
            effect = min(configuration.maximumEffect, excess / max(0.1, configuration.penaltyThreshold))
        }
    }
}

public struct FlowConfiguration: Codable, Equatable {
    public let passiveDecayPerSecond: Double
    public let cleanShiftGain: Double
    public let fastShiftGain: Double
    public let nearMissGain: Double
    public let collisionLoss: Double
    public let maximum: Double

    public init(
        passiveDecayPerSecond: Double = 0.035,
        cleanShiftGain: Double = 0.08,
        fastShiftGain: Double = 0.12,
        nearMissGain: Double = 0.18,
        collisionLoss: Double = 0.45,
        maximum: Double = 1.0
    ) {
        self.passiveDecayPerSecond = passiveDecayPerSecond
        self.cleanShiftGain = cleanShiftGain
        self.fastShiftGain = fastShiftGain
        self.nearMissGain = nearMissGain
        self.collisionLoss = collisionLoss
        self.maximum = maximum
    }
}

public struct FlowState: Codable, Equatable {
    public private(set) var value: Double

    public init(value: Double = 0) {
        self.value = max(0, value)
    }

    public mutating func step(deltaTime: Double, laneStaleEffect: Double, configuration: FlowConfiguration = FlowConfiguration()) {
        let decay = configuration.passiveDecayPerSecond * (1 + laneStaleEffect) * deltaTime
        value = max(0, value - decay)
    }

    public mutating func recordCleanShift(fast: Bool, configuration: FlowConfiguration = FlowConfiguration()) {
        value = min(configuration.maximum, value + (fast ? configuration.fastShiftGain : configuration.cleanShiftGain))
    }

    public mutating func recordNearMiss(configuration: FlowConfiguration = FlowConfiguration()) {
        value = min(configuration.maximum, value + configuration.nearMissGain)
    }

    public mutating func recordCollision(configuration: FlowConfiguration = FlowConfiguration()) {
        value = max(0, value - configuration.collisionLoss)
    }
}

public struct PursuitPressureConfiguration: Codable, Equatable {
    public let passiveGainPerSecond: Double
    public let staleGainPerSecond: Double
    public let lowFlowGainPerSecond: Double
    public let highFlowRecoveryPerSecond: Double
    public let nearMissRecovery: Double
    public let captureThreshold: Double

    public init(
        passiveGainPerSecond: Double = 0.055,
        staleGainPerSecond: Double = 0.095,
        lowFlowGainPerSecond: Double = 0.04,
        highFlowRecoveryPerSecond: Double = 0.07,
        nearMissRecovery: Double = 0.08,
        captureThreshold: Double = 1.0
    ) {
        self.passiveGainPerSecond = passiveGainPerSecond
        self.staleGainPerSecond = staleGainPerSecond
        self.lowFlowGainPerSecond = lowFlowGainPerSecond
        self.highFlowRecoveryPerSecond = highFlowRecoveryPerSecond
        self.nearMissRecovery = nearMissRecovery
        self.captureThreshold = captureThreshold
    }
}

public struct PursuitPressureState: Codable, Equatable {
    public private(set) var value: Double

    public init(value: Double = 0.18) {
        self.value = max(0, min(1, value))
    }

    public var isCaptured: Bool {
        value >= PursuitPressureConfiguration().captureThreshold
    }

    public mutating func step(flow: Double, laneStaleEffect: Double, deltaTime: Double, configuration: PursuitPressureConfiguration = PursuitPressureConfiguration()) {
        let lowFlow = max(0, 0.45 - flow)
        let gain = configuration.passiveGainPerSecond
            + laneStaleEffect * configuration.staleGainPerSecond
            + lowFlow * configuration.lowFlowGainPerSecond
        let recovery = max(0, flow - 0.62) * configuration.highFlowRecoveryPerSecond
        value = max(0, min(configuration.captureThreshold, value + (gain - recovery) * deltaTime))
    }

    public mutating func recordNearMiss(configuration: PursuitPressureConfiguration = PursuitPressureConfiguration()) {
        value = max(0, value - configuration.nearMissRecovery)
    }

    public mutating func recordCollision() {
        value = 1
    }
}

public struct RunStateSnapshot: Codable, Equatable {
    public let frameIndex: UInt64
    public let playerSlot: Int
    public let flow: Double
    public let laneStaleEffect: Double
    public let pursuitPressure: Double
    public let nearMissCount: Int
    public let highestCombo: Int
    public let score: Int
    public let outcome: RunOutcome

    public var stableHash: UInt64 {
        var hash: UInt64 = 1469598103934665603
        mix(frameIndex, into: &hash)
        mix(UInt64(max(0, playerSlot)), into: &hash)
        mix(UInt64((flow * 10_000).rounded()), into: &hash)
        mix(UInt64((laneStaleEffect * 10_000).rounded()), into: &hash)
        mix(UInt64((pursuitPressure * 10_000).rounded()), into: &hash)
        mix(UInt64(max(0, nearMissCount)), into: &hash)
        mix(UInt64(max(0, highestCombo)), into: &hash)
        mix(UInt64(max(0, score)), into: &hash)
        mix(outcomeCode, into: &hash)
        return hash
    }

    private var outcomeCode: UInt64 {
        switch outcome {
        case .running:
            return 0
        case .escaped:
            return 1
        case .crashed(let cause):
            return cause == .traffic ? 2 : 3
        case .captured:
            return 4
        case .missedExit:
            return 5
        }
    }

    private func mix(_ value: UInt64, into hash: inout UInt64) {
        hash ^= value
        hash = hash &* 1099511628211
    }
}

public final class FixedStepRunSimulation {
    public private(set) var frameIndex: UInt64 = 0
    public private(set) var playerSlot: Int
    public private(set) var score: Int = 0
    public private(set) var outcome: RunOutcome = .running
    public private(set) var laneStale: LaneStaleState
    public private(set) var flow = FlowState()
    public private(set) var pursuit = PursuitPressureState()
    public private(set) var nearMissCount = 0
    public private(set) var comboCount = 0
    public private(set) var highestCombo = 0

    private let configuration: RunConfigurationRecord
    private let vehicle: VehicleDefinition
    private var commandQueue: [UInt64: [PlayerCommand]] = [:]
    private var eventQueue: [UInt64: [RunEvent]] = [:]
    private var holdDirection = 0
    private var comboFramesRemaining: UInt64 = 0

    public init(configuration: RunConfigurationRecord, vehicle: VehicleDefinition) {
        self.configuration = configuration
        self.vehicle = vehicle
        self.playerSlot = LaneModel.clampSlot(configuration.startingSlot, for: vehicle.vehicleClass)
        self.laneStale = LaneStaleState(currentSlot: playerSlot)
        self.pursuit = PursuitPressureState(value: min(0.22, configuration.capturePressureThreshold * 0.22))
    }

    public func enqueue(_ command: PlayerCommand, forFrame frame: UInt64) {
        commandQueue[frame, default: []].append(command)
    }

    public func enqueue(_ event: RunEvent, forFrame frame: UInt64) {
        eventQueue[frame, default: []].append(event)
    }

    public func step() {
        guard case .running = outcome else { return }

        let previousSlot = playerSlot
        var moved = false
        let commands = commandQueue.removeValue(forKey: frameIndex) ?? []
        for command in commands {
            moved = apply(command) || moved
        }

        if holdDirection != 0, frameIndex.isMultiple(of: 12) {
            moved = move(bySlots: holdDirection) || moved
        }

        if comboFramesRemaining > 0 {
            comboFramesRemaining -= 1
            if comboFramesRemaining == 0 {
                comboCount = 0
            }
        }

        let events = eventQueue.removeValue(forKey: frameIndex) ?? []
        for event in events {
            apply(event)
        }

        guard case .running = outcome else {
            frameIndex += 1
            return
        }

        laneStale.step(slot: playerSlot, previousSlot: previousSlot, deltaTime: configuration.fixedStep)
        flow.step(deltaTime: configuration.fixedStep, laneStaleEffect: laneStale.effect)
        pursuit.step(flow: flow.value, laneStaleEffect: laneStale.effect, deltaTime: configuration.fixedStep)

        if moved {
            score += Int((8 + flow.value * 12).rounded())
        }

        if pursuit.value >= configuration.capturePressureThreshold {
            outcome = .captured
        } else if frameIndex >= configuration.exitWarningFrame,
                  LaneModel.exitSlots(for: configuration.exitSide, vehicleClass: vehicle.vehicleClass).contains(playerSlot) {
            outcome = .escaped
        } else if frameIndex > configuration.exitDeadlineFrame {
            outcome = .missedExit
        }

        frameIndex += 1
    }

    public func makeSnapshot() -> RunStateSnapshot {
        RunStateSnapshot(
            frameIndex: frameIndex,
            playerSlot: playerSlot,
            flow: flow.value,
            laneStaleEffect: laneStale.effect,
            pursuitPressure: pursuit.value,
            nearMissCount: nearMissCount,
            highestCombo: highestCombo,
            score: score,
            outcome: outcome
        )
    }

    private func apply(_ command: PlayerCommand) -> Bool {
        switch command {
        case .moveLeft:
            return move(bySlots: vehicle.vehicleClass == .car ? -2 : -1)
        case .moveRight:
            return move(bySlots: vehicle.vehicleClass == .car ? 2 : 1)
        case .fastMoveLeft:
            return move(bySlots: vehicle.vehicleClass == .car ? -4 : -3, fast: true)
        case .fastMoveRight:
            return move(bySlots: vehicle.vehicleClass == .car ? 4 : 3, fast: true)
        case .beginHoldLeft:
            holdDirection = vehicle.vehicleClass == .car ? -2 : -1
            return false
        case .beginHoldRight:
            holdDirection = vehicle.vehicleClass == .car ? 2 : 1
            return false
        case .endHold:
            holdDirection = 0
            return false
        }
    }

    private func move(bySlots slotDelta: Int, fast: Bool = false) -> Bool {
        let target = LaneModel.targetSlot(from: playerSlot, delta: slotDelta, vehicleClass: vehicle.vehicleClass)
        guard target != playerSlot else { return false }
        playerSlot = target
        flow.recordCleanShift(fast: fast)
        return true
    }

    private func apply(_ event: RunEvent) {
        switch event {
        case .nearMiss:
            nearMissCount += 1
            comboCount = comboFramesRemaining > 0 ? comboCount + 1 : 1
            highestCombo = max(highestCombo, comboCount)
            comboFramesRemaining = UInt64((2.5 / configuration.fixedStep).rounded())
            flow.recordNearMiss()
            pursuit.recordNearMiss()
            score += Int((35 + Double(comboCount) * 12 + flow.value * 18).rounded())
        case .trafficCollision:
            flow.recordCollision()
            pursuit.recordCollision()
            outcome = .crashed(cause: .traffic)
        case .roadblockCollision:
            flow.recordCollision()
            pursuit.recordCollision()
            outcome = .crashed(cause: .roadblock)
        }
    }
}

public enum ExitRoutePlanner {
    public static func commands(
        from startingSlot: Int,
        to exitSide: ExitSide,
        vehicleClass: VehicleClass,
        firstFrame: UInt64 = 0,
        frameStride: UInt64 = 1
    ) -> [RecordedCommand] {
        let exitSlots = LaneModel.exitSlots(for: exitSide, vehicleClass: vehicleClass)
        var slot = LaneModel.clampSlot(startingSlot, for: vehicleClass)
        guard !exitSlots.contains(slot) else { return [] }

        var commands: [RecordedCommand] = []
        var frame = firstFrame
        var guardCount = 0
        while !exitSlots.contains(slot) && guardCount < LaneModel.slotCount {
            let target = nearestExitSlot(to: slot, exitSlots: exitSlots)
            let delta = target - slot
            let command: PlayerCommand
            let slotDelta: Int
            switch vehicleClass {
            case .car:
                if abs(delta) >= 4 {
                    command = delta < 0 ? .fastMoveLeft : .fastMoveRight
                    slotDelta = delta < 0 ? -4 : 4
                } else {
                    command = delta < 0 ? .moveLeft : .moveRight
                    slotDelta = delta < 0 ? -2 : 2
                }
            case .motorcycle:
                if abs(delta) >= 3 {
                    command = delta < 0 ? .fastMoveLeft : .fastMoveRight
                    slotDelta = delta < 0 ? -3 : 3
                } else {
                    command = delta < 0 ? .moveLeft : .moveRight
                    slotDelta = delta < 0 ? -1 : 1
                }
            }

            commands.append(RecordedCommand(frameIndex: frame, command: command))
            slot = LaneModel.targetSlot(from: slot, delta: slotDelta, vehicleClass: vehicleClass)
            frame += frameStride
            guardCount += 1
        }

        return commands
    }

    private static func nearestExitSlot(to slot: Int, exitSlots: Set<Int>) -> Int {
        exitSlots.min { lhs, rhs in
            let lhsDistance = abs(lhs - slot)
            let rhsDistance = abs(rhs - slot)
            if lhsDistance == rhsDistance {
                return lhs < rhs
            }
            return lhsDistance < rhsDistance
        } ?? slot
    }
}

public enum RunReplayVerifier {
    public static func replay(_ replay: RunReplay, vehicle: VehicleDefinition) -> (matches: Bool, snapshot: RunStateSnapshot) {
        let simulation = FixedStepRunSimulation(configuration: replay.configuration, vehicle: vehicle)
        for command in replay.commands {
            simulation.enqueue(command.command, forFrame: command.frameIndex)
        }
        for event in replay.events {
            simulation.enqueue(event.event, forFrame: event.frameIndex)
        }

        let finalFrame = [
            replay.configuration.exitDeadlineFrame + 1,
            replay.commands.map(\.frameIndex).max() ?? 0,
            replay.events.map(\.frameIndex).max() ?? 0,
            replay.stateHashes.map(\.frameIndex).max() ?? 0
        ].max() ?? 0
        var recordedHashes: [RecordedStateHash] = []
        while simulation.frameIndex <= finalFrame {
            if replay.stateHashes.contains(where: { $0.frameIndex == simulation.frameIndex }) {
                let snapshot = simulation.makeSnapshot()
                recordedHashes.append(RecordedStateHash(frameIndex: snapshot.frameIndex, hash: snapshot.stableHash))
            }
            simulation.step()
            if simulation.outcome != .running {
                if replay.stateHashes.contains(where: { $0.frameIndex == simulation.frameIndex }) {
                    let snapshot = simulation.makeSnapshot()
                    recordedHashes.append(RecordedStateHash(frameIndex: snapshot.frameIndex, hash: snapshot.stableHash))
                }
                break
            }
        }

        let snapshot = simulation.makeSnapshot()
        let hashesMatch = recordedHashes == replay.stateHashes
        return (hashesMatch && snapshot.outcome == replay.expectedOutcome && snapshot.score == replay.expectedScore, snapshot)
    }
}
