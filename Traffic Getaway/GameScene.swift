import SpriteKit
import UIKit

enum GameState {
    case start
    case playing
    case gameOver
}

enum CityTheme {
    case newYork
    case losAngeles
    case miami

    var title: String {
        switch self {
        case .newYork:
            return "NEW YORK"
        case .losAngeles:
            return "LOS ANGELES"
        case .miami:
            return "MIAMI"
        }
    }

    var audioTheme: AudioManager.CityAudioTheme {
        switch self {
        case .newYork:
            return .newYork
        case .losAngeles:
            return .losAngeles
        case .miami:
            return .miami
        }
    }

    var runCity: RunCity {
        switch self {
        case .newYork:
            return .newYork
        case .losAngeles:
            return .losAngeles
        case .miami:
            return .miami
        }
    }
}

extension RunCity {
    var cityTheme: CityTheme {
        switch self {
        case .newYork:
            return .newYork
        case .losAngeles:
            return .losAngeles
        case .miami:
            return .miami
        }
    }
}

enum VehicleType: String, CaseIterable {
    case sedan
    case compact
    case suv
    case pickup
    case van
    case boxTruck
    case sportCoupe
    case policeMoto
}

private enum RoadEventType: CaseIterable {
    case trafficJam
    case constructionZone
    case vipMotorcade
    case heavyRainTraffic
    case bridgeCrossing
    case tunnelRun

    var title: String {
        switch self {
        case .trafficJam:
            return "TRAFFIC JAM"
        case .constructionZone:
            return "CONSTRUCTION"
        case .vipMotorcade:
            return "VIP MOTORCADE"
        case .heavyRainTraffic:
            return "HEAVY RAIN"
        case .bridgeCrossing:
            return "BRIDGE CROSSING"
        case .tunnelRun:
            return "TUNNEL RUN"
        }
    }
}

private enum ClutchSaveTier {
    case closeCall
    case insaneSave
    case threadingNeedle

    var title: String {
        switch self {
        case .closeCall:
            return "CLOSE CALL"
        case .insaneSave:
            return "INSANE SAVE"
        case .threadingNeedle:
            return "THREADING THE NEEDLE"
        }
    }

    var scoreBonus: Int {
        switch self {
        case .closeCall:
            return 75
        case .insaneSave:
            return 150
        case .threadingNeedle:
            return 250
        }
    }

    var cashBonus: Int {
        switch self {
        case .closeCall:
            return 8
        case .insaneSave:
            return 16
        case .threadingNeedle:
            return 28
        }
    }
}

private enum LaneMoveKind {
    case tap
    case swipe
    case fastSwipe
    case hold
}

private enum ExitPhase {
    case inactive
    case active
    case missed
    case completed
}

private typealias ThemePalette = ArcadeArt.RoadPalette

final class GameScene: SKScene {
    private let laneCount = LaneManager.laneCount
    private let gameMode: GameMode
    private let currentLevel: LevelDefinition?

    private let gameCamera = SKCameraNode()
    private let sceneryNode = SKNode()
    private let roadNode = SKNode()
    private let markerNode = SKNode()
    private let speedLineNode = SKNode()
    private let eventNode = SKNode()
    private let exitNode = SKNode()
    private let exitGuidanceNode = SKNode()
    private let trafficNode = SKNode()
    private let policeSupportNode = SKNode()
    private let effectsNode = SKNode()
    private let vehicleNode = SKNode()
    private let floatingTextNode = SKNode()
    private let warningPulseNode = SKNode()
    private let diagnosticOverlayNode = SKNode()
    private let overlayNode = SKNode()
    private let comboAuraNode = SKNode()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let wantedLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let exitHUDLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let distanceLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let cashLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let performanceDebugLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private let scorePanel = SKShapeNode()
    private let comboMeterBack = SKShapeNode()
    private let comboMeterFill = SKShapeNode()
    private let buddy = BuddyManager()

    private let laneHaptic = UIImpactFeedbackGenerator(style: .light)
    private let nearMissHaptic = UIImpactFeedbackGenerator(style: .soft)
    private let warningHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let crashHaptic = UINotificationFeedbackGenerator()

    private var gameState: GameState = .start
    private var currentCity: CityTheme = .losAngeles
    private var currentWorld: WorldTheme = WorldThemeCatalog.defaultTheme
    private var activeCar = CarCatalog.defaultCar
    private var activePaint = CarCatalog.defaultPaint

    private var laneCenters: [CGFloat] = []
    private var slotCenters: [CGFloat] = []
    private var laneManager = LaneManager(roadLeft: 0, roadWidth: 1)
    private var roadLeft: CGFloat = 0
    private var roadWidth: CGFloat = 0
    private var laneWidth: CGFloat = 0
    private var playerY: CGFloat = 0
    private var sceneryRecycleSpan: CGFloat = 0
    private var markerRecycleSpan: CGFloat = 0

    private var playerCar: SKSpriteNode?
    private var policeCar: SKSpriteNode?
    private var policeGap: CGFloat = 180
    private var maxPoliceGap: CGFloat = 185
    private var minPoliceGap: CGFloat = 82
    private var policeClosingSpeed: CGFloat = 3.4

    private var playerSlot = LaneManager.startSlot
    private var playerLane = LaneManager.startLane
    private var score = 0
    private var highScore = SaveManager.shared.data.bestScore
    private var scoreRemainder: CGFloat = 0
    private var totalCash = SaveManager.shared.data.totalCash
    private var runCash = 0
    private var cashRemainder: CGFloat = 0
    private var runDistance: CGFloat = 0
    private var runTime: TimeInterval = 0
    private var nearMissCount = 0
    private var laneSplitCount = 0
    private var clutchSaveCount = 0
    private var comboCount = 0
    private var highestCombo = 0
    private var comboTimer: TimeInterval = 0
    private var comboDuration: TimeInterval {
        if let currentLevel {
            return LevelDifficultyConfig.snapshot(for: currentLevel, elapsed: runTime, exitActive: exitPhase == .active).comboDuration
        }
        return 3.2
    }
    private var wantedLevel = 1
    private var highestWantedLevel = 1
    private var wantedVisualLevel = 1

    private var roadSpeed: CGFloat = 330
    private var trafficSpeed: CGFloat = 275
    private var spawnInterval: TimeInterval = 1.08
    private var spawnTimer: TimeInterval = 0
    private var difficultyTimer: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var smokeTimer: TimeInterval = 0
    private var warningPulseActive = false
    private var warningHapticCooldown: TimeInterval = 0
    private var showingSettings = false
    private var settingsReturnState: GameState = .start
    private var dodgeBoostTimer: TimeInterval = 0
    private var dodgeBoostStreakTimer: TimeInterval = 0
    private var dodgeBoostCount = 0
    private var clutchSaveCooldown: TimeInterval = 0
    private var roadblockCooldown: TimeInterval = 10
    private var currentEvent: RoadEventType?
    private var eventTimer: TimeInterval = 0
    private var eventCooldown: TimeInterval = 16
    private var eventSpawnTimer: TimeInterval = 0
    private var helicopterNode: SKNode?
    private var helicopterAngle: CGFloat = 0
    private var helicopterAudioTimer: TimeInterval = 0
    private var reviveUsed = false
    private var showingReviveOffer = false
    private var pendingCrashPoint: CGPoint?
    private var pendingCrashReason = "collision"
    private var invulnerabilityTimer: TimeInterval = 0
    private var cameraJuicePhase: CGFloat = 0
    private var screenshotShowcaseSpawned = false
    private var latestTrafficPlan: TrafficWavePlan?
    private var lastPoliceBuddyLevel = 1
    private var trafficSpawnSerial = 0
    private var runSeed: UInt64 = 0
    private var trafficPlanRNG = AppSeededRNG(seed: 1)
    private var trafficSpawnRNG = AppSeededRNG(seed: 2)
    private var trafficEventRNG = AppSeededRNG(seed: 3)
    private var debugAutoplayTimer: TimeInterval = 0
    private var performanceSampleTimer: TimeInterval = 0
    private var performanceFrameCounter = 0
    private var awardedLaneSplitPairs: Set<String> = []
    private var primaryExitTriggered = false
    private var emergencyExitUsed = false
    private var emergencyExitTimer: TimeInterval = 0
    private var exitAnticipationShown = false
    private var exitPhase: ExitPhase = .inactive
    private var activeExitSide: ExitSide?
    private var exitCountdown: TimeInterval = 0
    private var exitActivatedAt: TimeInterval = 0
    private var exitCountdownLabel: SKLabelNode?
    private var exitIsEmergency = false
    private var exitGuidanceRefreshTimer: TimeInterval = 0

    private var touchStart: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var activeHoldDirection = 0
    private var holdTimer: TimeInterval = 0
    private var holdActivated = false
    private var timeSinceLastLaneChange: TimeInterval = 0
    private var passivePressureWarningCooldown: TimeInterval = 0
    private var passivePressureAlertShown = false

    init(size: CGSize, mode: GameMode = .storyChase, level: LevelDefinition? = nil) {
        self.gameMode = mode
        if mode == .storyChase {
            self.currentLevel = level ?? LevelCatalog.level(id: AppConfig.forcedLevelID) ?? LevelCatalog.nextPlayableLevel(completedIDs: SaveManager.shared.data.completedLevelIDs)
        } else {
            self.currentLevel = nil
        }
        super.init(size: size)
        currentWorld = currentLevel?.worldTheme ?? WorldThemeCatalog.defaultTheme
        currentCity = currentWorld.audioCity.cityTheme
    }

    required init?(coder aDecoder: NSCoder) {
        self.gameMode = .storyChase
        self.currentLevel = LevelCatalog.nextPlayableLevel(completedIDs: SaveManager.shared.data.completedLevelIDs)
        super.init(coder: aDecoder)
        currentWorld = currentLevel?.worldTheme ?? WorldThemeCatalog.defaultTheme
        currentCity = currentWorld.audioCity.cityTheme
    }

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        recalculateLayout()
        setupCamera()
        setupLayers()
        buddy.attach(to: floatingTextNode, sceneSize: size)
        AudioManager.shared.configure()
        AtmosphereManager.shared.attach(to: self)
        setupRoad()
        setupWarningPulse()
        loadSelectedLoadout()
        setupPlayer()
        setupPolice()
        setupScoreLabel()
        AudioManager.shared.updateTheme(currentCity.audioTheme, crossfadeDuration: 0)
        startGame()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        recalculateLayout()
        resetCameraPosition()
        setupRoad()
        setupWarningPulse()
        AtmosphereManager.shared.updateLayout(size: size)
        buddy.updateLayout(sceneSize: size)
        positionPlayer(animated: false)
        positionPolice(deltaTime: 1)
        layoutScoreLabel()
    }

    // MARK: - Setup

    private func loadSelectedLoadout() {
        let save = SaveManager.shared.data
        activeCar = CarCatalog.car(id: save.selectedCarID)
        activePaint = CarCatalog.paint(id: save.selectedPaintID)
        highScore = save.bestScore
        totalCash = save.totalCash
    }

    private func setupCamera() {
        if gameCamera.parent == nil {
            addChild(gameCamera)
        }

        camera = gameCamera
        resetCameraPosition()
    }

    private func resetCameraPosition() {
        gameCamera.removeAllActions()
        gameCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    private func setupLayers() {
        sceneryNode.zPosition = -40
        roadNode.zPosition = -30
        markerNode.zPosition = -20
        speedLineNode.zPosition = -10
        eventNode.zPosition = -4
        exitNode.zPosition = -2
        trafficNode.zPosition = 5
        policeSupportNode.zPosition = 14
        effectsNode.zPosition = 18
        comboAuraNode.zPosition = 1
        vehicleNode.zPosition = 20
        floatingTextNode.zPosition = 120
        warningPulseNode.zPosition = 85
        diagnosticOverlayNode.zPosition = 92
        overlayNode.zPosition = 100

        // Feel effects live on separate layers so restarts can clear gameplay nodes without fighting overlays.
        [sceneryNode, roadNode, markerNode, speedLineNode, eventNode, exitNode, trafficNode, policeSupportNode, effectsNode, vehicleNode, floatingTextNode, warningPulseNode, diagnosticOverlayNode, overlayNode].forEach { node in
            if node.parent == nil {
                addChild(node)
            }
        }

        if comboAuraNode.parent == nil {
            effectsNode.addChild(comboAuraNode)
        }
    }

    private func recalculateLayout() {
        let roadScale: CGFloat
        switch currentWorld.roadStyle {
        case .openFreeway:
            roadScale = 0.94
        case .urbanExpressway:
            roadScale = 0.9
        case .tropicalBoulevard:
            roadScale = 0.92
        }
        roadWidth = min(size.width * roadScale, size.width - 32)
        roadLeft = (size.width - roadWidth) / 2
        laneManager = LaneManager(roadLeft: roadLeft, roadWidth: roadWidth)
        laneWidth = laneManager.laneWidth
        laneCenters = laneManager.laneCenters
        slotCenters = laneManager.slotCenters
        playerY = max(122, size.height * 0.2)
        maxPoliceGap = max(170, size.height * 0.22)
        minPoliceGap = max(76, laneWidth * 1.3)
        sceneryRecycleSpan = size.height + 180
        markerRecycleSpan = size.height + 140
    }

    private func setupRoad() {
        recalculateLayout()
        sceneryNode.removeAllChildren()
        roadNode.removeAllChildren()
        markerNode.removeAllChildren()

        let palette = palette(for: currentCity)
        backgroundColor = palette.background

        addWorldBackdrop(with: palette)

        let roadRect = CGRect(x: roadLeft, y: -80, width: roadWidth, height: size.height + 160)
        let road = SKShapeNode(rect: roadRect)
        road.fillColor = palette.road
        road.strokeColor = palette.roadTexture.withAlphaComponent(0.24)
        road.lineWidth = 2
        roadNode.addChild(road)

        let sideStripWidth = max(0, roadLeft - 5)
        let leftSideStrip = SKShapeNode(rect: CGRect(x: 0, y: -80, width: sideStripWidth, height: size.height + 160))
        leftSideStrip.fillColor = palette.shoulder.withAlphaComponent(0.78)
        leftSideStrip.strokeColor = .clear
        roadNode.addChild(leftSideStrip)

        let rightSideStrip = SKShapeNode(rect: CGRect(x: roadLeft + roadWidth + 5, y: -80, width: sideStripWidth, height: size.height + 160))
        rightSideStrip.fillColor = palette.shoulder.withAlphaComponent(0.78)
        rightSideStrip.strokeColor = .clear
        roadNode.addChild(rightSideStrip)

        let leftShoulder = SKShapeNode(rect: CGRect(x: roadLeft - 10, y: -80, width: 10, height: size.height + 160))
        leftShoulder.fillColor = palette.shoulder
        leftShoulder.strokeColor = palette.edgeLine
        leftShoulder.lineWidth = 1.5
        roadNode.addChild(leftShoulder)

        let rightShoulder = SKShapeNode(rect: CGRect(x: roadLeft + roadWidth, y: -80, width: 10, height: size.height + 160))
        rightShoulder.fillColor = palette.shoulder
        rightShoulder.strokeColor = palette.edgeLine
        rightShoulder.lineWidth = 1.5
        roadNode.addChild(rightShoulder)

        addRoadEdgeGlow(x: roadLeft - 11, color: palette.edgeLine)
        addRoadEdgeGlow(x: roadLeft + roadWidth + 11, color: palette.edgeLine)
        createRoadTexture(with: palette)
        createRoadDebris(with: palette)
        createLaneMarkers(with: palette)
        createRoadMarkings(with: palette)
        createSpeedLines(with: palette)
        createSideDecorations(with: palette)
        AtmosphereManager.shared.setRoadFrame(CGRect(x: roadLeft, y: 0, width: roadWidth, height: size.height))
        AtmosphereManager.shared.setCityGlow(primary: palette.accent, secondary: palette.secondAccent)
    }

    private func addWorldBackdrop(with palette: ThemePalette) {
        let horizonWash = SKShapeNode(rect: CGRect(x: 0, y: size.height * 0.58, width: size.width, height: size.height * 0.42 + 80))
        let horizonAlpha: CGFloat
        switch currentWorld.lightingMood {
        case .coolUrbanShadow:
            horizonAlpha = 0.1
        case .sunlitCalifornia, .tropicalNeon:
            horizonAlpha = 0.16
        }
        horizonWash.fillColor = palette.accent.withAlphaComponent(horizonAlpha)
        horizonWash.strokeColor = .clear
        sceneryNode.addChild(horizonWash)

        switch currentWorld.skylineStyle {
        case .laLowRiseCoast:
            let oceanWidth = max(roadLeft - 12, 18)
            let ocean = SKShapeNode(rect: CGRect(x: 0, y: -80, width: oceanWidth, height: size.height + 160))
            ocean.fillColor = palette.secondAccent.withAlphaComponent(0.24)
            ocean.strokeColor = .clear
            sceneryNode.addChild(ocean)

            for index in 0..<6 {
                let wave = SKShapeNode(rectOf: CGSize(width: oceanWidth * 0.56, height: 3), cornerRadius: 1.5)
                wave.fillColor = ArcadeArt.Palette.cream.withAlphaComponent(0.28)
                wave.strokeColor = .clear
                wave.position = CGPoint(x: oceanWidth * 0.42, y: CGFloat(index) * 118 - 20)
                wave.userData = ["speedFactor": CGFloat(0.42)]
                sceneryNode.addChild(wave)
            }

            for index in 0..<5 {
                let width = max(28, roadLeft * CGFloat.random(in: 0.18...0.3))
                let height = CGFloat(34 + (index % 3) * 14)
                let building = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 3)
                building.fillColor = ArcadeArt.Palette.cream.withAlphaComponent(0.32)
                building.strokeColor = palette.accent.withAlphaComponent(0.16)
                building.position = CGPoint(x: roadLeft + roadWidth + roadLeft * CGFloat.random(in: 0.22...0.78), y: size.height * 0.66)
                sceneryNode.addChild(building)
            }

        case .newYorkVertical:
            for index in 0..<8 {
                let width = max(22, roadLeft * CGFloat.random(in: 0.18...0.32))
                let height = CGFloat(90 + (index % 4) * 28)
                let building = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
                building.fillColor = SKColor.black.withAlphaComponent(0.18)
                building.strokeColor = palette.secondAccent.withAlphaComponent(0.18)
                building.position = CGPoint(x: CGFloat(index) / 7 * size.width, y: size.height * 0.68)
                sceneryNode.addChild(building)
            }

        case .miamiPastelCoast:
            let waterWidth = max(roadLeft - 12, 18)
            let water = SKShapeNode(rect: CGRect(x: 0, y: -80, width: waterWidth, height: size.height + 160))
            water.fillColor = palette.secondAccent.withAlphaComponent(0.34)
            water.strokeColor = .clear
            sceneryNode.addChild(water)

            for index in 0..<7 {
                let width = max(24, roadLeft * CGFloat.random(in: 0.2...0.36))
                let height = CGFloat(42 + (index % 4) * 18)
                let hotel = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
                hotel.fillColor = (index.isMultiple(of: 2) ? palette.accent : ArcadeArt.Palette.cream).withAlphaComponent(0.28)
                hotel.strokeColor = palette.secondAccent.withAlphaComponent(0.28)
                hotel.position = CGPoint(x: roadLeft + roadWidth + roadLeft * CGFloat.random(in: 0.2...0.8), y: size.height * 0.65)
                sceneryNode.addChild(hotel)
            }
        }
    }

    private func createLaneMarkers(with palette: ThemePalette) {
        let dashSize = CGSize(width: 3.5, height: 30)

        for laneDivider in 1..<laneCount {
            let x = roadLeft + laneWidth * CGFloat(laneDivider)
            var y: CGFloat = -70
            while y < size.height + 110 {
                let glow = SKShapeNode(rectOf: CGSize(width: dashSize.width + 5, height: dashSize.height + 6), cornerRadius: 3)
                glow.position = CGPoint(x: x, y: y)
                glow.fillColor = palette.laneMarker.withAlphaComponent(0.12)
                glow.strokeColor = .clear
                markerNode.addChild(glow)

                let dash = SKShapeNode(rectOf: dashSize, cornerRadius: 2)
                dash.position = CGPoint(x: x, y: y)
                dash.fillColor = palette.laneMarker
                dash.strokeColor = palette.edgeLine.withAlphaComponent(0.26)
                dash.lineWidth = 1
                markerNode.addChild(dash)
                y += 70
            }
        }
    }

    private func addRoadEdgeGlow(x: CGFloat, color: SKColor) {
        for index in 0..<3 {
            let width = CGFloat(4 + index * 5)
            let line = SKShapeNode(rect: CGRect(x: x - width / 2, y: -80, width: width, height: size.height + 160))
            line.fillColor = color.withAlphaComponent(0.18 / CGFloat(index + 1))
            line.strokeColor = .clear
            roadNode.addChild(line)
        }
    }

    private func createRoadTexture(with palette: ThemePalette) {
        let stripCount = 20

        for index in 0..<stripCount {
            let width = CGFloat.random(in: 1...3)
            let height = CGFloat.random(in: 28...78)
            let strip = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: width / 2)
            strip.position = CGPoint(
                x: CGFloat.random(in: (roadLeft + 16)...(roadLeft + roadWidth - 16)),
                y: CGFloat(index) / CGFloat(stripCount) * (size.height + 180) - 70
            )
            strip.fillColor = palette.roadTexture.withAlphaComponent(CGFloat.random(in: 0.08...0.18))
            strip.strokeColor = .clear
            strip.userData = ["speedFactor": CGFloat.random(in: 0.35...0.65)]
            markerNode.addChild(strip)
        }
    }

    private func createRoadDebris(with palette: ThemePalette) {
        for index in 0..<12 {
            let debris = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...5)), cornerRadius: 1)
            debris.fillColor = [palette.roadTexture, palette.laneMarker, SKColor.black].randomElement()?.withAlphaComponent(CGFloat.random(in: 0.08...0.18)) ?? palette.roadTexture
            debris.strokeColor = .clear
            debris.zRotation = CGFloat.random(in: -0.7...0.7)
            debris.position = CGPoint(
                x: CGFloat.random(in: (roadLeft + 18)...(roadLeft + roadWidth - 18)),
                y: CGFloat(index) / 18 * (size.height + 160) - 60
            )
            debris.userData = ["speedFactor": CGFloat.random(in: 0.7...1.05)]
            markerNode.addChild(debris)
        }
    }

    private func createRoadMarkings(with palette: ThemePalette) {
        var y = CGFloat(120)

        while y < size.height + 160 {
            switch currentWorld.roadStyle {
            case .urbanExpressway:
                addCrosswalkMarking(atY: y, color: palette.laneMarker.withAlphaComponent(0.14))
            case .tropicalBoulevard:
                addArrowMarking(atY: y, color: palette.secondAccent.withAlphaComponent(0.16))
            case .openFreeway:
                addFreewayChevron(atY: y, color: palette.laneMarker.withAlphaComponent(0.16))
            }
            y += CGFloat.random(in: 280...360)
        }
    }

    private func addFreewayChevron(atY y: CGFloat, color: SKColor) {
        for side in [-1, 1] {
            let centerX = side < 0 ? roadLeft + laneWidth * 0.6 : roadLeft + roadWidth - laneWidth * 0.6
            let path = CGMutablePath()
            path.move(to: CGPoint(x: centerX - CGFloat(side) * laneWidth * 0.22, y: y - 18))
            path.addLine(to: CGPoint(x: centerX, y: y))
            path.addLine(to: CGPoint(x: centerX - CGFloat(side) * laneWidth * 0.22, y: y + 18))

            let mark = SKShapeNode(path: path)
            mark.strokeColor = color
            mark.lineWidth = 4
            mark.fillColor = .clear
            markerNode.addChild(mark)
        }
    }

    private func addArrowMarking(atY y: CGFloat, color: SKColor) {
        let centerX = size.width / 2
        let shaft = SKShapeNode(rectOf: CGSize(width: 10, height: 42), cornerRadius: 2)
        shaft.position = CGPoint(x: centerX, y: y - 12)
        shaft.fillColor = color
        shaft.strokeColor = .clear
        markerNode.addChild(shaft)

        let headPath = CGMutablePath()
        headPath.move(to: CGPoint(x: 0, y: 32))
        headPath.addLine(to: CGPoint(x: -26, y: 2))
        headPath.addLine(to: CGPoint(x: -8, y: 2))
        headPath.addLine(to: CGPoint(x: -8, y: -12))
        headPath.addLine(to: CGPoint(x: 8, y: -12))
        headPath.addLine(to: CGPoint(x: 8, y: 2))
        headPath.addLine(to: CGPoint(x: 26, y: 2))
        headPath.closeSubpath()

        let head = SKShapeNode(path: headPath)
        head.position = CGPoint(x: centerX, y: y)
        head.fillColor = color
        head.strokeColor = .clear
        markerNode.addChild(head)
    }

    private func addCrosswalkMarking(atY y: CGFloat, color: SKColor) {
        for lane in 0..<laneCount {
            let stripe = SKShapeNode(rectOf: CGSize(width: laneWidth * 0.56, height: 7), cornerRadius: 1)
            stripe.position = CGPoint(x: laneCenters[lane], y: y)
            stripe.fillColor = color
            stripe.strokeColor = .clear
            markerNode.addChild(stripe)
        }
    }

    private func createSpeedLines(with palette: ThemePalette) {
        speedLineNode.removeAllChildren()

        for _ in 0..<24 {
            let height = CGFloat.random(in: 70...150)
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1.4...3), height: height), cornerRadius: 1)
            line.fillColor = [palette.laneMarker, palette.accent, ArcadeArt.Palette.cream].randomElement() ?? palette.laneMarker
            line.strokeColor = .clear
            line.alpha = CGFloat.random(in: 0.05...0.18)
            let edgeBand = Bool.random()
            let xRange = edgeBand
                ? (Bool.random() ? (roadLeft + 8)...(roadLeft + 34) : (roadLeft + roadWidth - 34)...(roadLeft + roadWidth - 8))
                : (roadLeft + 28)...(roadLeft + roadWidth - 28)
            line.position = CGPoint(
                x: CGFloat.random(in: xRange),
                y: CGFloat.random(in: -60...(size.height + 120))
            )
            line.userData = [
                "assetID": ArcadeArt.EffectAsset.speedStreak.rawValue,
                "speedFactor": CGFloat.random(in: 1.25...1.85)
            ]
            speedLineNode.addChild(line)
        }
    }

    private func setupWarningPulse() {
        warningPulseNode.removeAllChildren()
        warningPulseNode.removeAllActions()
        warningPulseNode.alpha = 0
        diagnosticOverlayNode.removeAllChildren()
        warningPulseActive = false

        let reduced = SaveManager.shared.data.reducedFlashingEnabled
        let pulse = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        pulse.fillColor = SKColor.red.withAlphaComponent(reduced ? 0.035 : 0.1)
        pulse.strokeColor = SKColor.red.withAlphaComponent(reduced ? 0.35 : 0.85)
        pulse.lineWidth = reduced ? 7 : 12
        warningPulseNode.addChild(pulse)
    }

    private func createSideDecorations(with palette: ThemePalette) {
        let count = Int(size.height / 88) + 5

        for index in 0..<count {
            let y = CGFloat(index) * 88 - 40
            sceneryNode.addChild(makeDecoration(side: -1, y: y, index: index, palette: palette))
            sceneryNode.addChild(makeDecoration(side: 1, y: y + 44, index: index, palette: palette))
        }
    }

    private func makeDecoration(side: Int, y: CGFloat, index: Int, palette: ThemePalette) -> SKNode {
        let node = SKNode()
        let sideWidth = max(roadLeft - 8, 12)
        let x = side < 0 ? roadLeft / 2 : roadLeft + roadWidth + roadLeft / 2
        node.position = CGPoint(x: x, y: y)

        switch currentWorld.propSet {
        case .losAngeles:
            if index.isMultiple(of: 4) {
                let sign = ArcadeArt.makeFreewaySign(size: CGSize(width: min(sideWidth, 48), height: 54))
                sign.setScale(0.84)
                node.addChild(sign)
            } else {
                addPalmTree(to: node, palette: palette, height: CGFloat(52 + (index % 3) * 9))
            }

        case .newYork:
            let height = CGFloat(54 + (index % 4) * 16)
            let width = min(sideWidth, CGFloat(28 + (index % 3) * 8))
            let building = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
            building.fillColor = SKColor(white: CGFloat(0.14 + Double(index % 3) * 0.04), alpha: 1)
            building.strokeColor = palette.edgeLine.withAlphaComponent(0.3)
            building.lineWidth = 1
            node.addChild(building)

            let roof = SKShapeNode(rectOf: CGSize(width: width * 0.72, height: 4), cornerRadius: 1)
            roof.position = CGPoint(x: 0, y: height / 2 + 3)
            roof.fillColor = palette.accent.withAlphaComponent(0.45)
            roof.strokeColor = .clear
            node.addChild(roof)

            for row in 0..<4 {
                for column in -1...1 {
                    let window = SKShapeNode(rectOf: CGSize(width: 4, height: 6), cornerRadius: 1)
                    window.fillColor = row == index % 4 ? palette.accent.withAlphaComponent(0.85) : SKColor(white: 0.55, alpha: 0.5)
                    window.strokeColor = .clear
                    window.position = CGPoint(x: CGFloat(column) * 8, y: CGFloat(row) * 13 - height * 0.25)
                    node.addChild(window)
                }
            }

            if index.isMultiple(of: 3) {
                addSteamVent(to: node, xOffset: side < 0 ? width * 0.18 : -width * 0.18, yOffset: -height * 0.48)
            }

        case .miami:
            if index.isMultiple(of: 2) {
                let height = CGFloat(52 + (index % 4) * 14)
                let width = min(sideWidth, CGFloat(30 + (index % 2) * 8))
                let bar = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
                bar.fillColor = index.isMultiple(of: 4) ? palette.accent.withAlphaComponent(0.82) : SKColor(red: 0.05, green: 0.07, blue: 0.18, alpha: 1)
                bar.strokeColor = index.isMultiple(of: 4) ? palette.accent : palette.secondAccent
                bar.lineWidth = 1.5
                node.addChild(bar)

                let crown = SKShapeNode(rectOf: CGSize(width: width * 0.86, height: 5), cornerRadius: 2)
                crown.position = CGPoint(x: 0, y: height / 2 + 4)
                crown.fillColor = index.isMultiple(of: 4) ? palette.secondAccent : palette.accent
                crown.strokeColor = .clear
                node.addChild(crown)
            } else {
                addPalmTree(to: node, palette: palette, height: CGFloat(48 + (index % 3) * 8))
            }
        }

        return node
    }

    private func addSteamVent(to node: SKNode, xOffset: CGFloat, yOffset: CGFloat) {
        let grate = SKShapeNode(rectOf: CGSize(width: 18, height: 5), cornerRadius: 2)
        grate.position = CGPoint(x: xOffset, y: yOffset)
        grate.fillColor = SKColor(white: 0.08, alpha: 1)
        grate.strokeColor = SKColor(white: 0.5, alpha: 0.4)
        node.addChild(grate)

        for puffIndex in 0..<3 {
            let puff = SKShapeNode(circleOfRadius: CGFloat(3 + puffIndex))
            puff.position = CGPoint(x: xOffset + CGFloat(puffIndex - 1) * 5, y: yOffset + 9)
            puff.fillColor = SKColor(white: 0.75, alpha: 0.28)
            puff.strokeColor = .clear
            node.addChild(puff)

            let rise = SKAction.moveBy(x: CGFloat.random(in: -4...4), y: 24, duration: 1.2 + Double(puffIndex) * 0.15)
            let fade = SKAction.fadeOut(withDuration: 1.2)
            let reset = SKAction.run {
                puff.position = CGPoint(x: xOffset + CGFloat(puffIndex - 1) * 5, y: yOffset + 9)
                puff.alpha = 1
            }
            puff.run(.repeatForever(.sequence([.group([rise, fade]), reset, .wait(forDuration: 0.3)])))
        }
    }

    private func addPalmTree(to node: SKNode, palette: ThemePalette, height: CGFloat) {
        let trunk = SKShapeNode(rectOf: CGSize(width: 6, height: height), cornerRadius: 2)
        trunk.fillColor = SKColor(red: 0.45, green: 0.24, blue: 0.12, alpha: 1)
        trunk.strokeColor = SKColor.black.withAlphaComponent(0.25)
        trunk.position = CGPoint(x: 0, y: -6)
        node.addChild(trunk)

        let sunsetGlow = SKShapeNode(circleOfRadius: 16)
        sunsetGlow.fillColor = palette.accent.withAlphaComponent(0.18)
        sunsetGlow.strokeColor = .clear
        sunsetGlow.position = CGPoint(x: 0, y: height * 0.38)
        node.addChild(sunsetGlow)

        for angle in stride(from: -60.0, through: 60.0, by: 20.0) {
            let frond = SKShapeNode(rectOf: CGSize(width: 30, height: 6), cornerRadius: 3)
            frond.fillColor = SKColor(red: 0.04, green: 0.42, blue: 0.22, alpha: 1)
            frond.strokeColor = palette.secondAccent.withAlphaComponent(0.25)
            frond.zRotation = CGFloat(angle * .pi / 180)
            frond.position = CGPoint(x: 0, y: height * 0.43)
            node.addChild(frond)
        }
    }

    private func setupPlayer() {
        setPlayerSlot(laneManager.clampSlot(LaneManager.startSlot, for: activeCar.vehicleClass))
        playerCar?.removeFromParent()
        let car = makePlayerCar()
        car.name = "player"
        playerCar = car
        vehicleNode.addChild(car)
        positionPlayer(animated: false)
    }

    private func setupPolice() {
        policeCar?.removeFromParent()
        let car = makePoliceCar()
        car.name = "police"
        policeCar = car
        vehicleNode.addChild(car)
        policeGap = maxPoliceGap
        positionPolice(deltaTime: 1)
    }

    private func setupScoreLabel() {
        scorePanel.zPosition = 89
        scorePanel.isHidden = true
        scorePanel.fillColor = palette(for: currentCity).panel
        scorePanel.strokeColor = palette(for: currentCity).accent.withAlphaComponent(0.8)
        scorePanel.lineWidth = 2

        if scorePanel.parent == nil {
            addChild(scorePanel)
        }

        let labels: [SKLabelNode] = [scoreLabel, comboLabel, wantedLabel, exitHUDLabel, distanceLabel, cashLabel]
        for label in labels {
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.zPosition = 90
            label.isHidden = true

            if label.parent == nil {
                addChild(label)
            }
        }

        let largerHUD = SaveManager.shared.data.largerHUDTextEnabled
        let highContrastHUD = SaveManager.shared.data.highContrastHUDEnabled
        let scale: CGFloat = largerHUD ? 1.16 : 1
        scoreLabel.fontSize = 21 * scale
        scoreLabel.fontColor = highContrastHUD ? .white : .white
        comboLabel.fontSize = 15 * scale
        comboLabel.fontColor = highContrastHUD ? SKColor(red: 0.55, green: 1, blue: 0.55, alpha: 1) : SKColor(red: 0.35, green: 1, blue: 0.42, alpha: 1)
        wantedLabel.fontSize = 16 * scale
        wantedLabel.fontColor = highContrastHUD ? SKColor(red: 1, green: 0.95, blue: 0.15, alpha: 1) : SKColor(red: 1, green: 0.24, blue: 0.2, alpha: 1)
        exitHUDLabel.fontSize = 16 * scale
        exitHUDLabel.fontColor = highContrastHUD ? SKColor(red: 0.65, green: 1, blue: 0.65, alpha: 1) : UITheme.Color.green
        distanceLabel.fontSize = 12 * scale
        distanceLabel.fontColor = highContrastHUD ? .white : SKColor(white: 0.86, alpha: 1)
        cashLabel.fontSize = 12 * scale
        cashLabel.fontColor = highContrastHUD ? SKColor(red: 1, green: 1, blue: 0.25, alpha: 1) : SKColor(red: 1, green: 0.86, blue: 0.25, alpha: 1)

        comboMeterBack.zPosition = 90
        comboMeterBack.fillColor = SKColor.black.withAlphaComponent(0.45)
        comboMeterBack.strokeColor = SKColor.white.withAlphaComponent(0.12)
        comboMeterBack.lineWidth = 1
        comboMeterBack.isHidden = true
        if comboMeterBack.parent == nil {
            addChild(comboMeterBack)
        }

        comboMeterFill.zPosition = 91
        comboMeterFill.fillColor = comboLabel.fontColor ?? .green
        comboMeterFill.strokeColor = .clear
        comboMeterFill.isHidden = true
        if comboMeterFill.parent == nil {
            addChild(comboMeterFill)
        }

        layoutScoreLabel()
    }

    private func layoutScoreLabel() {
        let metrics = GameLayoutMetrics(sceneSize: size, safeAreaInsets: view?.safeAreaInsets ?? .zero)
        let panelWidth = min(metrics.safeContentFrame.width, 382)
        let topY = metrics.topHUDFrame.midY + 2
        scorePanel.position = CGPoint(x: size.width / 2, y: topY)
        scorePanel.path = CGPath(
            roundedRect: CGRect(x: -panelWidth / 2, y: -30, width: panelWidth, height: 60),
            cornerWidth: 8,
            cornerHeight: 8,
            transform: nil
        )

        let leftX = size.width / 2 - panelWidth / 2 + 14
        let rightX = size.width / 2 + panelWidth / 2 - 14
        wantedLabel.horizontalAlignmentMode = .left
        exitHUDLabel.horizontalAlignmentMode = .right
        scoreLabel.horizontalAlignmentMode = .center
        comboLabel.horizontalAlignmentMode = .center
        distanceLabel.horizontalAlignmentMode = .left
        cashLabel.horizontalAlignmentMode = .right

        wantedLabel.position = CGPoint(x: leftX, y: topY + 11)
        scoreLabel.position = CGPoint(x: size.width / 2, y: topY + 11)
        exitHUDLabel.position = CGPoint(x: rightX, y: topY + 11)
        distanceLabel.position = CGPoint(x: leftX, y: topY - 15)
        cashLabel.position = CGPoint(x: rightX, y: topY - 15)
        comboLabel.position = CGPoint(x: size.width / 2, y: topY - 48)
        updateComboMeterPath()
    }

    private func setHUDVisible(_ visible: Bool) {
        scorePanel.isHidden = !visible
        scoreLabel.isHidden = !visible
        comboLabel.isHidden = !visible
        wantedLabel.isHidden = !visible
        exitHUDLabel.isHidden = !visible
        distanceLabel.isHidden = !visible
        cashLabel.isHidden = !visible
        comboMeterBack.isHidden = !visible || comboCount == 0
        comboMeterFill.isHidden = !visible || comboCount == 0
    }

    private func updateHUD() {
        let palette = palette(for: currentCity)
        scoreLabel.text = "SCORE \(score)"
        wantedLabel.text = wantedLevel >= 6 ? "ELITE \(wantedStars)" : "WANTED \(wantedStars)"
        distanceLabel.text = "\(currentWorld.stageCode)  DIST \(Int(runDistance))"
        cashLabel.text = "$\(runCash)"
        updateExitHUDLabel()

        if comboCount > 0 {
            comboLabel.text = "NEAR MISS x\(comboCount)  \(String(format: "%.1fx", scoreMultiplier))"
            comboMeterBack.isHidden = false
            comboMeterFill.isHidden = false
        } else {
            comboLabel.text = "COMBO READY"
            comboMeterBack.isHidden = true
            comboMeterFill.isHidden = true
        }

        scorePanel.fillColor = palette.panel
        scorePanel.strokeColor = palette.accent.withAlphaComponent(0.8)
        comboMeterFill.fillColor = palette.accent
        updateComboMeterPath()
    }

    private func updateComboMeterPath() {
        guard comboMeterBack.parent != nil else { return }

        let metrics = GameLayoutMetrics(sceneSize: size, safeAreaInsets: view?.safeAreaInsets ?? .zero)
        let panelWidth = min(metrics.safeContentFrame.width, 382)
        let meterWidth = min(188, panelWidth * 0.5)
        let progress = comboCount > 0 ? CGFloat(comboTimer / comboDuration) : 0
        let y = comboLabel.position.y - 14
        let x = size.width / 2 - meterWidth / 2

        comboMeterBack.path = CGPath(
            roundedRect: CGRect(x: x, y: y, width: meterWidth, height: 5),
            cornerWidth: 2.5,
            cornerHeight: 2.5,
            transform: nil
        )
        comboMeterFill.path = CGPath(
            roundedRect: CGRect(x: x, y: y, width: max(0, meterWidth * progress), height: 5),
            cornerWidth: 2.5,
            cornerHeight: 2.5,
            transform: nil
        )
    }

    private var wantedStars: String {
        String(repeating: "*", count: wantedLevel)
    }

    private func updateExitHUDLabel() {
        guard exitPhase == .active, let activeExitSide else {
            exitHUDLabel.text = "EXIT --"
            exitHUDLabel.alpha = 0.58
            return
        }

        exitHUDLabel.text = "EXIT \(activeExitSide.displayName) \(Int(ceil(exitCountdown)))"
        exitHUDLabel.alpha = 1
    }

    private var scoreMultiplier: CGFloat {
        let comboBonus = CGFloat(min(comboCount, 8)) * 0.15
        let wantedBonus = CGFloat(max(0, wantedLevel - 1)) * 0.1
        return (1 + comboBonus + wantedBonus) * activeCar.scoreMultiplier
    }

    private var passiveVehicleRewardScale: CGFloat {
        activeCar.vehicleClass == .motorcycle ? 0.92 : 1.03
    }

    // MARK: - Game Flow

    private func configureRunSeed() {
        let levelKey = currentLevel?.levelID ?? "endless"
        let key = "\(levelKey)|\(activeCar.id)|\(gameMode.rawValue)"
        runSeed = AppSeededRNG.stableSeed(
            for: key,
            runIndex: SaveManager.shared.data.totalRuns,
            baseSeed: 0x54524146464943
        )
        let runRNG = AppSeededRNG(seed: runSeed)
        trafficPlanRNG = runRNG.derivedStream(named: "traffic-plan")
        trafficSpawnRNG = runRNG.derivedStream(named: "traffic-spawn")
        trafficEventRNG = runRNG.derivedStream(named: "traffic-events")
    }

    private func startGame() {
        gameState = .playing
        loadSelectedLoadout()
        showingSettings = false
        overlayNode.removeAllChildren()
        trafficNode.removeAllChildren()
        policeSupportNode.removeAllChildren()
        eventNode.removeAllChildren()
        exitNode.removeAllChildren()
        exitNode.alpha = 1
        effectsNode.removeAllChildren()
        effectsNode.addChild(comboAuraNode)
        comboAuraNode.removeAllChildren()
        comboAuraNode.alpha = 0
        floatingTextNode.removeAllChildren()
        warningPulseNode.removeAllActions()
        warningPulseNode.alpha = 0

        score = 0
        scoreRemainder = 0
        runCash = 0
        cashRemainder = 0
        runDistance = 0
        runTime = 0
        nearMissCount = 0
        laneSplitCount = 0
        clutchSaveCount = 0
        comboCount = 0
        highestCombo = 0
        comboTimer = 0
        wantedLevel = 1
        highestWantedLevel = 1
        wantedVisualLevel = 1
        roadSpeed = 330
        trafficSpeed = 275
        spawnInterval = 1.08
        spawnTimer = 0.45
        difficultyTimer = 0
        lastUpdateTime = 0
        smokeTimer = 0
        warningPulseActive = false
        warningHapticCooldown = 0
        dodgeBoostTimer = 0
        dodgeBoostStreakTimer = 0
        dodgeBoostCount = 0
        clutchSaveCooldown = 0
        roadblockCooldown = 9
        currentEvent = nil
        eventTimer = 0
        eventCooldown = 14
        eventSpawnTimer = 0
        helicopterNode?.removeFromParent()
        helicopterNode = nil
        helicopterAngle = 0
        helicopterAudioTimer = 0
        reviveUsed = false
        showingReviveOffer = false
        pendingCrashPoint = nil
        pendingCrashReason = "collision"
        invulnerabilityTimer = 0
        cameraJuicePhase = 0
        screenshotShowcaseSpawned = false
        latestTrafficPlan = nil
        trafficSpawnSerial = 0
        debugAutoplayTimer = 0
        performanceSampleTimer = 0
        performanceFrameCounter = 0
        awardedLaneSplitPairs.removeAll()
        lastPoliceBuddyLevel = 1
        primaryExitTriggered = false
        emergencyExitUsed = false
        emergencyExitTimer = 0
        exitAnticipationShown = false
        exitPhase = .inactive
        activeExitSide = nil
        exitCountdown = 0
        exitActivatedAt = 0
        exitCountdownLabel = nil
        exitIsEmergency = false
        exitGuidanceRefreshTimer = 0
        activeHoldDirection = 0
        holdTimer = 0
        holdActivated = false
        timeSinceLastLaneChange = 0
        passivePressureWarningCooldown = 0
        passivePressureAlertShown = false
        policeClosingSpeed = 3.4
        policeGap = maxPoliceGap
        currentWorld = currentLevel?.worldTheme ?? WorldThemeCatalog.endlessTheme(score: score)
        currentCity = currentWorld.audioCity.cityTheme
        configureRunSeed()
        RunTelemetryRecorder.shared.startRun(seed: runSeed, levelID: currentLevel?.levelID ?? "endless", vehicleID: activeCar.id)
        setPlayerSlot(laneManager.clampSlot(LaneManager.startSlot, for: activeCar.vehicleClass))

        AudioManager.shared.updateTheme(currentCity.audioTheme, crossfadeDuration: 0)
        AudioManager.shared.quietDangerLayers()
        AtmosphereManager.shared.setWeather(.clear, animated: false)
        AtmosphereManager.shared.setDangerPulse(0)
        resetCameraPosition()
        prepareHaptics()
        setupRoad()
        setupPlayer()
        positionPlayer(animated: false)
        positionPolice(deltaTime: 1)
        rebuildPoliceSupport()
        updateHUD()
        setHUDVisible(true)
        if let currentLevel {
            showCityBanner(currentWorld.displayName.uppercased())
            buddy.say(.levelStart, detail: "\(currentLevel.name). \(currentWorld.shortName) is live.", force: true)
        } else {
            showCityBanner(currentWorld.displayName.uppercased())
            buddy.say(.levelStart, force: true)
        }
        applyDebugOverrides()
        applyScreenshotMode()
        AnalyticsManager.shared.runStarted(carID: activeCar.id, paintID: activePaint.id)
        recordTelemetry(event: "run_started")
    }

    private func endGame(crashPoint: CGPoint? = nil, reason: String = "collision") {
        guard gameState == .playing else { return }
        guard invulnerabilityTimer <= 0 else { return }

        AnalyticsManager.shared.crash(reason: reason, score: score, distance: Int(runDistance))

        if AppConfig.rewardedRevivesEnabled, reason != "missed_exit", !reviveUsed {
            showReviveOffer(crashPoint: crashPoint, reason: reason)
            return
        }

        finalizeGameOver(crashPoint: crashPoint, playCrash: true, reason: reason)
    }

    private func showReviveOffer(crashPoint: CGPoint?, reason: String) {
        gameState = .gameOver
        showingReviveOffer = true
        pendingCrashPoint = crashPoint
        pendingCrashReason = reason
        playerCar?.removeAllActions()
        warningPulseNode.removeAllActions()
        warningPulseNode.alpha = 0
        warningPulseActive = false
        dodgeBoostTimer = 0
        AudioManager.shared.quietDangerLayers()
        AtmosphereManager.shared.setDangerPulse(0)

        let impactPoint = crashPoint ?? playerCar?.position ?? CGPoint(x: size.width / 2, y: playerY)
        playCrashEffects(at: impactPoint)
        showReviveOverlay()
    }

    private func finalizeGameOver(crashPoint: CGPoint?, playCrash: Bool, reason: String) {
        gameState = .gameOver
        showingReviveOffer = false
        overlayNode.removeAllChildren()
        playerCar?.removeAllActions()
        warningPulseNode.removeAllActions()
        warningPulseNode.alpha = 0
        warningPulseActive = false
        dodgeBoostTimer = 0
        invulnerabilityTimer = 0
        AudioManager.shared.quietDangerLayers()
        AtmosphereManager.shared.setDangerPulse(0)

        if playCrash {
            let impactPoint = crashPoint ?? playerCar?.position ?? CGPoint(x: size.width / 2, y: playerY)
            playCrashEffects(at: impactPoint)
        }
        buddy.say(.failure, force: true)
        AudioManager.shared.play(.gameOver, volume: 0.78, cooldown: 0.6)
        showFailureReasonFlash(reason)

        let runStats = makeRunStats(crashes: 1, levelCompleted: false, failureReason: reason)
        recordTelemetry(event: "run_ended", terminalReason: reason, levelCompleted: false)
        RunTelemetryRecorder.shared.close()
        let result = ProgressionManager.shared.processRun(runStats)

        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                guard let self else { return }
                UIHelpers.present(ResultsScene(size: self.size, result: result), from: self)
            }
        ]))
    }

    private func makeRunStats(crashes: Int, levelCompleted: Bool, failureReason: String?) -> RunStats {
        RunStats(
            score: score,
            distance: Int(runDistance),
            survivalTime: runTime,
            cashEarned: runCash,
            xpEarned: 0,
            nearMisses: nearMissCount,
            clutchSaves: clutchSaveCount,
            highestCombo: highestCombo,
            wantedLevelReached: highestWantedLevel,
            cityReached: currentLevel?.city ?? currentCity.runCity,
            dodgeBoostsUsed: dodgeBoostCount,
            crashes: crashes,
            selectedCarID: activeCar.id,
            selectedVehicleClass: activeCar.vehicleClass,
            laneSplits: laneSplitCount,
            motorcycleRunCompleted: activeCar.vehicleClass == .motorcycle,
            completedOnMotorcycle: activeCar.vehicleClass == .motorcycle && levelCompleted,
            crashesOnMotorcycle: activeCar.vehicleClass == .motorcycle ? crashes : 0,
            gameMode: gameMode,
            levelID: currentLevel?.levelID,
            levelCompleted: levelCompleted,
            failureReason: failureReason,
            usedRevive: reviveUsed
        )
    }

    private func recordTelemetry(
        event: String,
        plan: TrafficWavePlan? = nil,
        terminalReason: String? = nil,
        levelCompleted: Bool? = nil,
        collisionVehicle: SKSpriteNode? = nil,
        playerRect: CGRect? = nil,
        trafficRect: CGRect? = nil
    ) {
        guard RunTelemetryRecorder.shared.isEnabled else { return }

        let exitSide = activeExitSide?.displayName
        let spawns = plan?.spawns.map {
            RunTelemetryEvent.TrafficSpawn(
                lane: $0.lane,
                type: $0.type.rawValue,
                yOffset: Double($0.yOffset),
                speedMultiplier: Double($0.speedMultiplier)
            )
        }
        let vehicleType = collisionVehicle?.userData?["type"] as? String
        let vehicleID = collisionVehicle?.userData?["spawnID"] as? Int
        let activeTraffic = trafficNode.children.compactMap { node -> RunTelemetryEvent.ActiveTraffic? in
            guard let vehicle = node as? SKSpriteNode,
                  let lane = vehicle.userData?["lane"] as? Int else {
                return nil
            }

            let laneSpan = vehicle.userData?["laneSpan"] as? Int ?? 1
            let spawnID = vehicle.userData?["spawnID"] as? Int ?? 0
            let type = vehicle.userData?["type"] as? String ?? "unknown"
            let speed = vehicle.userData?["speed"] as? CGFloat ?? 0
            let spawnTime = vehicle.userData?["spawnTime"] as? TimeInterval ?? 0
            return RunTelemetryEvent.ActiveTraffic(
                spawnID: spawnID,
                lane: lane,
                slot: lane * 2,
                laneSpan: laneSpan,
                type: type,
                speed: Double(speed),
                y: Double(vehicle.position.y),
                width: Double(vehicle.size.width),
                height: Double(vehicle.size.height),
                spawnTime: spawnTime,
                isRoadblock: vehicle.userData?["roadblock"] as? Bool == true
            )
        }

        RunTelemetryRecorder.shared.record(RunTelemetryEvent(
            event: event,
            build: appBuildIdentifier,
            tuningVersion: "app-local-2026-06-22",
            seed: runSeed,
            mode: gameMode.rawValue,
            levelID: currentLevel?.levelID ?? "endless",
            vehicleID: activeCar.id,
            vehicleClass: activeCar.vehicleClass.rawValue,
            time: runTime,
            playerLane: playerLane,
            playerSlot: playerSlot,
            score: score,
            cash: runCash,
            distance: Int(runDistance),
            nearMisses: nearMissCount,
            laneSplits: laneSplitCount,
            combo: comboCount,
            wantedLevel: wantedLevel,
            policeGap: Double(policeGap),
            exitPhase: telemetryExitPhase,
            exitSide: exitSide,
            exitCountdown: exitCountdown,
            patternID: plan?.patternName,
            occupiedLanes: plan?.occupiedLanes.sorted(),
            openLanes: plan?.openLanes.sorted(),
            safeCarSlots: plan?.safeCarSlots.sorted(),
            safeMotorcycleSlots: plan?.safeMotorcycleSlots.sorted(),
            rejectionReason: plan?.rejectionReason,
            spawns: spawns,
            activeTraffic: activeTraffic,
            collisionPlayerRect: playerRect.map(RunTelemetryEvent.RectValue.init),
            collisionTrafficRect: trafficRect.map(RunTelemetryEvent.RectValue.init),
            collisionVehicleID: vehicleID,
            collisionVehicleType: vehicleType,
            terminalReason: terminalReason,
            levelCompleted: levelCompleted
        ))
    }

    private var appBuildIdentifier: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(version)-\(build)"
    }

    private var telemetryExitPhase: String {
        switch exitPhase {
        case .inactive:
            return "inactive"
        case .active:
            return "active"
        case .missed:
            return "missed"
        case .completed:
            return "completed"
        }
    }

    private func showReviveOverlay() {
        overlayNode.removeAllChildren()
        overlayNode.addChild(makeDimmer())
        overlayNode.addChild(makeOverlayPanel(y: size.height * 0.5, height: 292))

        let title = makeLabel("WRECKED", size: 36, y: size.height * 0.61)
        title.fontColor = SKColor.red
        overlayNode.addChild(title)

        let subtitle = makeLabel("One chance to get back in the chase.", size: 17, y: size.height * 0.55)
        subtitle.fontColor = SKColor(white: 0.9, alpha: 1)
        fitLabel(subtitle, maxWidth: size.width - 54)
        overlayNode.addChild(subtitle)

        let reason = makeLabel(failureTitle(for: pendingCrashReason), size: 18, y: size.height * 0.515)
        reason.fontColor = UITheme.Color.gold
        fitLabel(reason, maxWidth: size.width - 64)
        overlayNode.addChild(reason)

        let advice = makeLabel(failureAdvice(for: pendingCrashReason), size: 13, y: size.height * 0.49)
        advice.fontColor = SKColor(white: 0.78, alpha: 1)
        fitLabel(advice, maxWidth: size.width - 72)
        overlayNode.addChild(advice)

        let reviveTitle = MonetizationManager.shared.shouldPromptForRewardedAds ? "WATCH AD TO REVIVE" : "FREE REVIVE"
        overlayNode.addChild(makeOverlayButton(text: reviveTitle, name: "revive.accept", y: size.height * 0.435, width: min(size.width - 84, 260)))
        overlayNode.addChild(makeOverlayButton(text: "NO THANKS", name: "revive.decline", y: size.height * 0.36, width: 170))
    }

    private func showFailureReasonFlash(_ reason: String) {
        let panel = SKShapeNode(rectOf: CGSize(width: min(size.width - 48, 320), height: 92), cornerRadius: 10)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        panel.fillColor = SKColor.black.withAlphaComponent(0.78)
        panel.strokeColor = SKColor.red.withAlphaComponent(0.72)
        panel.glowWidth = 8
        panel.zPosition = 160
        floatingTextNode.addChild(panel)

        let title = makeLabel(failureTitle(for: reason), size: 23, y: panel.position.y + 12)
        title.fontColor = SKColor.red
        title.zPosition = 161
        floatingTextNode.addChild(title)

        let detail = makeLabel(failureAdvice(for: reason), size: 13, y: panel.position.y - 20)
        detail.fontColor = SKColor(white: 0.86, alpha: 1)
        detail.zPosition = 161
        fitLabel(detail, maxWidth: min(size.width - 74, 292))
        floatingTextNode.addChild(detail)

        [panel, title, detail].forEach { node in
            node.alpha = 0
            node.run(.sequence([
                .fadeIn(withDuration: 0.1),
                .wait(forDuration: 0.72),
                .fadeOut(withDuration: 0.16),
                .removeFromParent()
            ]))
        }
    }

    private func failureTitle(for reason: String) -> String {
        switch reason {
        case "traffic", "collision":
            return "TRAFFIC COLLISION"
        case "roadblock":
            return "ROADBLOCK HIT"
        case "police_caught", "police":
            return "POLICE CAUGHT YOU"
        case "missed_exit":
            return "EXIT MISSED"
        default:
            return "CHASE FAILED"
        }
    }

    private func failureAdvice(for reason: String) -> String {
        switch reason {
        case "traffic", "collision":
            return "The hitbox overlapped traffic. Commit to the gap earlier."
        case "roadblock":
            return "Roadblock lanes are dangerous. Watch the warning arrows."
        case "police_caught", "police":
            return "Police reached your bumper. Keep risk bonuses flowing."
        case "missed_exit":
            return "The ramp window closed. Cross over as soon as the buddy calls it."
        default:
            return "Check the results screen for the run breakdown."
        }
    }

    private func acceptRevive() {
        guard showingReviveOffer, !reviveUsed else { return }
        overlayNode.removeAllChildren()
        overlayNode.addChild(makeDimmer())
        let loading = makeLabel(MonetizationManager.shared.isRemoveAdsOwned() ? "Reviving..." : "Loading reward...", size: 24, y: size.height * 0.5)
        loading.fontColor = .white
        overlayNode.addChild(loading)

        MonetizationManager.shared.showRewardedAd(type: .revive) { [weak self] success in
            guard let self else { return }
            guard success else {
                self.finalizeGameOver(crashPoint: self.pendingCrashPoint, playCrash: false, reason: self.pendingCrashReason)
                return
            }
            self.performRevive()
        }
    }

    private func performRevive() {
        reviveUsed = true
        showingReviveOffer = false
        overlayNode.removeAllChildren()
        trafficNode.children.forEach { node in
            if abs(node.position.y - playerY) < 330 || node.position.y < playerY + 260 {
                node.removeFromParent()
            }
        }

        setPlayerSlot(laneManager.clampSlot(LaneManager.startSlot, for: activeCar.vehicleClass))
        positionPlayer(animated: false)
        policeGap = maxPoliceGap
        invulnerabilityTimer = 3.0
        dodgeBoostTimer = max(dodgeBoostTimer, 1.0)
        lastUpdateTime = 0
        gameState = .playing
        AudioManager.shared.play(.powerUp, volume: 0.85, cooldown: 0.1)
        showAwardPopup(title: "REVIVED", subtitle: "3 SEC SHIELD", at: CGPoint(x: size.width / 2, y: playerY + 92), color: palette(for: currentCity).accent, scale: 1)

        playerCar?.alpha = 1
        playerCar?.run(.sequence([
            .repeat(.sequence([.fadeAlpha(to: 0.42, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 12),
            .fadeAlpha(to: 1, duration: 0.04)
        ]))
    }

    private func showStartScreen() {
        gameState = .start
        showingSettings = false
        setHUDVisible(false)
        AudioManager.shared.quietDangerLayers()
        AtmosphereManager.shared.setDangerPulse(0)
        overlayNode.removeAllChildren()
        overlayNode.addChild(makeDimmer())
        overlayNode.addChild(makeOverlayPanel(y: size.height * 0.5, height: size.height * 0.36))

        let title = makeLabel("Traffic Getaway", size: 42, y: size.height * 0.64)
        title.fontColor = palette(for: currentCity).accent
        overlayNode.addChild(title)

        let subtitle = makeLabel("\(currentWorld.displayName.uppercased())  \(activeCar.displayName)", size: 20, y: size.height * 0.55)
        subtitle.fontColor = SKColor(white: 0.9, alpha: 1)
        overlayNode.addChild(subtitle)

        let start = makeLabel("Tap to Start", size: 28, y: size.height * 0.43)
        start.fontColor = SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 1)
        overlayNode.addChild(start)

        let best = makeLabel("High Score \(highScore)   Cash $\(totalCash)", size: 17, y: size.height * 0.35)
        best.fontColor = SKColor(white: 0.85, alpha: 1)
        overlayNode.addChild(best)

        overlayNode.addChild(makeOverlayButton(text: "Settings", name: "settings.open", y: size.height * 0.27, width: 148))
    }

    private func showGameOverScreen() {
        showingSettings = false
        setHUDVisible(false)
        overlayNode.removeAllChildren()
        overlayNode.addChild(makeDimmer())
        let panelHeight = min(size.height - 74, 610)
        overlayNode.addChild(makeOverlayPanel(y: size.height * 0.5, height: panelHeight))

        let topY = size.height / 2 + panelHeight / 2 - 54
        let busted = makeLabel("BUSTED", size: 44, y: topY)
        busted.fontColor = SKColor(red: 1, green: 0.18, blue: 0.14, alpha: 1)
        overlayNode.addChild(busted)

        let rows: [(String, String)] = [
            ("City", currentWorld.displayName),
            ("Vehicle", activeCar.displayName),
            ("Distance", "\(Int(runDistance))"),
            ("Score", "\(score)"),
            ("Highest Combo", "x\(highestCombo)"),
            ("Near Misses", "\(nearMissCount)"),
            ("Clutch Saves", "\(clutchSaveCount)"),
            ("Wanted Reached", "Level \(highestWantedLevel)"),
            ("Cash Earned", "$\(runCash)")
        ]

        for (index, row) in rows.enumerated() {
            addResultsRow(title: row.0, value: row.1, y: topY - 64 - CGFloat(index) * 28)
        }

        let best = makeLabel("High Score \(highScore)   Total Cash $\(totalCash)", size: 16, y: topY - 334)
        best.fontColor = SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 1)
        overlayNode.addChild(best)

        let restart = makeLabel("Tap to Restart", size: 23, y: topY - 386)
        restart.fontColor = SKColor(white: 0.9, alpha: 1)
        overlayNode.addChild(restart)

        overlayNode.addChild(makeOverlayButton(text: "Settings", name: "settings.open", y: topY - 434, width: 148))
    }

    private func addResultsRow(title: String, value: String, y: CGFloat) {
        let left = settingsLabel(title.uppercased(), fontSize: 14, color: SKColor(white: 0.78, alpha: 1))
        left.horizontalAlignmentMode = .right
        left.position = CGPoint(x: size.width / 2 - 18, y: y)
        overlayNode.addChild(left)

        let right = settingsLabel(value, fontSize: 19, color: .white)
        right.horizontalAlignmentMode = .left
        right.position = CGPoint(x: size.width / 2 + 18, y: y)
        overlayNode.addChild(right)
    }

    private func makeDimmer() -> SKShapeNode {
        let dimmer = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimmer.fillColor = SKColor.black.withAlphaComponent(0.66)
        dimmer.strokeColor = palette(for: currentCity).edgeLine.withAlphaComponent(0.18)
        dimmer.lineWidth = 8
        return dimmer
    }

    private func makeOverlayPanel(y: CGFloat, height: CGFloat) -> SKShapeNode {
        let panelWidth = min(size.width - 42, 390)
        let rect = CGRect(x: -panelWidth / 2, y: -height / 2, width: panelWidth, height: height)
        let panel = SKShapeNode(rect: rect, cornerRadius: 10)
        let palette = palette(for: currentCity)
        panel.position = CGPoint(x: size.width / 2, y: y)
        panel.fillColor = palette.panel
        panel.strokeColor = palette.accent.withAlphaComponent(0.7)
        panel.lineWidth = 2

        let inner = SKShapeNode(rect: rect.insetBy(dx: 8, dy: 8), cornerRadius: 8)
        inner.fillColor = .clear
        inner.strokeColor = palette.secondAccent.withAlphaComponent(0.28)
        inner.lineWidth = 1
        panel.addChild(inner)
        return panel
    }

    private func makeLabel(_ text: String, size fontSize: CGFloat, y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = fontSize
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: self.size.width / 2, y: y)
        fitLabel(label, maxWidth: self.size.width - 36)

        let shadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        shadow.text = text
        shadow.fontSize = label.fontSize
        shadow.fontColor = SKColor.black.withAlphaComponent(0.75)
        shadow.horizontalAlignmentMode = .center
        shadow.verticalAlignmentMode = .center
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        label.addChild(shadow)
        return label
    }

    private func fitLabel(_ label: SKLabelNode, maxWidth: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > 12 {
            label.fontSize -= 1
        }
    }

    // MARK: - Settings Menu

    private func makeOverlayButton(text: String, name: String, y: CGFloat, width: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = CGPoint(x: size.width / 2, y: y)

        let palette = palette(for: currentCity)
        let backing = SKShapeNode(rectOf: CGSize(width: width, height: 38), cornerRadius: 8)
        backing.name = name
        backing.fillColor = palette.accent.withAlphaComponent(0.18)
        backing.strokeColor = palette.secondAccent.withAlphaComponent(0.78)
        backing.lineWidth = 1.6
        backing.glowWidth = 3
        container.addChild(backing)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.name = name
        label.text = text
        label.fontSize = 17
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        container.addChild(label)

        return container
    }

    private func showSettingsScreen(returnState: GameState) {
        settingsReturnState = returnState
        showingSettings = true
        setHUDVisible(false)

        overlayNode.removeAllChildren()
        overlayNode.addChild(makeDimmer())

        let panelHeight = min(size.height - 92, 520)
        overlayNode.addChild(makeOverlayPanel(y: size.height / 2, height: panelHeight))

        let topY = size.height / 2 + panelHeight / 2 - 58
        let title = makeLabel("SETTINGS", size: 34, y: topY)
        title.fontColor = palette(for: currentCity).accent
        overlayNode.addChild(title)

        let city = makeLabel("\(currentWorld.stageCode)  \(currentWorld.displayName.uppercased())", size: 14, y: topY - 34)
        city.fontColor = palette(for: currentCity).secondAccent
        fitLabel(city, maxWidth: size.width - 76)
        overlayNode.addChild(city)

        addVolumeSetting(
            title: "MUSIC VOLUME",
            value: percentText(AudioManager.shared.musicVolume),
            y: topY - 70,
            downName: "settings.musicDown",
            upName: "settings.musicUp"
        )

        addVolumeSetting(
            title: "SFX VOLUME",
            value: percentText(AudioManager.shared.sfxVolume),
            y: topY - 130,
            downName: "settings.sfxDown",
            upName: "settings.sfxUp"
        )

        addToggleSetting(
            title: "MUSIC",
            isOn: AudioManager.shared.isMusicEnabled,
            y: topY - 194,
            name: "settings.musicToggle"
        )

        addToggleSetting(
            title: "SFX",
            isOn: AudioManager.shared.isSFXEnabled,
            y: topY - 250,
            name: "settings.sfxToggle"
        )

        addToggleSetting(
            title: "HAPTICS",
            isOn: AudioManager.shared.isHapticsEnabled,
            y: topY - 306,
            name: "settings.hapticsToggle"
        )

        overlayNode.addChild(makeOverlayButton(text: "Back", name: "settings.back", y: size.height / 2 - panelHeight / 2 + 44, width: 124))
    }

    private func addVolumeSetting(title: String, value: String, y: CGFloat, downName: String, upName: String) {
        let titleLabel = settingsLabel(title, fontSize: 15, color: SKColor(white: 0.82, alpha: 1))
        titleLabel.horizontalAlignmentMode = .right
        titleLabel.position = CGPoint(x: size.width / 2 - 82, y: y)
        overlayNode.addChild(titleLabel)

        let valueLabel = settingsLabel(value, fontSize: 20, color: .white)
        valueLabel.position = CGPoint(x: size.width / 2 + 2, y: y)
        overlayNode.addChild(valueLabel)

        overlayNode.addChild(makeSettingsButton(text: "-", name: downName, center: CGPoint(x: size.width / 2 + 82, y: y), width: 34))
        overlayNode.addChild(makeSettingsButton(text: "+", name: upName, center: CGPoint(x: size.width / 2 + 126, y: y), width: 34))
    }

    private func addToggleSetting(title: String, isOn: Bool, y: CGFloat, name: String) {
        let titleLabel = settingsLabel(title, fontSize: 16, color: SKColor(white: 0.86, alpha: 1))
        titleLabel.horizontalAlignmentMode = .right
        titleLabel.position = CGPoint(x: size.width / 2 - 56, y: y)
        overlayNode.addChild(titleLabel)

        overlayNode.addChild(makeSettingsButton(text: isOn ? "ON" : "OFF", name: name, center: CGPoint(x: size.width / 2 + 52, y: y), width: 94))
    }

    private func settingsLabel(_ text: String, fontSize: CGFloat, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }

    private func makeSettingsButton(text: String, name: String, center: CGPoint, width: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = name
        container.position = center

        let palette = palette(for: currentCity)
        let backing = SKShapeNode(rectOf: CGSize(width: width, height: 34), cornerRadius: 7)
        backing.name = name
        backing.fillColor = palette.secondAccent.withAlphaComponent(0.2)
        backing.strokeColor = palette.accent.withAlphaComponent(0.85)
        backing.lineWidth = 1.4
        backing.glowWidth = 3
        container.addChild(backing)

        let label = settingsLabel(text, fontSize: 18, color: .white)
        label.name = name
        container.addChild(label)
        return container
    }

    private func handleSettingsTap(at location: CGPoint) {
        guard let name = nodeName(at: location) else { return }
        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "settings.musicDown":
            AudioManager.shared.setMusicVolume(AudioManager.shared.musicVolume - 0.1)
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.musicUp":
            AudioManager.shared.setMusicVolume(AudioManager.shared.musicVolume + 0.1)
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.sfxDown":
            AudioManager.shared.setSFXVolume(AudioManager.shared.sfxVolume - 0.1)
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.sfxUp":
            AudioManager.shared.setSFXVolume(AudioManager.shared.sfxVolume + 0.1)
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.musicToggle":
            AudioManager.shared.toggleMusic()
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.sfxToggle":
            AudioManager.shared.toggleSFX()
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.hapticsToggle":
            AudioManager.shared.toggleHaptics()
            showSettingsScreen(returnState: settingsReturnState)
        case "settings.back":
            showingSettings = false
            if settingsReturnState == .gameOver {
                showGameOverScreen()
            } else {
                showStartScreen()
            }
        default:
            break
        }
    }

    private func nodeName(at location: CGPoint) -> String? {
        for node in nodes(at: location) {
            var current: SKNode? = node
            while let candidate = current {
                if let name = candidate.name {
                    return name
                }
                current = candidate.parent
            }
        }
        return nil
    }

    private func percentText(_ value: Float) -> String {
        "\(Int(round(value * 100)))%"
    }

    // MARK: - Feel Effects

    private func prepareHaptics() {
        guard AudioManager.shared.isHapticsEnabled else { return }
        laneHaptic.prepare()
        nearMissHaptic.prepare()
        warningHaptic.prepare()
        crashHaptic.prepare()
    }

    private func shakeCamera(intensity: CGFloat, duration: TimeInterval) {
        guard SaveManager.shared.data.screenShakeEnabled else { return }
        let adjustedIntensity = SaveManager.shared.data.reducedFlashingEnabled ? intensity * 0.45 : intensity
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let stepDuration = 0.025
        let stepCount = max(1, Int(duration / stepDuration))
        var actions: [SKAction] = []

        gameCamera.removeAction(forKey: "cameraShake")

        for _ in 0..<stepCount {
            let offset = CGPoint(
                x: CGFloat.random(in: -adjustedIntensity...adjustedIntensity),
                y: CGFloat.random(in: -adjustedIntensity...adjustedIntensity)
            )
            actions.append(.move(to: CGPoint(x: center.x + offset.x, y: center.y + offset.y), duration: stepDuration))
        }

        actions.append(.move(to: center, duration: 0.02))
        gameCamera.run(.sequence(actions), withKey: "cameraShake")
    }

    private func updateTireSmoke(deltaTime: CGFloat) {
        guard gameState == .playing else { return }
        smokeTimer += TimeInterval(deltaTime)

        if smokeTimer >= 0.1 {
            smokeTimer = 0
            emitTireSmoke(count: 1, sidewaysPush: 0)
        }
    }

    private func emitTireSmoke(count: Int, sidewaysPush: CGFloat) {
        guard let playerCar else { return }

        for _ in 0..<count {
            let side: CGFloat = Bool.random() ? -1 : 1
            let radius = CGFloat.random(in: 3...8)
            let puff = SKShapeNode(circleOfRadius: radius)
            puff.fillColor = ArcadeArt.Palette.cream.withAlphaComponent(0.24)
            puff.strokeColor = ArcadeArt.Palette.asphaltLight.withAlphaComponent(0.18)
            puff.userData = ["assetID": ArcadeArt.EffectAsset.tireSmoke.rawValue]
            puff.position = CGPoint(
                x: playerCar.position.x + side * playerCar.size.width * 0.3 + CGFloat.random(in: -5...5),
                y: playerCar.position.y - playerCar.size.height * 0.48 + CGFloat.random(in: -5...5)
            )
            puff.alpha = CGFloat.random(in: 0.45...0.75)
            effectsNode.addChild(puff)

            let drift = SKAction.moveBy(
                x: CGFloat.random(in: -14...14) + sidewaysPush,
                y: -CGFloat.random(in: 24...60),
                duration: 0.5
            )
            let grow = SKAction.scale(to: CGFloat.random(in: 1.8...3.2), duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            puff.run(.sequence([.group([drift, grow, fade]), .removeFromParent()]))
        }
    }

    private func playCrashEffects(at position: CGPoint) {
        AudioManager.shared.play(.crash, volume: 1.0, cooldown: 0.4)
        AudioManager.shared.play(.debris, volume: 0.72, cooldown: 0.2)
        if AudioManager.shared.isHapticsEnabled {
            crashHaptic.notificationOccurred(.error)
            crashHaptic.prepare()
        }
        shakeCamera(intensity: 18, duration: 0.45)

        playerCar?.run(.sequence([
            .colorize(with: .white, colorBlendFactor: 0.9, duration: 0.04),
            .colorize(withColorBlendFactor: 0, duration: 0.12)
        ]))

        let reducedFlashing = SaveManager.shared.data.reducedFlashingEnabled
        let flash = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        flash.fillColor = SKColor.white.withAlphaComponent(reducedFlashing ? 0.18 : 0.72)
        flash.strokeColor = .clear
        flash.zPosition = 5
        floatingTextNode.addChild(flash)
        flash.run(.sequence([.fadeOut(withDuration: reducedFlashing ? 0.12 : 0.24), .removeFromParent()]))

        let ringColors: [SKColor] = [
            SKColor(red: 1, green: 0.86, blue: 0.12, alpha: 1),
            SKColor(red: 1, green: 0.28, blue: 0.04, alpha: 1),
            SKColor(red: 0.95, green: 0.04, blue: 0.03, alpha: 1)
        ]

        for index in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: 14 + CGFloat(index) * 7)
            ring.position = position
            ring.fillColor = .clear
            ring.strokeColor = ringColors[index]
            ring.lineWidth = 5
            ring.zPosition = 6
            floatingTextNode.addChild(ring)

            let scale = SKAction.scale(to: 4.0 + CGFloat(index) * 0.75, duration: 0.48)
            scale.timingMode = .easeOut
            ring.run(.sequence([.group([scale, .fadeOut(withDuration: 0.48)]), .removeFromParent()]))
        }

        let debrisColors: [SKColor] = [ArcadeArt.Palette.red, ArcadeArt.Palette.orange, ArcadeArt.Palette.gold, ArcadeArt.Palette.cream, ArcadeArt.Palette.asphaltDark]

        for _ in 0..<18 {
            let piece = SKSpriteNode(
                color: debrisColors.randomElement() ?? .orange,
                size: CGSize(width: CGFloat.random(in: 5...12), height: CGFloat.random(in: 4...10))
            )
            piece.position = CGPoint(
                x: position.x + CGFloat.random(in: -12...12),
                y: position.y + CGFloat.random(in: -10...12)
            )
            piece.zRotation = CGFloat.random(in: 0...(CGFloat.pi * 2))
            piece.zPosition = 7
            piece.userData = ["assetID": ArcadeArt.EffectAsset.crashSpark.rawValue]
            floatingTextNode.addChild(piece)

            let move = SKAction.moveBy(
                x: CGFloat.random(in: -90...90),
                y: CGFloat.random(in: -60...130),
                duration: TimeInterval.random(in: 0.36...0.68)
            )
            move.timingMode = .easeOut
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -5...5), duration: 0.58)
            piece.run(.sequence([.group([move, spin, .fadeOut(withDuration: 0.58)]), .removeFromParent()]))
        }

        for _ in 0..<12 {
            let smoke = SKShapeNode(circleOfRadius: CGFloat.random(in: 8...18))
            smoke.fillColor = ArcadeArt.Palette.cream.withAlphaComponent(CGFloat.random(in: 0.18...0.34))
            smoke.strokeColor = ArcadeArt.Palette.asphaltLight.withAlphaComponent(0.16)
            smoke.userData = ["assetID": ArcadeArt.EffectAsset.tireSmoke.rawValue]
            smoke.position = position
            smoke.zPosition = 6
            floatingTextNode.addChild(smoke)

            let move = SKAction.moveBy(
                x: CGFloat.random(in: -54...54),
                y: CGFloat.random(in: -18...82),
                duration: 0.7
            )
            let grow = SKAction.scale(to: CGFloat.random(in: 2.0...3.4), duration: 0.7)
            smoke.run(.sequence([.group([move, grow, .fadeOut(withDuration: 0.7)]), .removeFromParent()]))
        }
    }

    // MARK: - Controls

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        touchStart = location
        touchStartTime = touch.timestamp

        guard gameState == .playing, SaveManager.shared.data.controlPreference.allowsTap else { return }
        activeHoldDirection = location.x < size.width / 2 ? -1 : 1
        holdTimer = 0
        holdActivated = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if showingSettings {
            handleSettingsTap(at: location)
            resetTouchTracking()
            return
        }

        switch gameState {
        case .start:
            AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)
            if nodeName(at: location) == "settings.open" {
                showSettingsScreen(returnState: gameState)
                resetTouchTracking()
                return
            }
            startGame()

        case .gameOver:
            if showingReviveOffer, let name = nodeName(at: location) {
                AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)
                if name == "revive.accept" {
                    acceptRevive()
                } else if name == "revive.decline" {
                    finalizeGameOver(crashPoint: pendingCrashPoint, playCrash: false, reason: pendingCrashReason)
                }
            }

        case .playing:
            let start = touchStart ?? location
            let dx = location.x - start.x
            let dy = location.y - start.y
            let elapsed = max(0.04, touch.timestamp - touchStartTime)
            let horizontalVelocity = abs(dx) / CGFloat(elapsed)
            let preference = SaveManager.shared.data.controlPreference

            if holdActivated {
                break
            } else if preference.allowsSwipe && abs(dx) > 34 && abs(dx) > abs(dy) {
                let direction = dx > 0 ? 1 : -1
                let veryFast = horizontalVelocity > 1_550 || abs(dx) > 160
                let fast = veryFast || horizontalVelocity > 880 || abs(dx) > 86
                let requestedLanes: Int
                if dodgeBoostTimer > 0, veryFast {
                    requestedLanes = 3
                } else if fast {
                    requestedLanes = 2
                } else {
                    requestedLanes = 1
                }
                movePlayer(by: direction * requestedLanes, kind: requestedLanes > 1 ? .fastSwipe : .swipe)
            } else if preference.allowsTap {
                movePlayer(by: location.x < size.width / 2 ? -1 : 1, kind: .tap)
            }
        }

        resetTouchTracking()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouchTracking()
    }

    private func resetTouchTracking() {
        touchStart = nil
        touchStartTime = 0
        activeHoldDirection = 0
        holdTimer = 0
        holdActivated = false
    }

    private func updateHoldMovement(deltaTime: TimeInterval) {
        guard gameState == .playing,
              activeHoldDirection != 0,
              SaveManager.shared.data.controlPreference.allowsTap else { return }

        holdTimer += deltaTime
        let repeatInterval: TimeInterval = activeCar.vehicleClass == .motorcycle
            ? (dodgeBoostTimer > 0 ? 0.082 : 0.108)
            : (dodgeBoostTimer > 0 ? 0.105 : 0.135)

        if !holdActivated {
            guard holdTimer >= 0.22 else { return }
            holdActivated = true
            holdTimer = 0
            movePlayer(by: activeHoldDirection, kind: .hold)
        } else if holdTimer >= repeatInterval {
            holdTimer = 0
            movePlayer(by: activeHoldDirection, kind: .hold)
        }
    }

    private func setPlayerSlot(_ slot: Int) {
        playerSlot = laneManager.clampSlot(slot, for: activeCar.vehicleClass)
        playerLane = laneManager.nearestLaneForSlot(playerSlot)
    }

    private func movePlayer(by laneDelta: Int, kind: LaneMoveKind = .swipe) {
        guard gameState == .playing else { return }
        let requestedSlotDelta = laneDelta * (activeCar.vehicleClass == .car ? 2 : 1)
        let readableDelta = readableSlotDelta(for: requestedSlotDelta, kind: kind)
        guard readableDelta != 0 else { return }
        let nextSlot = laneManager.targetSlot(from: playerSlot, delta: readableDelta, vehicleClass: activeCar.vehicleClass)
        guard nextSlot != playerSlot else { return }

        let previousLane = playerLane
        let previousSlot = playerSlot
        let nextLane = laneManager.nearestLaneForSlot(nextSlot)
        let clutchRisk = clutchRiskForLaneChange(from: previousLane, to: nextLane)
        let idleBeforeMove = timeSinceLastLaneChange
        setPlayerSlot(nextSlot)
        timeSinceLastLaneChange = 0
        passivePressureAlertShown = false
        AudioManager.shared.play(.laneChange, volume: 0.62, cooldown: 0.05)
        if AudioManager.shared.isHapticsEnabled {
            let baseIntensity: CGFloat = activeCar.vehicleClass == .motorcycle ? 0.34 : 0.48
            laneHaptic.impactOccurred(intensity: min(0.9, baseIntensity + CGFloat(abs(readableDelta)) * 0.08))
            laneHaptic.prepare()
        }
        emitTireSmoke(count: kind == .fastSwipe ? 12 : 8, sidewaysPush: CGFloat(-readableDelta) * 16)
        positionPlayer(animated: true, laneDelta: readableDelta, kind: kind)
        if clutchRisk > 0.55 {
            triggerClutchSave(risk: clutchRisk, at: CGPoint(x: laneManager.xPositionForSlot(playerSlot), y: playerY + 58))
        }
        easePassivePolicePressureAfterLaneChange(idleTime: idleBeforeMove, laneDelta: readableDelta)
        if activeCar.vehicleClass == .motorcycle, laneManager.isSplitSlot(previousSlot) != laneManager.isSplitSlot(playerSlot) {
            emitBikeSlotStreak(direction: readableDelta > 0 ? 1 : -1)
        }
        recordTelemetry(event: "lane_changed")
    }

    private func readableSlotDelta(for slotDelta: Int, kind: LaneMoveKind) -> Int {
        let targetDelta = laneManager.targetSlot(from: playerSlot, delta: slotDelta, vehicleClass: activeCar.vehicleClass) - playerSlot
        guard targetDelta != 0 else { return 0 }

        // Multi-lane dashes should feel powerful, but not blind. If the far target is about
        // to collide, degrade to a shorter dash rather than throwing the player into a wall.
        guard abs(targetDelta) > (activeCar.vehicleClass == .car ? 2 : 1) else { return targetDelta }
        let direction = targetDelta > 0 ? 1 : -1
        var candidate = targetDelta
        while candidate != 0 {
            let slot = laneManager.targetSlot(from: playerSlot, delta: candidate, vehicleClass: activeCar.vehicleClass)
            let lane = laneManager.nearestLaneForSlot(slot)
            if kind != .fastSwipe || hazardDanger(inLane: lane) < 0.86 {
                return slot - playerSlot
            }
            candidate -= direction
        }
        let fallback = laneManager.targetSlot(from: playerSlot, delta: direction, vehicleClass: activeCar.vehicleClass)
        return fallback - playerSlot
    }

    private func positionPlayer(animated: Bool, laneDelta: Int = 0, kind: LaneMoveKind = .swipe) {
        guard let playerCar, slotCenters.indices.contains(playerSlot) else { return }
        let target = CGPoint(x: slotCenters[playerSlot], y: playerY)

        if animated {
            playerCar.removeAction(forKey: "laneChange")
            playerCar.removeAction(forKey: "laneTilt")

            let handlingScale = max(0.88, min(activeCar.vehicleClass == .motorcycle ? 1.3 : 1.16, activeCar.handling))
            let laneDistance = max(1, abs(laneDelta))
            let baseMoveDuration: TimeInterval
            switch kind {
            case .fastSwipe:
                baseMoveDuration = activeCar.vehicleClass == .motorcycle ? 0.128 : (laneDistance >= 3 ? 0.18 : 0.16)
            case .hold:
                baseMoveDuration = activeCar.vehicleClass == .motorcycle ? 0.085 : 0.105
            case .tap, .swipe:
                baseMoveDuration = activeCar.vehicleClass == .motorcycle ? 0.098 : 0.12
            }
            let boostScale: TimeInterval = dodgeBoostTimer > 0 ? 0.74 : 1
            let levelScale = currentLevel.map { LevelDifficultyConfig.snapshot(for: $0, elapsed: runTime, exitActive: exitPhase == .active).laneChangeDurationScale } ?? 1
            let moveDuration = baseMoveDuration * boostScale * levelScale / TimeInterval(handlingScale)
            let move = SKAction.move(to: target, duration: moveDuration)
            move.timingMode = .easeOut
            playerCar.run(move, withKey: "laneChange")

            let maxTilt: CGFloat = activeCar.vehicleClass == .motorcycle ? 0.46 : 0.28
            let tiltAngle = CGFloat(laneDelta > 0 ? -1 : 1) * min(maxTilt, 0.13 + CGFloat(laneDistance) * (activeCar.vehicleClass == .motorcycle ? 0.07 : 0.045))
            let lean = SKAction.rotate(toAngle: tiltAngle, duration: max(0.026, moveDuration * 0.32), shortestUnitArc: true)
            let recover = SKAction.rotate(toAngle: 0, duration: max(0.08, moveDuration * 0.86), shortestUnitArc: true)
            recover.timingMode = .easeOut
            if activeCar.vehicleClass == .motorcycle {
                let wobble = SKAction.sequence([
                    lean,
                    .rotate(toAngle: -tiltAngle * 0.18, duration: max(0.045, moveDuration * 0.42), shortestUnitArc: true),
                    recover
                ])
                playerCar.run(wobble, withKey: "laneTilt")
            } else {
                playerCar.run(.sequence([lean, recover]), withKey: "laneTilt")
            }
        } else {
            playerCar.removeAction(forKey: "laneTilt")
            playerCar.position = target
            playerCar.zRotation = 0
        }
    }

    // MARK: - Mobility, Dodge Boost, and Clutch Saves

    private func activateDodgeBoost() {
        dodgeBoostCount += 1
        dodgeBoostTimer = max(dodgeBoostTimer, 1.5 * activeCar.dodgeBoost)
        AudioManager.shared.play(.dodgeBoost, volume: 0.68, cooldown: 0.16)
        emitDodgeBoostStreaks(count: 8)
    }

    private func updateDodgeBoostEffects(deltaTime: TimeInterval) {
        guard dodgeBoostTimer > 0 else { return }
        dodgeBoostStreakTimer += deltaTime

        if dodgeBoostStreakTimer >= 0.08 {
            dodgeBoostStreakTimer = 0
            emitDodgeBoostStreaks(count: 2)
        }
    }

    private func updateComboSpectacle(deltaTime: TimeInterval) {
        guard let playerCar else { return }
        comboAuraNode.position = playerCar.position

        let targetAlpha: CGFloat
        if comboCount >= 10 {
            targetAlpha = 0.95
        } else if comboCount >= 8 {
            targetAlpha = 0.72
        } else if comboCount >= 5 {
            targetAlpha = 0.48
        } else if comboCount >= 3 {
            targetAlpha = 0.28
        } else {
            targetAlpha = 0
        }

        comboAuraNode.alpha += (targetAlpha - comboAuraNode.alpha) * CGFloat(min(1, deltaTime * 8))
        guard comboCount >= 3 else { return }

        if comboAuraNode.children.isEmpty {
            let palette = palette(for: currentCity)
            for index in 0..<2 {
                let ring = SKShapeNode(ellipseOf: CGSize(width: playerCar.size.width * (1.4 + CGFloat(index) * 0.35), height: playerCar.size.height * (1.15 + CGFloat(index) * 0.28)))
                ring.fillColor = .clear
                ring.strokeColor = (index == 0 ? palette.accent : palette.secondAccent).withAlphaComponent(0.7)
                ring.lineWidth = 3
                ring.glowWidth = comboCount >= 8 ? 12 : 6
                comboAuraNode.addChild(ring)
                ring.run(.repeatForever(.sequence([
                    .scale(to: 1.12, duration: 0.45),
                    .scale(to: 0.94, duration: 0.45)
                ])))
            }
        }
    }

    private func updateCameraJuice(deltaTime: CGFloat) {
        guard SaveManager.shared.data.screenShakeEnabled,
              gameCamera.action(forKey: "cameraShake") == nil else { return }

        cameraJuicePhase += deltaTime * (roadSpeed / 120)
        let speedPressure = max(0, min(1, (roadSpeed - 330) / 230))
        let comboPressure = max(0, min(1, CGFloat(comboCount) / 10))
        let intensity = (speedPressure * 1.4) + (comboPressure * 1.1)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        gameCamera.position = CGPoint(
            x: center.x + sin(cameraJuicePhase * 1.7) * intensity,
            y: center.y + cos(cameraJuicePhase * 2.3) * intensity
        )
    }

    private func emitDodgeBoostStreaks(count: Int) {
        guard let playerCar else { return }
        let palette = palette(for: currentCity)

        for _ in 0..<count {
            let streak = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 24...58)), cornerRadius: 1.5)
            streak.fillColor = [palette.accent, palette.secondAccent, ArcadeArt.Palette.cream].randomElement()?.withAlphaComponent(0.72) ?? ArcadeArt.Palette.cream
            streak.strokeColor = .clear
            streak.glowWidth = 3
            streak.userData = ["assetID": ArcadeArt.EffectAsset.boostTrail.rawValue]
            streak.position = CGPoint(
                x: playerCar.position.x + CGFloat.random(in: -playerCar.size.width * 0.48...playerCar.size.width * 0.48),
                y: playerCar.position.y - playerCar.size.height * 0.44 + CGFloat.random(in: -8...10)
            )
            streak.zPosition = 4
            effectsNode.addChild(streak)

            let move = SKAction.moveBy(x: CGFloat.random(in: -9...9), y: -CGFloat.random(in: 56...102), duration: 0.22)
            let fade = SKAction.fadeOut(withDuration: 0.22)
            streak.run(.sequence([.group([move, fade]), .removeFromParent()]))
        }
    }

    private func emitBikeSlotStreak(direction: Int) {
        guard activeCar.vehicleClass == .motorcycle, let playerCar else { return }
        let palette = palette(for: currentCity)
        for index in 0..<5 {
            let streak = SKShapeNode(rectOf: CGSize(width: 2, height: CGFloat.random(in: 18...34)), cornerRadius: 1)
            streak.fillColor = (index.isMultiple(of: 2) ? activeCar.accentColor : palette.accent).withAlphaComponent(0.8)
            streak.strokeColor = .clear
            streak.glowWidth = 3
            streak.userData = ["assetID": ArcadeArt.EffectAsset.speedStreak.rawValue]
            streak.position = CGPoint(
                x: playerCar.position.x - CGFloat(direction) * CGFloat.random(in: 6...15),
                y: playerCar.position.y - CGFloat.random(in: 16...34)
            )
            streak.zRotation = CGFloat(direction) * 0.18
            streak.zPosition = 5
            effectsNode.addChild(streak)
            streak.run(.sequence([
                .group([
                    .moveBy(x: CGFloat(-direction) * CGFloat.random(in: 12...26), y: -CGFloat.random(in: 34...68), duration: 0.18),
                    .fadeOut(withDuration: 0.18)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func clutchRiskForLaneChange(from oldLane: Int, to newLane: Int) -> CGFloat {
        let oldDanger = hazardDanger(inLane: oldLane)
        let newDanger = hazardDanger(inLane: newLane)
        let blockedLanes = (0..<laneCount).filter { hazardDanger(inLane: $0) > 0.42 }.count

        var risk = oldDanger - newDanger * 0.55
        if blockedLanes >= 3 {
            risk += 0.18
        }
        if blockedLanes >= 4 {
            risk += 0.2
        }
        if oldDanger > 0.78 && newDanger < 0.36 {
            risk += 0.18
        }

        return max(0, min(1, risk))
    }

    private func hazardDanger(inLane lane: Int) -> CGFloat {
        guard let playerCar else { return 0 }
        var danger: CGFloat = 0

        for node in trafficNode.children {
            guard let vehicle = node as? SKSpriteNode,
                  let vehicleLane = vehicle.userData?["lane"] as? Int else {
                continue
            }

            let span = vehicle.userData?["laneSpan"] as? Int ?? 1
            guard occupiedLanes(for: vehicleLane, span: span).contains(lane) else { continue }

            let verticalDistance = vehicle.position.y - playerY
            let dangerWindow = max(115, playerCar.size.height * 1.45)
            guard verticalDistance > -playerCar.size.height * 0.45, verticalDistance < dangerWindow else {
                continue
            }

            let normalized = 1 - max(0, verticalDistance) / dangerWindow
            let collisionPadding = vehicle.size.height * 0.18
            let extra = verticalDistance < playerCar.size.height * 0.42 + collisionPadding ? CGFloat(0.24) : 0
            danger = max(danger, min(1, normalized + extra))
        }

        return danger
    }

    private func triggerClutchSave(risk: CGFloat, at position: CGPoint) {
        guard clutchSaveCooldown == 0 else { return }
        clutchSaveCooldown = 0.75

        let tier: ClutchSaveTier
        if risk > 0.9 {
            tier = .threadingNeedle
        } else if risk > 0.74 {
            tier = .insaneSave
        } else {
            tier = .closeCall
        }

        clutchSaveCount += 1
        let scoreBonus = Int(CGFloat(tier.scoreBonus) * scoreMultiplier)
        let cashBonus = tier.cashBonus + wantedLevel * 2 + min(comboCount, 5)
        score += scoreBonus
        runCash += cashBonus
        activateDodgeBoost()
        updateHUD()

        AudioManager.shared.play(.clutchSave, volume: 0.9, cooldown: 0.18)
        buddy.say(.clutchSave, force: false)
        if AudioManager.shared.isHapticsEnabled {
            warningHaptic.impactOccurred(intensity: min(1, 0.55 + risk * 0.4))
            warningHaptic.prepare()
        }

        showAwardPopup(
            title: tier.title,
            subtitle: "+\(scoreBonus)  +$\(cashBonus)",
            at: position,
            color: palette(for: currentCity).accent,
            scale: risk > 0.9 ? 1.2 : 1.0
        )
        emitClutchSaveBurst(at: position, intensity: risk)
        shakeCamera(intensity: risk > 0.9 ? 8 : 5, duration: 0.18)
    }

    private func emitClutchSaveBurst(at position: CGPoint, intensity: CGFloat) {
        let palette = palette(for: currentCity)
        for index in 0..<2 {
            let ring = SKShapeNode(circleOfRadius: 18 + CGFloat(index) * 8)
            ring.position = position
            ring.fillColor = .clear
            ring.strokeColor = index == 0 ? palette.accent : palette.secondAccent
            ring.lineWidth = 4
            ring.glowWidth = 6
            floatingTextNode.addChild(ring)

            let scale = SKAction.scale(to: 2.6 + intensity * 1.2, duration: 0.34)
            scale.timingMode = .easeOut
            ring.run(.sequence([.group([scale, .fadeOut(withDuration: 0.34)]), .removeFromParent()]))
        }

        emitNearMissSparks(at: position)
        emitDodgeBoostStreaks(count: 12)
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else {
            lastUpdateTime = currentTime
            return
        }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let rawDeltaTime = min(CGFloat(currentTime - lastUpdateTime), 0.05)
        lastUpdateTime = currentTime

        let deltaTime = rawDeltaTime
        runTime += TimeInterval(rawDeltaTime)
        timeSinceLastLaneChange += TimeInterval(rawDeltaTime)
        passivePressureWarningCooldown = max(0, passivePressureWarningCooldown - TimeInterval(rawDeltaTime))
        warningHapticCooldown = max(0, warningHapticCooldown - TimeInterval(rawDeltaTime))
        dodgeBoostTimer = max(0, dodgeBoostTimer - TimeInterval(rawDeltaTime))
        clutchSaveCooldown = max(0, clutchSaveCooldown - TimeInterval(rawDeltaTime))
        roadblockCooldown = max(0, roadblockCooldown - TimeInterval(rawDeltaTime))
        invulnerabilityTimer = max(0, invulnerabilityTimer - TimeInterval(rawDeltaTime))
        AtmosphereManager.shared.update(deltaTime: TimeInterval(rawDeltaTime))

        updateHoldMovement(deltaTime: TimeInterval(rawDeltaTime))
        updateStoryChase(deltaTime: TimeInterval(rawDeltaTime))
        guard gameState == .playing else { return }
        scrollRoad(deltaTime: deltaTime)
        updateSpeedLines(deltaTime: deltaTime)
        updateTireSmoke(deltaTime: rawDeltaTime)
        updateDodgeBoostEffects(deltaTime: TimeInterval(rawDeltaTime))
        updateComboSpectacle(deltaTime: TimeInterval(rawDeltaTime))
        updateTraffic(deltaTime: deltaTime)
        updateRoadEvents(deltaTime: TimeInterval(deltaTime))
        updateWantedLevel()
        applyDebugOverrides()
        updateRoadblocks()
        updateSpawning(deltaTime: TimeInterval(deltaTime))
        updateDifficulty(deltaTime: TimeInterval(deltaTime))
        updateCombo(deltaTime: TimeInterval(rawDeltaTime))
        updateScore(deltaTime: deltaTime)
        updateCityIfNeeded()
        positionPolice(deltaTime: deltaTime)
        updatePoliceSupport(deltaTime: deltaTime)
        updateHelicopter(deltaTime: TimeInterval(rawDeltaTime))
        updatePoliceWarning()
        updatePassivePolicePressureCues()
        updateDynamicAudioAndAtmosphere()
        updateCameraJuice(deltaTime: deltaTime)
        applyScreenshotMode()
        pruneTransientNodes()
        updateDebugAutoplay(deltaTime: TimeInterval(rawDeltaTime))
        updatePerformanceDebug(deltaTime: TimeInterval(rawDeltaTime))
        updateTrafficDiagnostics()
        checkCollisions()
    }

    private func pruneTransientNodes() {
        trimChildren(of: effectsNode, keeping: 150)
        trimChildren(of: floatingTextNode, keeping: 90)
        trimChildren(of: trafficNode, keeping: 72)
    }

    private func trimChildren(of node: SKNode, keeping maxCount: Int) {
        guard node.children.count > maxCount else { return }
        for child in node.children.prefix(node.children.count - maxCount) {
            if child !== comboAuraNode && child !== performanceDebugLabel {
                child.removeFromParent()
            }
        }
    }

    private func updateDebugAutoplay(deltaTime: TimeInterval) {
        guard AppConfig.debugMode, AppConfig.debugAutoplay, gameState == .playing else { return }
        guard playerCar?.action(forKey: "laneChange") == nil else { return }

        debugAutoplayTimer = max(0, debugAutoplayTimer - deltaTime)
        guard debugAutoplayTimer <= 0 else { return }
        debugAutoplayTimer = activeCar.vehicleClass == .motorcycle ? 0.105 : 0.13

        let validSlots = Set(laneManager.validSlots(for: activeCar.vehicleClass))
        var safeSlots: Set<Int>
        if let latestTrafficPlan {
            safeSlots = activeCar.vehicleClass == .motorcycle ? latestTrafficPlan.safeMotorcycleSlots : latestTrafficPlan.safeCarSlots
            safeSlots = safeSlots.intersection(validSlots)
        } else {
            safeSlots = validSlots
        }

        if exitPhase == .active, let activeExitSide {
            safeSlots.formUnion(laneManager.exitSlots(for: activeExitSide, vehicleClass: activeCar.vehicleClass))
        }

        guard !safeSlots.isEmpty else { return }

        let maxStep: Int
        if activeCar.vehicleClass == .motorcycle {
            maxStep = dodgeBoostTimer > 0 ? 3 : 2
        } else {
            maxStep = dodgeBoostTimer > 0 ? 6 : 4
        }

        let reachable = safeSlots.filter { abs($0 - playerSlot) <= maxStep }
        guard !reachable.isEmpty else { return }

        let desiredSlot: Int
        if exitPhase == .active, let activeExitSide {
            let exitSlots = laneManager.exitSlots(for: activeExitSide, vehicleClass: activeCar.vehicleClass)
            desiredSlot = activeExitSide == .left ? (exitSlots.min() ?? 0) : (exitSlots.max() ?? LaneManager.slotCount - 1)
        } else {
            desiredSlot = LaneManager.startSlot
        }

        guard let targetSlot = reachable.min(by: { lhs, rhs in
            debugRouteScore(slot: lhs, desiredSlot: desiredSlot) < debugRouteScore(slot: rhs, desiredSlot: desiredSlot)
        }) else { return }

        let delta = targetSlot - playerSlot
        guard delta != 0 else { return }

        let moveDelta: Int
        if activeCar.vehicleClass == .car {
            moveDelta = max(-3, min(3, delta / 2))
        } else {
            moveDelta = max(-3, min(3, delta))
        }
        guard moveDelta != 0 else { return }

        movePlayer(by: moveDelta, kind: abs(moveDelta) > 1 ? .fastSwipe : .swipe)
    }

    private func debugRouteScore(slot: Int, desiredSlot: Int) -> CGFloat {
        let lane = laneManager.nearestLaneForSlot(slot)
        var danger = hazardDanger(inLane: lane)
        if activeCar.vehicleClass == .motorcycle, laneManager.isSplitSlot(slot) {
            let leftLane = max(0, lane - 1)
            danger = max(danger * 0.65, min(hazardDanger(inLane: leftLane), danger) * 0.45)
        }

        let exitUrgency: CGFloat = exitPhase == .active ? 1.55 : 1
        let desiredCost = CGFloat(abs(slot - desiredSlot)) * exitUrgency
        let movementCost = CGFloat(abs(slot - playerSlot)) * 0.26
        return desiredCost + movementCost + danger * 8.5
    }

    private func updatePerformanceDebug(deltaTime: TimeInterval) {
        guard AppConfig.debugMode else { return }
        guard AppConfig.showPerformanceOverlay else {
            performanceDebugLabel.removeFromParent()
            performanceSampleTimer = 0
            performanceFrameCounter = 0
            return
        }

        if performanceDebugLabel.parent == nil {
            performanceDebugLabel.fontSize = 10
            performanceDebugLabel.horizontalAlignmentMode = .left
            performanceDebugLabel.verticalAlignmentMode = .top
            performanceDebugLabel.zPosition = 250
            floatingTextNode.addChild(performanceDebugLabel)
        }

        performanceFrameCounter += 1
        performanceSampleTimer += deltaTime
        performanceDebugLabel.position = CGPoint(x: 12, y: size.height - 76)

        guard performanceSampleTimer >= 0.5 else { return }
        let fps = Int(round(Double(performanceFrameCounter) / max(0.001, performanceSampleTimer)))
        let totalNodes = recursiveNodeCount(self)
        performanceDebugLabel.fontColor = totalNodes > 560 ? UITheme.Color.gold : UITheme.Color.green
        performanceDebugLabel.text = "FPS \(fps)  N \(totalNodes)  Traffic \(trafficNode.children.count)  FX \(effectsNode.children.count)  Text \(floatingTextNode.children.count)"
        performanceSampleTimer = 0
        performanceFrameCounter = 0
    }

    private func recursiveNodeCount(_ node: SKNode) -> Int {
        1 + node.children.reduce(0) { $0 + recursiveNodeCount($1) }
    }

    private func updateTrafficDiagnostics() {
        guard AppConfig.debugMode, AppConfig.showOpenLaneAnalysis, gameState == .playing else {
            diagnosticOverlayNode.removeAllChildren()
            return
        }

        diagnosticOverlayNode.removeAllChildren()
        drawDiagnosticRoadGuides()
        drawDiagnosticExitCorridor()
        drawDiagnosticSafeSlots()
        drawDiagnosticHitboxes()
        drawDiagnosticHeader()
    }

    private func drawDiagnosticRoadGuides() {
        for lane in 0..<laneCenters.count {
            let guide = SKShapeNode(rect: CGRect(x: laneCenters[lane] - 0.75, y: 0, width: 1.5, height: size.height))
            guide.fillColor = SKColor.cyan.withAlphaComponent(0.18)
            guide.strokeColor = .clear
            diagnosticOverlayNode.addChild(guide)
        }

        for slot in 0..<slotCenters.count {
            let guide = SKShapeNode(rect: CGRect(x: slotCenters[slot] - 0.5, y: 0, width: 1, height: size.height))
            guide.fillColor = SKColor.white.withAlphaComponent(laneManager.isSplitSlot(slot) ? 0.18 : 0.08)
            guide.strokeColor = .clear
            diagnosticOverlayNode.addChild(guide)
        }
    }

    private func drawDiagnosticExitCorridor() {
        guard exitPhase == .active, let activeExitSide else { return }

        for lane in laneManager.exitGuardLanes(for: activeExitSide) where laneCenters.indices.contains(lane) {
            let laneRect = CGRect(
                x: laneCenters[lane] - laneWidth / 2,
                y: 0,
                width: laneWidth,
                height: size.height
            )
            let corridor = SKShapeNode(rect: laneRect)
            corridor.fillColor = UITheme.Color.gold.withAlphaComponent(0.12)
            corridor.strokeColor = UITheme.Color.gold.withAlphaComponent(0.52)
            corridor.lineWidth = 1.5
            diagnosticOverlayNode.addChild(corridor)
        }
    }

    private func drawDiagnosticSafeSlots() {
        let validSlots = Set(laneManager.validSlots(for: activeCar.vehicleClass))
        let planSlots: Set<Int>
        if let latestTrafficPlan {
            planSlots = activeCar.vehicleClass == .motorcycle ? latestTrafficPlan.safeMotorcycleSlots : latestTrafficPlan.safeCarSlots
        } else {
            planSlots = validSlots
        }

        let safeSlots = planSlots.intersection(validSlots)
        let maxStep = activeCar.vehicleClass == .motorcycle ? (dodgeBoostTimer > 0 ? 3 : 2) : (dodgeBoostTimer > 0 ? 6 : 4)
        let reachableSlots = safeSlots.filter { abs($0 - playerSlot) <= maxStep }

        for slot in safeSlots.sorted() where slotCenters.indices.contains(slot) {
            let isReachable = reachableSlots.contains(slot)
            let marker = SKShapeNode(rectOf: CGSize(width: max(8, laneWidth * 0.2), height: size.height * 0.72), cornerRadius: 3)
            marker.position = CGPoint(x: slotCenters[slot], y: size.height * 0.48)
            marker.fillColor = UITheme.Color.green.withAlphaComponent(isReachable ? 0.2 : 0.08)
            marker.strokeColor = UITheme.Color.green.withAlphaComponent(isReachable ? 0.72 : 0.28)
            marker.lineWidth = isReachable ? 2 : 1
            diagnosticOverlayNode.addChild(marker)
        }
    }

    private func drawDiagnosticHitboxes() {
        let nearMissHeight = (playerCar?.size.height ?? 72) * 1.72
        let nearMissBand = SKShapeNode(rect: CGRect(x: roadLeft, y: playerY - nearMissHeight / 2, width: roadWidth, height: nearMissHeight))
        nearMissBand.fillColor = SKColor.cyan.withAlphaComponent(0.06)
        nearMissBand.strokeColor = SKColor.cyan.withAlphaComponent(0.38)
        nearMissBand.lineWidth = 1
        diagnosticOverlayNode.addChild(nearMissBand)

        let playerRect = playerHitboxRect()
        if !playerRect.isNull {
            diagnosticOverlayNode.addChild(diagnosticRect(playerRect, color: UITheme.Color.green, alpha: 0.82, lineWidth: 2))
        }

        for node in trafficNode.children {
            guard let vehicle = node as? SKSpriteNode else { continue }
            let isRoadblock = vehicle.userData?["roadblock"] as? Bool == true
            diagnosticOverlayNode.addChild(diagnosticRect(trafficHitboxRect(for: vehicle), color: isRoadblock ? UITheme.Color.gold : SKColor.red, alpha: 0.74, lineWidth: isRoadblock ? 2 : 1.5))
        }
    }

    private func diagnosticRect(_ rect: CGRect, color: SKColor, alpha: CGFloat, lineWidth: CGFloat) -> SKShapeNode {
        let node = SKShapeNode(rect: rect)
        node.fillColor = color.withAlphaComponent(0.08)
        node.strokeColor = color.withAlphaComponent(alpha)
        node.lineWidth = lineWidth
        return node
    }

    private func drawDiagnosticHeader() {
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.fontSize = 10
        label.fontColor = SKColor.white.withAlphaComponent(0.92)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        label.position = CGPoint(x: roadLeft + 8, y: size.height - 112)
        let pattern = latestTrafficPlan?.patternName ?? "none"
        let exitText = activeExitSide.map { " exit \($0.displayName)" } ?? ""
        label.text = "seed \(runSeed)  wave \(pattern)  slot \(playerSlot)\(exitText)"
        diagnosticOverlayNode.addChild(label)
    }

    // MARK: - Story Chase Levels and Exit Escapes

    private func updateStoryChase(deltaTime: TimeInterval) {
        guard gameMode == .storyChase, let currentLevel else { return }

        applyLevelDifficulty(currentLevel)

        if emergencyExitTimer > 0 {
            emergencyExitTimer = max(0, emergencyExitTimer - deltaTime)
            if emergencyExitTimer == 0 {
                activateExit(side: currentLevel.exitSide.opposite, isEmergency: true)
            }
        }

        if !exitAnticipationShown, !primaryExitTriggered, runTime >= max(0, currentLevel.durationBeforeExit - 5) {
            exitAnticipationShown = true
            showExitAnticipation(side: currentLevel.exitSide)
        }

        if !primaryExitTriggered, (runTime >= currentLevel.durationBeforeExit || (AppConfig.forceExitEvent && runTime > 4)) {
            primaryExitTriggered = true
            activateExit(side: currentLevel.exitSide, isEmergency: false)
        }

        guard exitPhase == .active else { return }
        exitCountdown = max(0, exitCountdown - deltaTime)
        updateExitCountdownLabel()
        updateExitGuidance(deltaTime: deltaTime)
        if exitCountdown <= 5, exitCountdown > 0 {
            buddy.say(.exitCountdown, detail: "Exit window closing!", force: false)
        }

        if playerReachedExitRamp() {
            completeLevelEscape()
        } else if exitCountdown == 0 {
            missExit()
        }
    }

    private func applyLevelDifficulty(_ level: LevelDefinition) {
        let snapshot = LevelDifficultyConfig.snapshot(for: level, elapsed: runTime, exitActive: exitPhase == .active)
        roadSpeed = snapshot.roadSpeed
        trafficSpeed = snapshot.trafficSpeed
        spawnInterval = snapshot.spawnInterval
        policeClosingSpeed = snapshot.policeClosingSpeed
    }

    private func activateExit(side: ExitSide, isEmergency: Bool) {
        guard exitPhase != .completed else { return }
        exitPhase = .active
        activeExitSide = side
        exitIsEmergency = isEmergency
        exitActivatedAt = runTime

        let baseWindow = currentLevel?.exitWindowSeconds ?? 10
        exitCountdown = isEmergency ? max(7, min(10, baseWindow + 2)) : baseWindow
        clearExitApproach(side: side)
        buildExitRamp(side: side, isEmergency: isEmergency)
        let category: BuddyLineCategory = side == .left ? .exitWarningLeft : .exitWarningRight
        buddy.say(
            category,
            detail: isEmergency ? "Emergency exit on the \(side.displayName)!" : "Exit on the \(side.displayName) in \(Int(exitCountdown)) seconds!",
            force: true
        )

        AudioManager.shared.play(.cityTransition, volume: 0.86, cooldown: 0.4)
        if AudioManager.shared.isHapticsEnabled {
            warningHaptic.impactOccurred(intensity: isEmergency ? 0.9 : 0.68)
            warningHaptic.prepare()
        }
        shakeCamera(intensity: 5, duration: 0.16)
        recordTelemetry(event: isEmergency ? "emergency_exit_activated" : "exit_activated")
    }

    private func showExitAnticipation(side: ExitSide) {
        let palette = palette(for: currentCity)
        let sign = SKShapeNode(rectOf: CGSize(width: min(size.width * 0.54, 210), height: 40), cornerRadius: 7)
        sign.position = CGPoint(x: side == .left ? size.width * 0.31 : size.width * 0.69, y: size.height * 0.76)
        sign.fillColor = currentWorld.exitSignFill(isEmergency: false).withAlphaComponent(0.72)
        sign.strokeColor = palette.edgeLine.withAlphaComponent(0.76)
        sign.lineWidth = 2
        sign.glowWidth = 5
        sign.zPosition = 9
        floatingTextNode.addChild(sign)

        let label = UIHelpers.label("EXIT SOON  \(side.displayName)", size: 17, color: ArcadeArt.Palette.cream, width: sign.frame.width - 18)
        label.position = .zero
        sign.addChild(label)

        sign.setScale(0.88)
        sign.run(.sequence([
            .group([.fadeIn(withDuration: 0.08), .scale(to: 1, duration: 0.1)]),
            .wait(forDuration: 1.1),
            .fadeOut(withDuration: 0.28),
            .removeFromParent()
        ]))
    }

    private func buildExitRamp(side: ExitSide, isEmergency: Bool) {
        exitNode.removeAllChildren()
        exitNode.alpha = 1
        exitCountdownLabel = nil
        exitGuidanceNode.removeFromParent()
        exitGuidanceNode.removeAllChildren()
        exitGuidanceNode.zPosition = 14
        exitNode.addChild(exitGuidanceNode)
        exitGuidanceRefreshTimer = 0
        let palette = palette(for: currentCity)
        let exitLanes = laneManager.exitLanes(for: side)
        let rampWidth = laneWidth * 2.35
        let rampCenterX = side == .left ? laneCenters[0] + laneWidth * 0.5 : laneCenters[laneCount - 1] - laneWidth * 0.5
        let rampColor = isEmergency ? UITheme.Color.orange : palette.accent

        let laneGlow = SKShapeNode(rectOf: CGSize(width: rampWidth, height: size.height + 160), cornerRadius: 10)
        laneGlow.position = CGPoint(x: rampCenterX, y: size.height / 2)
        laneGlow.fillColor = rampColor.withAlphaComponent(0.12)
        laneGlow.strokeColor = rampColor.withAlphaComponent(0.82)
        laneGlow.lineWidth = 2
        laneGlow.glowWidth = 10
        exitNode.addChild(laneGlow)

        let rampPath = CGMutablePath()
        let edgeX = side == .left ? roadLeft + laneWidth * 2 : roadLeft + roadWidth - laneWidth * 2
        let outsideX = side == .left ? roadLeft - laneWidth * 1.3 : roadLeft + roadWidth + laneWidth * 1.3
        rampPath.move(to: CGPoint(x: edgeX, y: playerY - 72))
        rampPath.addLine(to: CGPoint(x: outsideX, y: playerY + 56))
        rampPath.addLine(to: CGPoint(x: outsideX, y: size.height + 80))
        rampPath.addLine(to: CGPoint(x: edgeX, y: size.height + 80))
        rampPath.closeSubpath()

        let ramp = SKShapeNode(path: rampPath)
        ramp.fillColor = palette.road.withAlphaComponent(0.92)
        ramp.strokeColor = rampColor.withAlphaComponent(0.9)
        ramp.lineWidth = 3
        ramp.glowWidth = 8
        exitNode.addChild(ramp)

        let sign = SKShapeNode(rectOf: CGSize(width: min(size.width * 0.46, 180), height: 48), cornerRadius: 7)
        sign.position = CGPoint(x: side == .left ? size.width * 0.28 : size.width * 0.72, y: size.height * 0.72)
        sign.fillColor = currentWorld.exitSignFill(isEmergency: isEmergency)
        sign.strokeColor = palette.laneMarker.withAlphaComponent(0.78)
        sign.lineWidth = 2
        sign.glowWidth = 5
        exitNode.addChild(sign)

        let signText = UIHelpers.label(currentWorld.exitSignText(side: side, isEmergency: isEmergency), size: 20, color: .white, width: sign.frame.width - 18)
        signText.position = .zero
        sign.addChild(signText)

        for (index, lane) in exitLanes.enumerated() {
            let arrow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            arrow.text = side == .left ? "<" : ">"
            arrow.fontSize = 34
            arrow.fontColor = rampColor
            arrow.horizontalAlignmentMode = .center
            arrow.verticalAlignmentMode = .center
            arrow.position = CGPoint(x: laneCenters[lane], y: playerY + 128 + CGFloat(index) * 50)
            arrow.zPosition = 10
            exitNode.addChild(arrow)
            arrow.run(.repeatForever(.sequence([
                .scale(to: 1.28, duration: 0.16),
                .scale(to: 1, duration: 0.16)
            ])))
        }

        let countdown = UIHelpers.label("", size: 26, color: rampColor, width: size.width - 36)
        countdown.position = CGPoint(x: size.width / 2, y: size.height * 0.63)
        countdown.zPosition = 12
        exitCountdownLabel = countdown
        exitNode.addChild(countdown)
        updateExitCountdownLabel()
        rebuildExitGuidance(side: side)
    }

    private func updateExitCountdownLabel() {
        guard let activeExitSide, let exitCountdownLabel else { return }
        exitCountdownLabel.text = "EXIT \(activeExitSide.displayName)  \(String(format: "%.1f", exitCountdown))"
        updateExitHUDLabel()
    }

    private func updateExitGuidance(deltaTime: TimeInterval) {
        guard exitPhase == .active, let activeExitSide else { return }
        exitGuidanceRefreshTimer = max(0, exitGuidanceRefreshTimer - deltaTime)
        guard exitGuidanceRefreshTimer == 0 else { return }
        exitGuidanceRefreshTimer = 0.16
        rebuildExitGuidance(side: activeExitSide)
    }

    private func rebuildExitGuidance(side: ExitSide) {
        exitGuidanceNode.removeAllChildren()

        let validSlots = Set(laneManager.validSlots(for: activeCar.vehicleClass))
        var safeSlots = validSlots
        if let latestTrafficPlan {
            safeSlots = activeCar.vehicleClass == .motorcycle ? latestTrafficPlan.safeMotorcycleSlots : latestTrafficPlan.safeCarSlots
            safeSlots = safeSlots.intersection(validSlots)
        }

        let exitSlots = laneManager.exitSlots(for: side, vehicleClass: activeCar.vehicleClass)
        safeSlots.formUnion(exitSlots)

        let direction = side == .left ? -1 : 1
        let pathSlots = safeSlots
            .filter { direction < 0 ? $0 < playerSlot : $0 > playerSlot }
            .sorted { lhs, rhs in
                let lhsExit = exitSlots.map { abs($0 - lhs) }.min() ?? 0
                let rhsExit = exitSlots.map { abs($0 - rhs) }.min() ?? 0
                let lhsScore = abs(lhs - playerSlot) + lhsExit
                let rhsScore = abs(rhs - playerSlot) + rhsExit
                return lhsScore < rhsScore
            }

        let visibleSlots = Array(pathSlots.prefix(5))
        guard !visibleSlots.isEmpty else { return }

        let color = exitIsEmergency ? UITheme.Color.orange : UITheme.Color.green
        for (index, slot) in visibleSlots.enumerated() where slotCenters.indices.contains(slot) {
            let chevron = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            chevron.text = side == .left ? "<" : ">"
            chevron.fontSize = 22
            chevron.fontColor = color.withAlphaComponent(0.9 - CGFloat(index) * 0.08)
            chevron.horizontalAlignmentMode = .center
            chevron.verticalAlignmentMode = .center
            chevron.position = CGPoint(
                x: slotCenters[slot],
                y: playerY + 62 + CGFloat(index) * 40
            )
            chevron.zPosition = 1
            exitGuidanceNode.addChild(chevron)
            chevron.run(.repeatForever(.sequence([
                .scale(to: 1.18, duration: 0.12),
                .scale(to: 0.96, duration: 0.16)
            ])))

            let glow = SKShapeNode(circleOfRadius: max(5, laneWidth * 0.16))
            glow.position = chevron.position
            glow.fillColor = color.withAlphaComponent(0.22)
            glow.strokeColor = .clear
            glow.glowWidth = 8
            glow.zPosition = 0
            exitGuidanceNode.addChild(glow)
        }
    }

    private func clearExitApproach(side: ExitSide) {
        let protectedLanes = laneManager.exitGuardLanes(for: side)
        let safetyGap = currentLevel.map { LevelDifficultyConfig.snapshot(for: $0, elapsed: runTime, exitActive: true).exitSafetyGap } ?? 360
        for node in trafficNode.children {
            guard let vehicle = node as? SKSpriteNode,
                  let lane = vehicle.userData?["lane"] as? Int else { continue }
            let span = vehicle.userData?["laneSpan"] as? Int ?? 1
            let occupied = occupiedLanes(for: lane, span: span)
            if !protectedLanes.isDisjoint(with: occupied), vehicle.position.y < playerY + safetyGap {
                vehicle.removeFromParent()
            }
        }
    }

    private func playerReachedExitRamp() -> Bool {
        guard runTime - exitActivatedAt > 0.18, let activeExitSide else { return false }
        return laneManager.exitSlots(for: activeExitSide, vehicleClass: activeCar.vehicleClass).contains(playerSlot)
    }

    private func missExit() {
        guard exitPhase == .active else { return }
        exitPhase = .missed
        exitNode.removeAllChildren()
        buddy.say(.missedExit, force: true)
        wantedLevel = min(6, wantedLevel + 1)
        highestWantedLevel = max(highestWantedLevel, wantedLevel)
        policeGap = max(minPoliceGap, policeGap - 42)
        policeClosingSpeed += 1.4
        rebuildPoliceSupport()
        updateHUD()
        recordTelemetry(event: "exit_missed", terminalReason: "missed_exit", levelCompleted: false)
        AudioManager.shared.play(.wantedIncrease, volume: 0.95, cooldown: 0.2)

        if let currentLevel, currentLevel.allowsEmergencyExit, !emergencyExitUsed {
            emergencyExitUsed = true
            emergencyExitTimer = 4.2
            buddy.say(.exitCountdown, detail: "Second chance. Watch the other side!", force: true)
            return
        }

        endGame(crashPoint: playerCar?.position, reason: "missed_exit")
    }

    private func completeLevelEscape() {
        guard exitPhase == .active else { return }
        exitPhase = .completed
        gameState = .gameOver
        activeHoldDirection = 0
        playerCar?.removeAllActions()
        warningPulseNode.removeAllActions()
        warningPulseNode.alpha = 0
        warningPulseActive = false
        AudioManager.shared.quietDangerLayers()
        AudioManager.shared.play(.powerUp, volume: 0.95, cooldown: 0.1)
        buddy.say(.levelComplete, force: true)
        if AudioManager.shared.isHapticsEnabled {
            crashHaptic.notificationOccurred(.success)
            crashHaptic.prepare()
        }

        let exitText = currentLevel.map { "LEVEL \(LevelCatalog.displayNumber(for: $0.levelID)) COMPLETE" } ?? "ESCAPED"
        triggerEventCinematic(title: exitText, color: UITheme.Color.green)
        showAwardPopup(
            title: "ESCAPED",
            subtitle: "+$\(currentLevel?.rewardCash ?? 0)  +\(currentLevel?.rewardXP ?? 0) XP",
            at: CGPoint(x: laneCenters[playerLane], y: playerY + 96),
            color: UITheme.Color.green,
            scale: 1.1
        )
        exitNode.run(.sequence([
            .fadeOut(withDuration: 0.35),
            .run { [weak self] in
                self?.exitNode.removeAllChildren()
                self?.exitNode.alpha = 1
            }
        ]))

        recordTelemetry(event: "run_ended", terminalReason: "escaped", levelCompleted: true)
        RunTelemetryRecorder.shared.close()
        let result = ProgressionManager.shared.processRun(makeRunStats(crashes: 0, levelCompleted: true, failureReason: nil))
        run(.sequence([
            .wait(forDuration: 0.9),
            .run { [weak self] in
                guard let self else { return }
                UIHelpers.present(ResultsScene(size: self.size, result: result), from: self)
            }
        ]))
    }

    // MARK: - Road Scrolling

    private func scrollRoad(deltaTime: CGFloat) {
        let markerStep = roadSpeed * deltaTime

        for marker in markerNode.children {
            let speedFactor = marker.userData?["speedFactor"] as? CGFloat ?? 1
            marker.position.y -= markerStep * speedFactor
            if marker.position.y < -80 {
                marker.position.y += markerRecycleSpan
            }
        }

        let sceneryStep = roadSpeed * 0.7 * deltaTime

        for decoration in sceneryNode.children {
            decoration.position.y -= sceneryStep
            if decoration.position.y < -90 {
                decoration.position.y += sceneryRecycleSpan
            }
        }
    }

    private func updateSpeedLines(deltaTime: CGFloat) {
        let comboBoost = max(0, min(1, CGFloat(comboCount) / 10))
        for node in speedLineNode.children {
            let speedFactor = node.userData?["speedFactor"] as? CGFloat ?? 1.4
            node.position.y -= roadSpeed * (speedFactor + comboBoost * 0.28) * deltaTime

            if node.position.y < -100 {
                node.position.y = size.height + CGFloat.random(in: 60...220)
                node.position.x = CGFloat.random(in: (roadLeft + 14)...(roadLeft + roadWidth - 14))
                node.alpha = CGFloat.random(in: 0.08...(0.22 + comboBoost * 0.22))
            }
        }
    }

    // MARK: - Traffic

    private func updateSpawning(deltaTime: TimeInterval) {
        spawnTimer += deltaTime

        if spawnTimer >= spawnInterval {
            spawnTimer = 0
            spawnTrafficWave()
        }
    }

    private func spawnTrafficWave() {
        var protectedLanes = reservedEscapeLanes()
        if exitPhase == .active, let side = activeExitSide {
            protectedLanes.formUnion(laneManager.exitGuardLanes(for: side))
        }
        var protectedSlots = Set(protectedLanes.map { $0 * 2 })
        if exitPhase == .active, let side = activeExitSide {
            protectedSlots.formUnion(laneManager.exitSlots(for: side, vehicleClass: activeCar.vehicleClass))
        }

        let context = TrafficPatternContext(
            laneCount: laneCount,
            playerLane: playerLane,
            playerSlot: playerSlot,
            vehicleClass: activeCar.vehicleClass,
            density: currentTrafficDensity(),
            wantedLevel: wantedLevel,
            city: currentCity,
            worldThemeID: currentWorld.id,
            protectedLanes: protectedLanes,
            protectedSlots: protectedSlots,
            recentBlockedLanes: recentBlockedLanes(),
            recentHazards: recentTrafficHazards(),
            exitActive: exitPhase == .active,
            exitSide: activeExitSide,
            dodgeBoostActive: dodgeBoostTimer > 0
        )

        guard let plan = TrafficPatternGenerator.generate(context: context, rng: &trafficPlanRNG) else {
            if AppConfig.printRejectedTrafficWaves {
                print("[TrafficPattern] all retries rejected density=\(context.density) wanted=\(wantedLevel)")
            }
            return
        }

        latestTrafficPlan = plan
        recordTelemetry(event: "traffic_wave", plan: plan)
        if plan.occupiedLanes.count >= 7 {
            buddy.say(.trafficWarning, force: false)
        }

        for spawn in plan.spawns {
            spawnVehicle(in: spawn.lane, type: spawn.type, yOffset: spawn.yOffset, speedMultiplier: spawn.speedMultiplier)
        }

        showTrafficDebug(plan)
    }

    private func reservedEscapeLanes() -> Set<Int> {
        var candidates: [Int] = []
        let nearPlayer = [playerLane - 1, playerLane, playerLane + 1].map(laneManager.clampedLane)
        candidates.append(contentsOf: nearPlayer)

        let randomStart = trafficPlanRNG.int(in: 0...(laneCount - 2))
        candidates.append(randomStart)
        candidates.append(randomStart + 1)

        return Set(candidates.prefix(currentTrafficDensity() < 0.82 ? 3 : 2))
    }

    private func recentBlockedLanes() -> Set<Int> {
        var lanes: Set<Int> = []
        for lane in 0..<laneCount where laneHasRecentVehicle(lane) {
            lanes.insert(lane)
        }
        return lanes
    }

    private func recentTrafficHazards() -> [TrafficHazardSnapshot] {
        trafficNode.children.compactMap { node in
            guard let vehicle = node as? SKSpriteNode,
                  let lane = vehicle.userData?["lane"] as? Int else {
                return nil
            }

            guard vehicle.position.y > size.height - 360 else {
                return nil
            }

            let typeName = vehicle.userData?["type"] as? String
            let type = typeName.flatMap(VehicleType.init(rawValue:)) ?? .sedan
            let span = vehicle.userData?["laneSpan"] as? Int ?? laneSpan(for: type)
            let isRoadblock = vehicle.userData?["roadblock"] as? Bool == true

            return TrafficHazardSnapshot(
                lane: lane,
                laneSpan: span,
                type: type,
                y: vehicle.position.y,
                height: vehicle.size.height,
                isRoadblock: isRoadblock
            )
        }
    }

    private func showTrafficDebug(_ plan: TrafficWavePlan) {
        guard AppConfig.showTrafficSpawnHeatmap || AppConfig.showOpenLaneAnalysis else { return }

        let node = SKNode()
        node.zPosition = 128
        floatingTextNode.addChild(node)

        for lane in 0..<laneCount {
            let laneColor: SKColor
            if plan.occupiedLanes.contains(lane) {
                laneColor = SKColor.red
            } else if plan.openLanes.contains(lane) {
                laneColor = UITheme.Color.green
            } else {
                laneColor = SKColor.yellow
            }
            let marker = SKShapeNode(rectOf: CGSize(width: max(5, laneWidth * 0.32), height: 12), cornerRadius: 2)
            marker.position = CGPoint(x: laneCenters[lane], y: size.height * 0.58)
            marker.fillColor = laneColor.withAlphaComponent(AppConfig.showTrafficSpawnHeatmap ? 0.55 : 0.24)
            marker.strokeColor = .clear
            node.addChild(marker)
        }

        if AppConfig.showOpenLaneAnalysis {
            let label = UIHelpers.bodyLabel("\(plan.patternName)  open \(plan.openLanes.sorted())  car \(plan.safeCarSlots.sorted())  moto \(plan.safeMotorcycleSlots.sorted())", size: 10, color: .white, width: size.width - 24)
            label.position = CGPoint(x: size.width / 2, y: size.height * 0.61)
            node.addChild(label)
        }

        node.run(.sequence([.wait(forDuration: 0.55), .fadeOut(withDuration: 0.18), .removeFromParent()]))
    }

    private func laneHasRecentVehicle(_ lane: Int) -> Bool {
        for node in trafficNode.children {
            guard let vehicle = node as? SKSpriteNode,
                  let vehicleLane = vehicle.userData?["lane"] as? Int else {
                continue
            }

            let span = vehicle.userData?["laneSpan"] as? Int ?? 1
            if occupiedLanes(for: vehicleLane, span: span).contains(lane), vehicle.position.y > size.height - 220 {
                return true
            }
        }

        return false
    }

    private func spawnVehicle(in lane: Int) {
        spawnVehicle(in: lane, type: randomVehicleType())
    }

    private func spawnVehicle(in lane: Int, type: VehicleType, yOffset: CGFloat = 0, speedMultiplier: CGFloat = 1) {
        trafficSpawnSerial += 1
        let vehicle = makeTrafficVehicle(type: type)
        vehicle.position = CGPoint(x: laneCenters[lane], y: size.height + vehicle.size.height / 2 + trafficSpawnRNG.cgFloat(in: 0...34) + yOffset)
        vehicle.name = "traffic"
        vehicle.userData = [
            "spawnID": trafficSpawnSerial,
            "assetID": ArcadeArt.assetID(for: type).rawValue,
            "lane": lane,
            "laneSpan": laneSpan(for: type),
            "speed": randomTrafficSpeed(for: type) * speedMultiplier,
            "type": type.rawValue,
            "spawnTime": runTime,
            "nearMissAwarded": false
        ]
        trafficNode.addChild(vehicle)
    }

    private func laneSpan(for type: VehicleType) -> Int {
        ArcadeArt.laneSpan(for: type)
    }

    private func occupiedLanes(for centerLane: Int, span: Int) -> Set<Int> {
        guard span > 1 else { return [laneManager.clampedLane(centerLane)] }
        let sideLane = centerLane < laneCount - 1 ? centerLane + 1 : centerLane - 1
        return [laneManager.clampedLane(centerLane), laneManager.clampedLane(sideLane)]
    }

    private func currentTrafficDensity() -> CGFloat {
        let bikeDensityBonus: CGFloat = activeCar.vehicleClass == .motorcycle ? 0.06 : 0
        if let currentLevel {
            return min(0.94, LevelDifficultyConfig.snapshot(for: currentLevel, elapsed: runTime, exitActive: exitPhase == .active).trafficDensity + bikeDensityBonus)
        }

        let speedProgress = max(0, min(1, (roadSpeed - 330) / 230))
        return max(0.3, min(0.92, 0.32 + speedProgress * 0.42 + CGFloat(wantedLevel - 1) * 0.035 + bikeDensityBonus))
    }

    private func updateTraffic(deltaTime: CGFloat) {
        for node in trafficNode.children {
            guard let vehicle = node as? SKSpriteNode else { continue }
            let speed = vehicle.userData?["speed"] as? CGFloat ?? trafficSpeed
            vehicle.position.y -= speed * deltaTime

            if vehicle.position.y < -vehicle.size.height {
                vehicle.removeFromParent()
            } else {
                checkNearMiss(for: vehicle)
            }
        }
        checkLaneSplitOpportunities()
    }

    private func randomVehicleType() -> VehicleType {
        trafficSpawnRNG.element(from: currentWorld.trafficPool(wantedLevel: wantedLevel)) ?? .sedan
    }

    private func randomTrafficSpeed(for type: VehicleType) -> CGFloat {
        var speed = trafficSpeed + trafficSpawnRNG.cgFloat(in: -22...28)

        speed += ArcadeArt.speedOffset(for: type)

        speed += currentWorld.trafficSpeedOffset

        return speed
    }

    // MARK: - Police Pressure

    private func positionPolice(deltaTime: CGFloat) {
        guard let policeCar, let playerCar else { return }

        let resistance = max(0.92, min(1.18, activeCar.policeResistance))
        let worldPressure = max(0.92, min(1.12, currentWorld.policePressureMultiplier))
        let passiveMultiplier = 1 + passivePolicePressure * 1.42
        policeGap = max(minPoliceGap, policeGap - (policeClosingSpeed * worldPressure * passiveMultiplier / resistance) * deltaTime)

        let targetX = slotCenters.indices.contains(playerSlot) ? slotCenters[playerSlot] : playerCar.position.x
        let followAmount = min(1, deltaTime * 5.4)
        policeCar.position.x += (targetX - policeCar.position.x) * followAmount
        let logicalY = playerY - policeGap
        let bottomInset = max(view?.safeAreaInsets.bottom ?? 0, 12)
        let minimumVisibleY = bottomInset + policeCar.size.height * 0.55 + 12
        let displayY = max(logicalY, minimumVisibleY)
        let pressureRange = max(1, maxPoliceGap - minPoliceGap)
        let pressure = max(0, min(1, (maxPoliceGap - policeGap) / pressureRange))
        let isBottomClamped = displayY > logicalY + 1
        policeCar.position.y = displayY
        policeCar.alpha = isBottomClamped ? 0.46 + pressure * 0.34 : 1
        policeCar.setScale(isBottomClamped ? 0.78 + pressure * 0.14 : 1)

        let logicalPoliceMaxY = logicalY + policeCar.size.height * policeCar.xScale / 2
        if logicalPoliceMaxY >= playerCar.frame.minY {
            endGame(crashPoint: playerCar.position, reason: "police_caught")
        }
    }

    private func pushPoliceBack() {
        policeGap = min(maxPoliceGap, policeGap + 18)
    }

    private var passivePolicePressure: CGFloat {
        guard runTime >= 2 else { return 0 }
        let passiveSeconds = max(0, timeSinceLastLaneChange - 2.0)
        return max(0, min(1, CGFloat(passiveSeconds / 4.0)))
    }

    private func easePassivePolicePressureAfterLaneChange(idleTime: TimeInterval, laneDelta: Int) {
        guard idleTime >= 1.6 else { return }
        let laneDistance = CGFloat(max(1, abs(laneDelta)))
        let relief = min(10, 3 + laneDistance * 1.4)
        policeGap = min(maxPoliceGap, policeGap + relief)
    }

    private func updatePoliceWarning() {
        let warningGap = minPoliceGap + 48
        let gapPressure = max(0, min(1, (warningGap - policeGap) / max(1, warningGap - minPoliceGap)))
        let pressure = max(gapPressure, passivePolicePressure * 0.78)
        let shouldPulse = (policeGap <= warningGap || passivePolicePressure >= 0.72) && gameState == .playing

        if shouldPulse && !warningPulseActive {
            warningPulseActive = true
            let reduced = SaveManager.shared.data.reducedFlashingEnabled
            let fadeIn = SKAction.fadeAlpha(to: reduced ? 0.38 : 1, duration: reduced ? 0.26 : 0.16)
            let fadeOut = SKAction.fadeAlpha(to: reduced ? 0.12 : 0.22, duration: reduced ? 0.34 : 0.22)
            warningPulseNode.run(.repeatForever(.sequence([fadeIn, fadeOut])), withKey: "warningPulse")
        } else if !shouldPulse && warningPulseActive {
            warningPulseActive = false
            warningPulseNode.removeAction(forKey: "warningPulse")
            warningPulseNode.run(.fadeOut(withDuration: 0.18))
        }

        guard shouldPulse, warningHapticCooldown == 0, AudioManager.shared.isHapticsEnabled else { return }
        warningHaptic.impactOccurred(intensity: 0.35 + pressure * 0.45)
        warningHaptic.prepare()
        warningHapticCooldown = 1.1
    }

    private func updatePassivePolicePressureCues() {
        let pressure = passivePolicePressure
        guard pressure >= 0.45 else {
            if timeSinceLastLaneChange < 1.2 {
                passivePressureAlertShown = false
            }
            return
        }

        guard !passivePressureAlertShown || passivePressureWarningCooldown == 0 else { return }
        showPassivePoliceAlert(urgent: pressure >= 0.82)
        passivePressureAlertShown = true
        passivePressureWarningCooldown = pressure >= 0.82 ? 2.1 : 3.2
    }

    private func showPassivePoliceAlert(urgent: Bool) {
        let palette = palette(for: currentCity)
        let width = min(size.width - 40, urgent ? 292 : 268)
        let banner = SKShapeNode(rectOf: CGSize(width: width, height: 34), cornerRadius: 8)
        banner.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        banner.fillColor = SKColor.black.withAlphaComponent(0.72)
        banner.strokeColor = SKColor.red.withAlphaComponent(urgent ? 0.92 : 0.68)
        banner.lineWidth = urgent ? 2.2 : 1.6
        banner.glowWidth = urgent ? 8 : 4
        banner.zPosition = 150
        floatingTextNode.addChild(banner)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = urgent ? "CHANGE LANES NOW" : "MOVE - POLICE CLOSING"
        label.fontSize = urgent ? 19 : 17
        label.fontColor = urgent ? UITheme.Color.gold : palette.accent
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = .zero
        fitLabel(label, maxWidth: width - 20)
        banner.addChild(label)

        let pop = SKAction.sequence([.scale(to: 1.06, duration: 0.08), .scale(to: 1, duration: 0.1)])
        let hold = SKAction.wait(forDuration: urgent ? 0.72 : 0.56)
        banner.run(.sequence([pop, hold, .fadeOut(withDuration: 0.18), .removeFromParent()]))
    }

    private func updateDynamicAudioAndAtmosphere() {
        guard gameState == .playing else {
            AudioManager.shared.quietDangerLayers()
            AtmosphereManager.shared.setDangerPulse(0)
            return
        }

        let pressureRange = max(1, maxPoliceGap - minPoliceGap)
        let pressure = max(0, min(1, (maxPoliceGap - policeGap) / pressureRange))
        let wantedPressure = min(1, max(pressure, passivePolicePressure * 0.65) + CGFloat(wantedLevel - 1) * 0.08)
        AudioManager.shared.setPoliceIntensity(wantedPressure)
        AudioManager.shared.setDangerIntensity(wantedPressure)
        AtmosphereManager.shared.setDangerPulse(wantedPressure)
    }

    // MARK: - Wanted Escalation

    private func updateWantedLevel() {
        guard AppConfig.forcedWantedLevel == 0 else { return }
        let computedLevel: Int
        if let currentLevel {
            let totalDuration = max(1, currentLevel.durationBeforeExit + currentLevel.exitWindowSeconds)
            let progress = max(0, min(1, runTime / totalDuration))
            computedLevel = min(6, 1 + Int(progress * Double(4.4 * currentLevel.policeAggression)))
        } else {
            computedLevel = min(6, 1 + Int(runTime / 24))
        }
        let passiveWantedLevel: Int
        if timeSinceLastLaneChange >= 5.5 {
            passiveWantedLevel = 3
        } else if timeSinceLastLaneChange >= 3.5 {
            passiveWantedLevel = 2
        } else {
            passiveWantedLevel = 1
        }
        let newLevel = max(wantedLevel, computedLevel, passiveWantedLevel)
        guard newLevel != wantedLevel else { return }

        wantedLevel = newLevel
        highestWantedLevel = max(highestWantedLevel, wantedLevel)
        if wantedLevel > lastPoliceBuddyLevel {
            buddy.say(.policeWarning, force: false)
            lastPoliceBuddyLevel = wantedLevel
        }
        updateHUD()
        showWantedAlert(level: wantedLevel)
        rebuildPoliceSupport()

        if wantedLevel >= 5 {
            ensureHelicopter()
        }

        AudioManager.shared.play(.wantedIncrease, volume: 0.92, cooldown: 0.5)
        if AudioManager.shared.isHapticsEnabled {
            warningHaptic.impactOccurred(intensity: min(1, 0.45 + CGFloat(wantedLevel) * 0.08))
            warningHaptic.prepare()
        }
    }

    private func applyDebugOverrides() {
        guard AppConfig.debugMode else { return }

        let forcedWanted = AppConfig.forcedWantedLevel
        if forcedWanted > 0, forcedWanted != wantedLevel {
            wantedLevel = forcedWanted
            highestWantedLevel = max(highestWantedLevel, wantedLevel)
            wantedVisualLevel = wantedLevel
            updateHUD()
            rebuildPoliceSupport()
            if wantedLevel >= 5 {
                ensureHelicopter()
            }
        }

        let forcedCity: CityTheme?
        switch AppConfig.forcedCity {
        case .automatic:
            forcedCity = nil
        case .newYork:
            forcedCity = .newYork
        case .losAngeles:
            forcedCity = .losAngeles
        case .miami:
            forcedCity = .miami
        }

        if let forcedCity {
            let forcedWorld = WorldThemeCatalog.legacyTheme(for: forcedCity)
            guard forcedCity != currentCity || forcedWorld.id != currentWorld.id else { return }
            currentCity = forcedCity
            currentWorld = forcedWorld
            setupRoad()
            AudioManager.shared.updateTheme(forcedCity.audioTheme)
            updateHUD()
            showCityBanner(currentWorld.displayName.uppercased())
        }
    }

    private func applyScreenshotMode() {
        guard AppConfig.debugMode else { return }
        let mode = ScreenshotMode.shared.state
        guard mode.enabled else { return }

        if mode.hideHUD {
            setHUDVisible(false)
        }

        if mode.forcedCombo > 0, comboCount < mode.forcedCombo {
            comboCount = mode.forcedCombo
            highestCombo = max(highestCombo, comboCount)
            comboTimer = comboDuration
            updateHUD()
        }

        switch mode.weather {
        case .automatic:
            break
        case .clear:
            AtmosphereManager.shared.setWeather(.clear)
        case .rain:
            AtmosphereManager.shared.setWeather(.rain)
        case .heavyRain:
            AtmosphereManager.shared.setWeather(.heavyRain)
        case .fog:
            AtmosphereManager.shared.setWeather(.fog)
        case .nightStorm:
            AtmosphereManager.shared.setWeather(.nightStorm)
        }

        if mode.showcaseTraffic, !screenshotShowcaseSpawned, laneCenters.count == laneCount {
            screenshotShowcaseSpawned = true
            for lane in 0..<laneCount where lane != playerLane {
                let type: VehicleType = lane.isMultiple(of: 3) ? .boxTruck : (lane.isMultiple(of: 2) ? .compact : .sportCoupe)
                spawnVehicle(in: lane, type: type, yOffset: CGFloat(lane) * 58, speedMultiplier: 0.82)
            }
            if wantedLevel < 5 {
                wantedLevel = max(wantedLevel, 4)
                highestWantedLevel = max(highestWantedLevel, wantedLevel)
                rebuildPoliceSupport()
                updateHUD()
            }
        }
    }

    private func showWantedAlert(level: Int) {
        let palette = palette(for: currentCity)
        let banner = SKShapeNode(rectOf: CGSize(width: min(size.width - 36, 330), height: 42), cornerRadius: 8)
        banner.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        banner.fillColor = SKColor.black.withAlphaComponent(0.72)
        banner.strokeColor = SKColor.red.withAlphaComponent(0.9)
        banner.lineWidth = 2
        banner.glowWidth = 7
        floatingTextNode.addChild(banner)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = level >= 6 ? "ELITE PURSUIT" : "WANTED LEVEL \(level)"
        label.fontSize = 22
        label.fontColor = palette.accent
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = .zero
        banner.addChild(label)

        banner.setScale(0.86)
        let pulse = SKAction.sequence([.scale(to: 1.05, duration: 0.08), .scale(to: 1, duration: 0.12)])
        let hold = SKAction.wait(forDuration: 0.65)
        let fade = SKAction.fadeOut(withDuration: 0.24)
        banner.run(.sequence([pulse, hold, fade, .removeFromParent()]))
    }

    private func rebuildPoliceSupport() {
        policeSupportNode.removeAllChildren()
        guard wantedLevel >= 2 else { return }

        let supportCount = min(3, wantedLevel - 1)
        for index in 0..<supportCount {
            let car = wantedLevel >= 4 && index == supportCount - 1 ? makePoliceSUV() : makePoliceCar()
            car.name = "policeSupport"
            car.setScale(index == 0 ? 0.84 : 0.78)
            car.userData = ["offset": index]
            policeSupportNode.addChild(car)
        }
    }

    private func updatePoliceSupport(deltaTime: CGFloat) {
        guard gameState == .playing else { return }

        let laneOffsets = [-1, 1, 0]
        for (index, node) in policeSupportNode.children.enumerated() {
            guard let car = node as? SKSpriteNode else { continue }
            let lane = max(0, min(laneCount - 1, playerLane + laneOffsets[index % laneOffsets.count]))
            let targetX = laneCenters.indices.contains(lane) ? laneCenters[lane] : size.width / 2
            let targetY = playerY - policeGap - CGFloat(82 + index * 48)
            car.position.x += (targetX - car.position.x) * min(1, deltaTime * 3.6)
            car.position.y += (targetY - car.position.y) * min(1, deltaTime * 4.8)
            car.alpha = targetY > -80 ? 0.95 : 0.45
        }
    }

    private func makePoliceSUV() -> SKSpriteNode {
        ArcadeArt.makeVehicleSprite(
            spec: ArcadeArt.policeSUVSpec(laneWidth: laneWidth, world: currentWorld),
            reducedFlashing: SaveManager.shared.data.reducedFlashingEnabled
        )
    }

    private func ensureHelicopter() {
        guard helicopterNode == nil else { return }

        let helicopter = SKNode()
        helicopter.zPosition = 82
        helicopter.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        floatingTextNode.addChild(helicopter)

        let shadow = SKShapeNode(ellipseOf: CGSize(width: 72, height: 24))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.24)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 10, y: -68)
        shadow.name = "heliShadow"
        helicopter.addChild(shadow)

        let spotlightPath = CGMutablePath()
        spotlightPath.move(to: CGPoint(x: 0, y: -16))
        spotlightPath.addLine(to: CGPoint(x: -48, y: -245))
        spotlightPath.addLine(to: CGPoint(x: 48, y: -245))
        spotlightPath.closeSubpath()
        let spotlight = SKShapeNode(path: spotlightPath)
        spotlight.name = "heliSpotlight"
        spotlight.fillColor = SKColor.white.withAlphaComponent(0.12)
        spotlight.strokeColor = SKColor.white.withAlphaComponent(0.18)
        spotlight.lineWidth = 1
        spotlight.glowWidth = 12
        helicopter.addChild(spotlight)

        let body = SKShapeNode(ellipseOf: CGSize(width: 58, height: 30))
        body.fillColor = SKColor(white: 0.08, alpha: 1)
        body.strokeColor = SKColor.white.withAlphaComponent(0.45)
        body.lineWidth = 1.5
        body.name = "heliBody"
        helicopter.addChild(body)

        let nose = SKShapeNode(ellipseOf: CGSize(width: 20, height: 16))
        nose.fillColor = SKColor(red: 0.1, green: 0.4, blue: 0.95, alpha: 1)
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 0, y: 17)
        helicopter.addChild(nose)

        let rotor = SKShapeNode(rectOf: CGSize(width: 92, height: 5), cornerRadius: 2)
        rotor.fillColor = SKColor.white.withAlphaComponent(0.82)
        rotor.strokeColor = .clear
        rotor.name = "heliRotor"
        helicopter.addChild(rotor)

        helicopterNode = helicopter
        AudioManager.shared.play(.helicopter, volume: 0.65, cooldown: 0.2)
    }

    private func updateHelicopter(deltaTime: TimeInterval) {
        guard wantedLevel >= 5, let helicopterNode else { return }

        helicopterAngle += CGFloat(deltaTime) * 0.82
        let targetX = size.width / 2 + sin(helicopterAngle) * roadWidth * 0.34
        let targetY = size.height * 0.77 + cos(helicopterAngle * 0.6) * 18
        helicopterNode.position.x += (targetX - helicopterNode.position.x) * 0.08
        helicopterNode.position.y += (targetY - helicopterNode.position.y) * 0.08

        if let rotor = helicopterNode.childNode(withName: "heliRotor") {
            rotor.zRotation += CGFloat(deltaTime) * 28
        }

        if let spotlight = helicopterNode.childNode(withName: "heliSpotlight") {
            spotlight.zRotation = sin(helicopterAngle * 1.2) * 0.28
            spotlight.alpha = 0.72 + sin(helicopterAngle * 2.1) * 0.16
        }

        helicopterAudioTimer -= deltaTime
        if helicopterAudioTimer <= 0 {
            helicopterAudioTimer = 0.48
            AudioManager.shared.play(.helicopter, volume: 0.32 + Float(wantedLevel) * 0.035, cooldown: 0.28)
        }
    }

    // MARK: - Roadblocks and Special Events

    private func updateRoadblocks() {
        guard wantedLevel >= 3, roadblockCooldown == 0 else { return }
        spawnRoadblock()
        if let currentLevel {
            roadblockCooldown = LevelDifficultyConfig.snapshot(for: currentLevel, elapsed: runTime, exitActive: exitPhase == .active).roadblockCooldown
        } else {
            roadblockCooldown = max(5.5, 13.5 - Double(wantedLevel) * 1.25)
        }
    }

    private func spawnRoadblock() {
        let safeLane = safestRoadblockLane()
        let protectedLanes = protectedExitLanes()
        var lanes = Array(0..<laneCount).filter { $0 != safeLane && !protectedLanes.contains($0) }
        lanes = trafficEventRNG.shuffled(lanes)

        let blockedCount = min(lanes.count, wantedLevel >= 6 ? 4 : (wantedLevel >= 5 ? 3 : 2))
        let blockedLanes = Array(lanes.prefix(blockedCount))
        guard !blockedLanes.isEmpty else { return }
        buddy.say(.roadblockWarning, force: false)
        showRoadblockWarning(lanes: blockedLanes)
        triggerEventCinematic(title: "ROADBLOCK", color: SKColor.red)

        for (index, lane) in blockedLanes.enumerated() {
            trafficSpawnSerial += 1
            let block = makeRoadblockNode()
            block.name = "roadblock"
            block.position = CGPoint(
                x: laneCenters[lane],
                y: size.height + block.size.height / 2 + CGFloat(index) * 16 + 96
            )
            block.userData = [
                "spawnID": trafficSpawnSerial,
                "lane": lane,
                "laneSpan": 1,
                "speed": roadSpeed,
                "type": "roadblock",
                "spawnTime": runTime,
                "nearMissAwarded": false,
                "roadblock": true
            ]
            trafficNode.addChild(block)
        }
    }

    private func safestRoadblockLane() -> Int {
        let protectedLanes = protectedExitLanes()
        let clearLanes = Array(0..<laneCount).filter { !laneHasRecentVehicle($0) && !protectedLanes.contains($0) }
        if clearLanes.contains(playerLane) && trafficEventRNG.chance(0.5) {
            return playerLane
        }
        if let adjacent = trafficEventRNG.element(from: clearLanes.filter({ abs($0 - playerLane) <= 1 })) {
            return adjacent
        }
        return trafficEventRNG.element(from: clearLanes) ?? playerLane
    }

    private func protectedExitLanes() -> Set<Int> {
        guard exitPhase == .active, let activeExitSide else { return [] }
        return laneManager.exitGuardLanes(for: activeExitSide)
    }

    private func makeRoadblockNode() -> SKSpriteNode {
        let blockSize = CGSize(width: laneWidth * 0.78, height: 44)
        return ArcadeArt.makeRoadblock(size: blockSize)
    }

    private func showRoadblockWarning(lanes: [Int]) {
        AudioManager.shared.play(.roadblockWarning, volume: 0.82, cooldown: 0.7)

        for lane in lanes where laneCenters.indices.contains(lane) {
            let marker = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            marker.text = "!"
            marker.fontSize = 30
            marker.fontColor = SKColor.red
            marker.horizontalAlignmentMode = .center
            marker.verticalAlignmentMode = .center
            marker.position = CGPoint(x: laneCenters[lane], y: size.height - 128)
            marker.zPosition = 122
            floatingTextNode.addChild(marker)

            let down = SKAction.moveBy(x: 0, y: -28, duration: 0.32)
            let pulse = SKAction.sequence([.scale(to: 1.25, duration: 0.09), .scale(to: 1, duration: 0.09)])
            marker.run(.sequence([.group([down, .repeat(pulse, count: 3)]), .fadeOut(withDuration: 0.2), .removeFromParent()]))
        }
    }

    private func updateRoadEvents(deltaTime: TimeInterval) {
        if let event = currentEvent {
            eventTimer -= deltaTime
            eventSpawnTimer -= deltaTime
            updateActiveEvent(event)

            if eventTimer <= 0 {
                endRoadEvent()
            }
            return
        }

        eventCooldown -= deltaTime
        guard runTime > 18, eventCooldown <= 0 else { return }
        let event = trafficEventRNG.element(from: RoadEventType.allCases) ?? .trafficJam
        startRoadEvent(event)
    }

    private func startRoadEvent(_ event: RoadEventType) {
        currentEvent = event
        eventTimer = trafficEventRNG.double(in: 9.0...14.0)
        eventSpawnTimer = 0.4
        eventNode.removeAllChildren()
        showEventBanner(event.title)
        triggerEventCinematic(title: event.title, color: palette(for: currentCity).secondAccent)
        buildEventVisuals(for: event)

        switch event {
        case .trafficJam:
            spawnTrafficJamWave()
        case .constructionZone:
            spawnConstructionBlock()
        case .vipMotorcade:
            spawnVIPMotorcade()
        case .heavyRainTraffic:
            AtmosphereManager.shared.setWeather(.heavyRain)
            spawnTrafficJamWave(speedMultiplier: 0.9)
        case .bridgeCrossing, .tunnelRun:
            break
        }
    }

    private func updateActiveEvent(_ event: RoadEventType) {
        guard eventSpawnTimer <= 0 else { return }

        switch event {
        case .trafficJam:
            eventSpawnTimer = 1.55
            spawnTrafficJamWave()
        case .constructionZone:
            eventSpawnTimer = 3.2
            spawnConstructionBlock()
        case .vipMotorcade:
            eventSpawnTimer = 4.2
            spawnVIPMotorcade()
        case .heavyRainTraffic:
            eventSpawnTimer = 2.1
            spawnTrafficJamWave(speedMultiplier: 0.9)
        case .bridgeCrossing:
            eventSpawnTimer = 2.6
            spawnVehicle(in: safestRoadblockLane(), type: randomVehicleType(), speedMultiplier: 1.04)
        case .tunnelRun:
            eventSpawnTimer = 1.9
            spawnTrafficJamWave(count: 2, speedMultiplier: 1.08)
        }
    }

    private func endRoadEvent() {
        if currentEvent == .heavyRainTraffic {
            AtmosphereManager.shared.setWeather(.clear)
        }

        currentEvent = nil
        eventTimer = 0
        eventSpawnTimer = 0
        eventCooldown = trafficEventRNG.double(in: 15.0...24.0)
        eventNode.removeAllChildren()
    }

    private func spawnTrafficJamWave(count: Int = 4, speedMultiplier: CGFloat = 1) {
        let safeLane = safestRoadblockLane()
        let protectedLanes = protectedExitLanes()
        let targetCount = max(count, Int((4 + currentTrafficDensity() * 4).rounded()))
        var lanes = Array(0..<laneCount).filter { $0 != safeLane && !protectedLanes.contains($0) && !laneHasRecentVehicle($0) }
        lanes = trafficEventRNG.shuffled(lanes)
        let spawnCount = min(targetCount, lanes.count, laneCount - 2)

        for (index, lane) in lanes.prefix(spawnCount).enumerated() {
            spawnVehicle(
                in: lane,
                type: randomVehicleType(),
                yOffset: CGFloat(index) * 54,
                speedMultiplier: speedMultiplier
            )
        }
    }

    private func spawnConstructionBlock() {
        let safeLane = safestRoadblockLane()
        let protectedLanes = protectedExitLanes()
        var lanes = Array(0..<laneCount).filter { $0 != safeLane && !protectedLanes.contains($0) }
        lanes = trafficEventRNG.shuffled(lanes)
        let blockedLanes = Array(lanes.prefix(2))
        showRoadblockWarning(lanes: blockedLanes)

        for (index, lane) in blockedLanes.enumerated() {
            trafficSpawnSerial += 1
            let cone = makeConstructionNode()
            cone.position = CGPoint(x: laneCenters[lane], y: size.height + 84 + CGFloat(index) * 40)
            cone.userData = [
                "spawnID": trafficSpawnSerial,
                "lane": lane,
                "laneSpan": 1,
                "speed": roadSpeed * 0.96,
                "type": "construction",
                "spawnTime": runTime,
                "nearMissAwarded": false,
                "roadblock": true
            ]
            trafficNode.addChild(cone)
        }
    }

    private func makeConstructionNode() -> SKSpriteNode {
        ArcadeArt.makeConstructionMarker(laneWidth: laneWidth)
    }

    private func spawnVIPMotorcade() {
        let safeLane = safestRoadblockLane()
        let protectedLanes = protectedExitLanes()
        var lanes = Array(0..<laneCount).filter { $0 != safeLane && !protectedLanes.contains($0) && !laneHasRecentVehicle($0) }
        lanes = trafficEventRNG.shuffled(lanes)

        for (index, lane) in lanes.prefix(3).enumerated() {
            let type: VehicleType = index == 1 ? .sportCoupe : .sedan
            spawnVehicle(in: lane, type: type, yOffset: CGFloat(index) * 70, speedMultiplier: 1.08)
        }
    }

    private func showEventBanner(_ title: String) {
        let palette = palette(for: currentCity)
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = title
        label.fontSize = 24
        label.fontColor = palette.secondAccent
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        label.zPosition = 122
        fitLabel(label, maxWidth: size.width - 34)
        floatingTextNode.addChild(label)

        label.setScale(0.82)
        label.run(.sequence([
            .group([.fadeIn(withDuration: 0.08), .scale(to: 1.06, duration: 0.12)]),
            .scale(to: 1, duration: 0.08),
            .wait(forDuration: 0.72),
            .group([.moveBy(x: 0, y: 24, duration: 0.28), .fadeOut(withDuration: 0.28)]),
            .removeFromParent()
        ]))
    }

    private func triggerEventCinematic(title: String, color: SKColor) {
        let topBar = SKShapeNode(rect: CGRect(x: 0, y: size.height, width: size.width, height: 36))
        topBar.fillColor = SKColor.black.withAlphaComponent(0.72)
        topBar.strokeColor = .clear
        topBar.zPosition = 121
        floatingTextNode.addChild(topBar)

        let bottomBar = SKShapeNode(rect: CGRect(x: 0, y: -36, width: size.width, height: 36))
        bottomBar.fillColor = SKColor.black.withAlphaComponent(0.72)
        bottomBar.strokeColor = .clear
        bottomBar.zPosition = 121
        floatingTextNode.addChild(bottomBar)

        let label = UIHelpers.label(title, size: 22, color: color, width: size.width - 42)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        label.zPosition = 122
        label.alpha = 0
        floatingTextNode.addChild(label)

        topBar.run(.sequence([.moveBy(x: 0, y: -36, duration: 0.12), .wait(forDuration: 0.42), .moveBy(x: 0, y: 36, duration: 0.14), .removeFromParent()]))
        bottomBar.run(.sequence([.moveBy(x: 0, y: 36, duration: 0.12), .wait(forDuration: 0.42), .moveBy(x: 0, y: -36, duration: 0.14), .removeFromParent()]))
        label.run(.sequence([
            .group([.fadeIn(withDuration: 0.08), .scale(to: 1.08, duration: 0.12)]),
            .scale(to: 1, duration: 0.08),
            .wait(forDuration: 0.34),
            .group([.moveBy(x: 0, y: 18, duration: 0.16), .fadeOut(withDuration: 0.16)]),
            .removeFromParent()
        ]))
        shakeCamera(intensity: 4, duration: 0.12)
    }

    private func buildEventVisuals(for event: RoadEventType) {
        let palette = palette(for: currentCity)

        switch event {
        case .bridgeCrossing:
            for x in [roadLeft + 12, roadLeft + roadWidth - 12] {
                let rail = SKShapeNode(rectOf: CGSize(width: 7, height: size.height + 120), cornerRadius: 3)
                rail.position = CGPoint(x: x, y: size.height / 2)
                rail.fillColor = SKColor(red: 0.68, green: 0.78, blue: 0.86, alpha: 0.7)
                rail.strokeColor = palette.secondAccent.withAlphaComponent(0.45)
                rail.glowWidth = 5
                eventNode.addChild(rail)
            }
        case .tunnelRun:
            let topShadow = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            topShadow.fillColor = SKColor.black.withAlphaComponent(0.26)
            topShadow.strokeColor = .clear
            eventNode.addChild(topShadow)

            for x in [roadLeft + 16, roadLeft + roadWidth - 16] {
                let light = SKShapeNode(rectOf: CGSize(width: 12, height: size.height + 120), cornerRadius: 6)
                light.position = CGPoint(x: x, y: size.height / 2)
                light.fillColor = palette.accent.withAlphaComponent(0.22)
                light.strokeColor = .clear
                light.glowWidth = 10
                eventNode.addChild(light)
            }
        case .constructionZone:
            for lane in 0..<laneCount {
                let stripe = SKShapeNode(rectOf: CGSize(width: laneWidth * 0.42, height: 6), cornerRadius: 2)
                stripe.position = CGPoint(x: laneCenters[lane], y: size.height * 0.55)
                stripe.fillColor = SKColor(red: 1, green: 0.58, blue: 0.08, alpha: 0.26)
                stripe.strokeColor = .clear
                eventNode.addChild(stripe)
            }
        case .trafficJam, .vipMotorcade, .heavyRainTraffic:
            break
        }
    }

    // MARK: - Scoring and Difficulty

    private func updateScore(deltaTime: CGFloat) {
        runDistance += roadSpeed * deltaTime * 0.1
        scoreRemainder += roadSpeed * deltaTime * 0.1 * scoreMultiplier * passiveVehicleRewardScale
        cashRemainder += roadSpeed * deltaTime * 0.0035 * (1 + CGFloat(wantedLevel - 1) * 0.08) * passiveVehicleRewardScale

        let gained = Int(scoreRemainder)
        let cashGained = Int(cashRemainder)

        if gained > 0 {
            score += gained
            scoreRemainder -= CGFloat(gained)
        }

        if cashGained > 0 {
            runCash += cashGained
            cashRemainder -= CGFloat(cashGained)
        }

        if gained > 0 || cashGained > 0 {
            updateHUD()
        }
    }

    private func updateScoreLabel() {
        updateHUD()
    }

    private func updateDifficulty(deltaTime: TimeInterval) {
        guard gameMode == .endlessPursuit else { return }
        difficultyTimer += deltaTime

        if difficultyTimer >= 15 {
            difficultyTimer -= 15
            roadSpeed = min(560, roadSpeed + 36)
            trafficSpeed = min(500, trafficSpeed + 32)
            spawnInterval = max(0.54, spawnInterval - 0.08)
            policeClosingSpeed = min(6.2, policeClosingSpeed + 0.35)
        }
    }

    private func updateCityIfNeeded() {
        guard gameMode == .endlessPursuit else { return }
        guard AppConfig.forcedCity == .automatic else { return }
        let newWorld = WorldThemeCatalog.endlessTheme(score: score)
        let newCity = newWorld.audioCity.cityTheme

        guard newCity != currentCity || newWorld.id != currentWorld.id else { return }
        currentWorld = newWorld
        currentCity = newCity
        setupRoad()
        positionPlayer(animated: true)
        positionPolice(deltaTime: 1)
        let cityPalette = palette(for: newCity)
        AudioManager.shared.updateTheme(newCity.audioTheme)
        AudioManager.shared.play(.cityTransition, volume: 0.82, cooldown: 0.7)
        AtmosphereManager.shared.triggerCitySweep(primary: cityPalette.accent, secondary: cityPalette.secondAccent)
        if AudioManager.shared.isHapticsEnabled {
            warningHaptic.impactOccurred(intensity: 0.55)
            warningHaptic.prepare()
        }
        showCityBanner(newWorld.displayName.uppercased())
        triggerEventCinematic(title: "\(newWorld.shortName.uppercased()) ARRIVAL", color: cityPalette.accent)
    }

    private func checkNearMiss(for vehicle: SKSpriteNode) {
        guard let playerCar,
              let lane = vehicle.userData?["lane"] as? Int,
              let awarded = vehicle.userData?["nearMissAwarded"] as? Bool,
              awarded == false else {
            return
        }

        let span = vehicle.userData?["laneSpan"] as? Int ?? 1
        let occupied = occupiedLanes(for: lane, span: span)
        let isCloseLane = occupied.contains(playerLane) || occupied.contains(playerLane - 1) || occupied.contains(playerLane + 1)
        let verticalDistance = abs(vehicle.position.y - playerCar.position.y)
        let isInNearMissWindow = verticalDistance < playerCar.size.height * 0.86

        if isCloseLane && isInNearMissWindow && !trafficHitboxRect(for: vehicle).intersects(playerHitboxRect()) {
            vehicle.userData?["nearMissAwarded"] = true
            nearMissCount += 1
            advanceCombo()
            let scoreBonus = Int(CGFloat(25 + min(comboCount, 10) * 5) * scoreMultiplier * activeCar.nearMissMultiplier)
            let cashBonus = 1 + min(comboCount, 8) / 2 + wantedLevel / 2
            score += scoreBonus
            runCash += cashBonus
            updateHUD()
            pushPoliceBack()
            triggerNearMissFeel()
            showBonusText(
                text: "+\(scoreBonus)  +$\(cashBonus)",
                at: CGPoint(x: playerCar.position.x, y: playerCar.position.y + playerCar.size.height * 0.9)
            )
        }
    }

    private func checkLaneSplitOpportunities() {
        guard activeCar.canLaneSplit,
              laneManager.isSplitSlot(playerSlot),
              let playerCar else { return }

        let leftLane = playerSlot / 2
        let rightLane = leftLane + 1
        guard rightLane < laneCount else { return }

        let candidates = trafficNode.children.compactMap { $0 as? SKSpriteNode }
            .filter { vehicle in
                guard let lane = vehicle.userData?["lane"] as? Int else { return false }
                let span = vehicle.userData?["laneSpan"] as? Int ?? 1
                let occupied = occupiedLanes(for: lane, span: span)
                let verticalDistance = abs(vehicle.position.y - playerCar.position.y)
                return verticalDistance < playerCar.size.height * 0.95 && !trafficHitboxRect(for: vehicle).intersects(playerHitboxRect()) && !occupied.isSuperset(of: [leftLane, rightLane])
            }

        guard let leftVehicle = candidates.first(where: { vehicle in
            guard let lane = vehicle.userData?["lane"] as? Int else { return false }
            return occupiedLanes(for: lane, span: vehicle.userData?["laneSpan"] as? Int ?? 1).contains(leftLane)
        }), let rightVehicle = candidates.first(where: { vehicle in
            guard let lane = vehicle.userData?["lane"] as? Int else { return false }
            return occupiedLanes(for: lane, span: vehicle.userData?["laneSpan"] as? Int ?? 1).contains(rightLane)
        }) else { return }

        let leftID = leftVehicle.userData?["spawnID"] as? Int ?? 0
        let rightID = rightVehicle.userData?["spawnID"] as? Int ?? 0
        let key = "\(min(leftID, rightID))-\(max(leftID, rightID))-\(playerSlot)"
        guard !awardedLaneSplitPairs.contains(key) else { return }
        awardedLaneSplitPairs.insert(key)
        awardLaneSplit(at: playerCar.position)
    }

    private func awardLaneSplit(at position: CGPoint) {
        laneSplitCount += 1
        advanceCombo()
        activateDodgeBoost()
        pushPoliceBack()

        let scoreBonus = Int(CGFloat(42 + min(comboCount, 12) * 5) * scoreMultiplier * activeCar.nearMissMultiplier)
        let cashBonus = 2 + min(comboCount, 10) / 3 + wantedLevel
        score += scoreBonus
        runCash += cashBonus
        updateHUD()

        AudioManager.shared.play(.laneSplit, volume: 0.84, cooldown: 0.08)
        if AudioManager.shared.isHapticsEnabled {
            nearMissHaptic.impactOccurred(intensity: 0.9)
            nearMissHaptic.prepare()
        }
        showAwardPopup(
            title: ["LANE SPLIT", "THREAD THE GAP", "BIKE SKILL"].randomElement() ?? "LANE SPLIT",
            subtitle: "+\(scoreBonus)  +$\(cashBonus)",
            at: CGPoint(x: position.x, y: position.y + 74),
            color: activeCar.accentColor,
            scale: 1.04
        )
        emitLaneSplitSparks(at: position)
        shakeCamera(intensity: 3.8, duration: 0.1)
    }

    private func emitLaneSplitSparks(at position: CGPoint) {
        let palette = palette(for: currentCity)
        for index in 0..<14 {
            let spark = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 8...20)), cornerRadius: 1)
            spark.fillColor = (index.isMultiple(of: 2) ? activeCar.accentColor : palette.secondAccent).withAlphaComponent(0.88)
            spark.strokeColor = .clear
            spark.glowWidth = 4
            spark.userData = ["assetID": ArcadeArt.EffectAsset.crashSpark.rawValue]
            spark.position = CGPoint(x: position.x + CGFloat.random(in: -12...12), y: position.y + CGFloat.random(in: -12...26))
            spark.zRotation = CGFloat.random(in: -0.7...0.7)
            floatingTextNode.addChild(spark)
            spark.run(.sequence([
                .group([
                    .moveBy(x: CGFloat.random(in: -26...26), y: CGFloat.random(in: 36...76), duration: 0.24),
                    .fadeOut(withDuration: 0.24)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func triggerNearMissFeel() {
        AudioManager.shared.play(.nearMiss, volume: 0.76, cooldown: 0.08)
        if comboCount > 1 {
            AudioManager.shared.play(.comboIncrease, volume: min(1.0, 0.5 + Float(comboCount) * 0.06), cooldown: 0.12)
        }

        activateDodgeBoost()
        buddy.say(.nearMiss, force: false)
        if AudioManager.shared.isHapticsEnabled {
            nearMissHaptic.impactOccurred(intensity: 0.75)
            nearMissHaptic.prepare()
        }
        shakeCamera(intensity: 3, duration: 0.12)
        if let playerCar {
            emitNearMissSparks(at: playerCar.position)
        }

        for line in speedLineNode.children {
            line.run(.sequence([
                .fadeAlpha(to: 0.34, duration: 0.04),
                .fadeAlpha(to: CGFloat.random(in: 0.1...0.2), duration: 0.18)
            ]))
        }
    }

    private func advanceCombo() {
        comboCount += 1
        highestCombo = max(highestCombo, comboCount)
        comboTimer = comboDuration
        if [3, 5, 8, 10].contains(comboCount) || comboCount > 10 && comboCount.isMultiple(of: 5) {
            showComboMilestone(comboCount)
        }
        updateHUD()
    }

    private func showComboMilestone(_ combo: Int) {
        let palette = palette(for: currentCity)
        let title: String
        if combo >= 10 {
            title = "NEON FLOW x\(combo)"
        } else if combo >= 8 {
            title = "HOT STREAK x\(combo)"
        } else if combo >= 5 {
            title = "COMBO x\(combo)"
        } else {
            title = "CHAIN x\(combo)"
        }

        let banner = SKShapeNode(rectOf: CGSize(width: min(size.width - 36, 320), height: 46), cornerRadius: 9)
        banner.fillColor = UITheme.Color.panelDeep.withAlphaComponent(combo >= 10 ? 0.92 : 0.76)
        banner.strokeColor = combo >= 10 ? palette.secondAccent : palette.accent
        banner.lineWidth = 2
        banner.glowWidth = combo >= 10 ? 14 : 7
        banner.position = CGPoint(x: size.width / 2, y: size.height * 0.64)
        floatingTextNode.addChild(banner)

        let label = UIHelpers.label(title, size: combo >= 10 ? 25 : 21, color: combo >= 10 ? palette.secondAccent : palette.accent, width: banner.frame.width - 24)
        label.position = .zero
        banner.addChild(label)

        banner.setScale(0.82)
        banner.run(.sequence([
            .group([.scale(to: 1.08, duration: 0.1), .fadeIn(withDuration: 0.08)]),
            .scale(to: 1, duration: 0.1),
            .wait(forDuration: combo >= 10 ? 0.5 : 0.28),
            .group([.moveBy(x: 0, y: 22, duration: 0.22), .fadeOut(withDuration: 0.22)]),
            .removeFromParent()
        ]))

        emitDodgeBoostStreaks(count: combo >= 10 ? 18 : 8)
        if combo >= 10 {
            shakeCamera(intensity: 5, duration: 0.16)
            AudioManager.shared.setDangerIntensity(1)
        }
    }

    private func updateCombo(deltaTime: TimeInterval) {
        guard comboCount > 0 else { return }
        comboTimer = max(0, comboTimer - deltaTime)
        if comboTimer == 0 {
            comboCount = 0
            comboAuraNode.removeAllChildren()
            comboAuraNode.alpha = 0
        }
        updateHUD()
    }

    private func showBonusText(text: String = "+25", at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = 24
        label.fontColor = SKColor(red: 0.35, green: 1, blue: 0.42, alpha: 1)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = position
        floatingTextNode.addChild(label)

        let rise = SKAction.moveBy(x: 0, y: 42, duration: 0.55)
        let fade = SKAction.fadeOut(withDuration: 0.55)
        label.run(.sequence([.group([rise, fade]), .removeFromParent()]))
    }

    private func showAwardPopup(title: String, subtitle: String, at position: CGPoint, color: SKColor, scale: CGFloat) {
        let container = SKNode()
        container.position = position
        container.setScale(scale)
        floatingTextNode.addChild(container)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = title
        titleLabel.fontSize = title.count > 14 ? 20 : 26
        titleLabel.fontColor = color
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 14)
        fitLabel(titleLabel, maxWidth: size.width - 44)
        container.addChild(titleLabel)

        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        subtitleLabel.text = subtitle
        subtitleLabel.fontSize = 17
        subtitleLabel.fontColor = .white
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: 0, y: -12)
        container.addChild(subtitleLabel)

        let rise = SKAction.moveBy(x: 0, y: 54, duration: 0.68)
        rise.timingMode = .easeOut
        let pop = SKAction.sequence([
            .scale(to: scale * 1.12, duration: 0.08),
            .scale(to: scale, duration: 0.1)
        ])
        let fade = SKAction.fadeOut(withDuration: 0.68)
        container.run(.sequence([.group([rise, pop, fade]), .removeFromParent()]))
    }

    private func emitNearMissSparks(at position: CGPoint) {
        let palette = palette(for: currentCity)
        for _ in 0..<10 {
            let spark = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 3...7), height: 2), cornerRadius: 1)
            spark.fillColor = [palette.accent, palette.secondAccent, ArcadeArt.Palette.cream].randomElement() ?? ArcadeArt.Palette.cream
            spark.strokeColor = .clear
            spark.userData = ["assetID": ArcadeArt.EffectAsset.crashSpark.rawValue]
            spark.position = CGPoint(
                x: position.x + CGFloat.random(in: -26...26),
                y: position.y + CGFloat.random(in: 4...36)
            )
            spark.zRotation = CGFloat.random(in: -1.2...1.2)
            floatingTextNode.addChild(spark)

            let fly = SKAction.moveBy(x: CGFloat.random(in: -36...36), y: CGFloat.random(in: 26...64), duration: 0.28)
            let fade = SKAction.fadeOut(withDuration: 0.28)
            spark.run(.sequence([.group([fly, fade]), .removeFromParent()]))
        }
    }

    // MARK: - Collision

    private func checkCollisions() {
        guard let playerCar else { return }
        guard invulnerabilityTimer <= 0 else { return }
        let playerRect = playerHitboxRect()

        for node in trafficNode.children {
            guard let vehicle = node as? SKSpriteNode else { continue }

            let trafficRect = trafficHitboxRect(for: vehicle)
            if trafficRect.intersects(playerRect) {
                recordTelemetry(
                    event: "collision",
                    terminalReason: (vehicle.userData?["roadblock"] as? Bool) == true ? "roadblock" : "traffic",
                    levelCompleted: false,
                    collisionVehicle: vehicle,
                    playerRect: playerRect,
                    trafficRect: trafficRect
                )
                endGame(crashPoint: CGPoint(
                    x: (vehicle.position.x + playerCar.position.x) / 2,
                    y: (vehicle.position.y + playerCar.position.y) / 2
                ), reason: (vehicle.userData?["roadblock"] as? Bool) == true ? "roadblock" : "traffic")
                return
            }
        }
    }

    private func playerHitboxRect() -> CGRect {
        guard let playerCar else { return .null }
        let width = playerCar.size.width * activeCar.collisionWidthMultiplier
        let height = playerCar.size.height * (activeCar.vehicleClass == .motorcycle ? 0.82 : 0.9)
        return CGRect(
            x: playerCar.position.x - width / 2,
            y: playerCar.position.y - height / 2,
            width: width,
            height: height
        )
    }

    private func trafficHitboxRect(for vehicle: SKSpriteNode) -> CGRect {
        let typeName = vehicle.userData?["type"] as? String
        let type = typeName.flatMap(VehicleType.init(rawValue:))
        let roadblock = vehicle.userData?["roadblock"] as? Bool == true
        let widthScale: CGFloat
        let heightScale: CGFloat

        if roadblock {
            widthScale = 1.02
            heightScale = 0.92
        } else {
            let scale = type.map { ArcadeArt.hitboxScale(for: $0) } ?? ArcadeArt.HitboxScale(width: 0.9, height: 0.9)
            widthScale = scale.width
            heightScale = scale.height
        }

        let width = vehicle.size.width * widthScale
        let height = vehicle.size.height * heightScale
        return CGRect(
            x: vehicle.position.x - width / 2,
            y: vehicle.position.y - height / 2,
            width: width,
            height: height
        )
    }

    // MARK: - Vehicles

    private func makePlayerCar() -> SKSpriteNode {
        let car = VehicleRenderer.gameplayCar(car: activeCar, paint: activePaint, laneWidth: laneWidth)
        car.zPosition = 2
        return car
    }

    private func makePoliceCar() -> SKSpriteNode {
        let car = ArcadeArt.makeVehicleSprite(
            spec: ArcadeArt.policeCruiserSpec(laneWidth: laneWidth, world: currentWorld),
            reducedFlashing: SaveManager.shared.data.reducedFlashingEnabled
        )
        car.zPosition = 1
        return car
    }

    private func makeTrafficVehicle(type: VehicleType) -> SKSpriteNode {
        let spec = ArcadeArt.trafficSpec(for: type, laneWidth: laneWidth, world: currentWorld)
        let vehicle = ArcadeArt.makeVehicleSprite(
            spec: spec,
            reducedFlashing: SaveManager.shared.data.reducedFlashingEnabled
        )
        vehicle.zPosition = 1
        return vehicle
    }

    private func addMotorcycleDetails(to vehicle: SKSpriteNode, size: CGSize, bodyColor: SKColor, accent: SKColor, police: Bool) {
        let frontWheel = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.72, height: size.height * 0.2))
        frontWheel.fillColor = .black
        frontWheel.strokeColor = accent.withAlphaComponent(0.35)
        frontWheel.position = CGPoint(x: 0, y: size.height * 0.38)
        vehicle.addChild(frontWheel)

        let rearWheel = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.74, height: size.height * 0.22))
        rearWheel.fillColor = .black
        rearWheel.strokeColor = accent.withAlphaComponent(0.35)
        rearWheel.position = CGPoint(x: 0, y: -size.height * 0.38)
        vehicle.addChild(rearWheel)

        let fairing = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: size.height * 0.48), cornerRadius: size.width * 0.32)
        fairing.fillColor = police ? SKColor.white.withAlphaComponent(0.92) : bodyColor
        fairing.strokeColor = accent.withAlphaComponent(0.75)
        fairing.lineWidth = 1.2
        fairing.position = CGPoint(x: 0, y: size.height * 0.02)
        vehicle.addChild(fairing)

        let rider = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.64, height: size.height * 0.2))
        rider.fillColor = SKColor.black.withAlphaComponent(0.82)
        rider.strokeColor = .clear
        rider.position = CGPoint(x: 0, y: -size.height * 0.08)
        vehicle.addChild(rider)

        if police {
            let bar = SKShapeNode(rectOf: CGSize(width: size.width * 0.92, height: 5), cornerRadius: 2)
            bar.fillColor = SKColor.red
            bar.strokeColor = SKColor.blue
            bar.glowWidth = 4
            bar.position = CGPoint(x: 0, y: size.height * 0.12)
            vehicle.addChild(bar)
        }
    }

    private enum WheelStyle {
        case standard
        case sport
        case heavy
    }

    private func makeVehicleShell(
        size: CGSize,
        bodyColor: SKColor,
        strokeColor: SKColor,
        glowColor: SKColor,
        frontInset: CGFloat,
        rearInset: CGFloat
    ) -> SKSpriteNode {
        let vehicle = SKSpriteNode(color: .clear, size: size)

        let shadow = SKShapeNode(path: vehicleBodyPath(size: size, frontInset: frontInset, rearInset: rearInset))
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.38)
        shadow.strokeColor = .clear
        shadow.zPosition = -4
        vehicle.addChild(shadow)

        let glow = SKShapeNode(path: vehicleBodyPath(size: CGSize(width: size.width * 1.06, height: size.height * 1.04), frontInset: frontInset, rearInset: rearInset))
        glow.fillColor = glowColor.withAlphaComponent(0.12)
        glow.strokeColor = glowColor.withAlphaComponent(0.28)
        glow.lineWidth = 2
        glow.zPosition = -3
        vehicle.addChild(glow)

        let body = SKShapeNode(path: vehicleBodyPath(size: size, frontInset: frontInset, rearInset: rearInset))
        body.fillColor = bodyColor
        body.strokeColor = strokeColor.withAlphaComponent(0.8)
        body.lineWidth = 1.6
        body.zPosition = 0
        vehicle.addChild(body)

        let leftFacet = SKShapeNode(path: facetPath(size: size, isLeft: true))
        leftFacet.fillColor = SKColor.black.withAlphaComponent(0.16)
        leftFacet.strokeColor = .clear
        leftFacet.zPosition = 1
        vehicle.addChild(leftFacet)

        let rightFacet = SKShapeNode(path: facetPath(size: size, isLeft: false))
        rightFacet.fillColor = SKColor.white.withAlphaComponent(0.12)
        rightFacet.strokeColor = .clear
        rightFacet.zPosition = 1
        vehicle.addChild(rightFacet)

        return vehicle
    }

    private func vehicleBodyPath(size: CGSize, frontInset: CGFloat, rearInset: CGFloat) -> CGPath {
        let width = size.width
        let height = size.height
        let frontHalf = width * (0.5 - frontInset)
        let rearHalf = width * (0.5 - rearInset)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -frontHalf, y: height / 2))
        path.addLine(to: CGPoint(x: frontHalf, y: height / 2))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.18))
        path.addLine(to: CGPoint(x: rearHalf, y: -height / 2))
        path.addLine(to: CGPoint(x: -rearHalf, y: -height / 2))
        path.addLine(to: CGPoint(x: -width * 0.5, y: height * 0.18))
        path.closeSubpath()
        return path
    }

    private func facetPath(size: CGSize, isLeft: Bool) -> CGPath {
        let sign: CGFloat = isLeft ? -1 : 1
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height * 0.42))
        path.addLine(to: CGPoint(x: sign * size.width * 0.44, y: size.height * 0.14))
        path.addLine(to: CGPoint(x: sign * size.width * 0.34, y: -size.height * 0.42))
        path.addLine(to: CGPoint(x: sign * size.width * 0.08, y: -size.height * 0.2))
        path.closeSubpath()
        return path
    }

    private func addHoodPanel(to vehicle: SKSpriteNode, size: CGSize, color: SKColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -size.width * 0.22, y: size.height * 0.43))
        path.addLine(to: CGPoint(x: size.width * 0.22, y: size.height * 0.43))
        path.addLine(to: CGPoint(x: size.width * 0.32, y: size.height * 0.18))
        path.addLine(to: CGPoint(x: -size.width * 0.32, y: size.height * 0.18))
        path.closeSubpath()

        let hood = SKShapeNode(path: path)
        hood.fillColor = color
        hood.strokeColor = SKColor.white.withAlphaComponent(0.12)
        hood.lineWidth = 1
        hood.zPosition = 2
        vehicle.addChild(hood)
    }

    private func addWindow(to vehicle: SKSpriteNode, size: CGSize, y: CGFloat, widthScale: CGFloat, heightScale: CGFloat, color: SKColor) {
        let window = SKShapeNode(rectOf: CGSize(width: size.width * widthScale, height: size.height * heightScale), cornerRadius: 4)
        window.fillColor = color
        window.strokeColor = SKColor.white.withAlphaComponent(0.32)
        window.lineWidth = 1
        window.position = CGPoint(x: 0, y: y)
        window.zPosition = 4
        vehicle.addChild(window)
    }

    private func addVehicleHighlight(to vehicle: SKSpriteNode, size: CGSize, color: SKColor) {
        let shine = SKShapeNode(rectOf: CGSize(width: size.width * 0.1, height: size.height * 0.72), cornerRadius: 2)
        shine.fillColor = color
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -size.width * 0.18, y: size.height * 0.02)
        shine.zRotation = -0.18
        shine.zPosition = 5
        vehicle.addChild(shine)
    }

    private func addVehicleLights(to vehicle: SKSpriteNode, size: CGSize, headColor: SKColor, tailColor: SKColor) {
        for x in [-size.width * 0.2, size.width * 0.2] {
            let headGlow = SKShapeNode(circleOfRadius: 5)
            headGlow.fillColor = headColor.withAlphaComponent(0.22)
            headGlow.strokeColor = .clear
            headGlow.position = CGPoint(x: x, y: size.height * 0.47)
            headGlow.zPosition = 6
            vehicle.addChild(headGlow)

            let head = SKShapeNode(rectOf: CGSize(width: size.width * 0.16, height: 4), cornerRadius: 2)
            head.fillColor = headColor
            head.strokeColor = .clear
            head.position = CGPoint(x: x, y: size.height * 0.45)
            head.zPosition = 7
            vehicle.addChild(head)

            let tail = SKShapeNode(rectOf: CGSize(width: size.width * 0.13, height: 4), cornerRadius: 2)
            tail.fillColor = tailColor
            tail.strokeColor = .clear
            tail.position = CGPoint(x: x, y: -size.height * 0.46)
            tail.zPosition = 7
            vehicle.addChild(tail)
        }
    }

    private func addPoliceLightBar(to car: SKSpriteNode, size: CGSize) {
        let reducedFlashing = SaveManager.shared.data.reducedFlashingEnabled
        let bar = SKShapeNode(rectOf: CGSize(width: size.width * 0.48, height: 11), cornerRadius: 3)
        bar.fillColor = SKColor.black.withAlphaComponent(0.8)
        bar.strokeColor = SKColor.white.withAlphaComponent(0.4)
        bar.position = CGPoint(x: 0, y: size.height * 0.06)
        bar.zPosition = 8
        car.addChild(bar)

        let redLight = SKShapeNode(rectOf: CGSize(width: size.width * 0.2, height: 8), cornerRadius: 3)
        redLight.fillColor = .red
        redLight.strokeColor = .clear
        redLight.position = CGPoint(x: -size.width * 0.13, y: size.height * 0.06)
        redLight.zPosition = 9
        car.addChild(redLight)

        let blueLight = SKShapeNode(rectOf: CGSize(width: size.width * 0.2, height: 8), cornerRadius: 3)
        blueLight.fillColor = .blue
        blueLight.strokeColor = .clear
        blueLight.position = CGPoint(x: size.width * 0.13, y: size.height * 0.06)
        blueLight.zPosition = 9
        car.addChild(blueLight)

        let redGlow = SKShapeNode(circleOfRadius: size.width * 0.27)
        redGlow.fillColor = SKColor.red.withAlphaComponent(reducedFlashing ? 0.08 : 0.2)
        redGlow.strokeColor = .clear
        redGlow.position = CGPoint(x: -size.width * 0.18, y: size.height * 0.08)
        redGlow.zPosition = 7
        car.addChild(redGlow)

        let blueGlow = SKShapeNode(circleOfRadius: size.width * 0.27)
        blueGlow.fillColor = SKColor.blue.withAlphaComponent(reducedFlashing ? 0.08 : 0.2)
        blueGlow.strokeColor = .clear
        blueGlow.position = CGPoint(x: size.width * 0.18, y: size.height * 0.08)
        blueGlow.zPosition = 7
        car.addChild(blueGlow)

        let highAlpha: CGFloat = reducedFlashing ? 0.62 : 1
        let lowAlpha: CGFloat = reducedFlashing ? 0.32 : 0.16
        let glowHigh: CGFloat = reducedFlashing ? 0.18 : 0.5
        let glowLow: CGFloat = reducedFlashing ? 0.04 : 0.06
        let flashDuration = reducedFlashing ? 0.28 : 0.11
        redLight.run(.repeatForever(.sequence([.fadeAlpha(to: highAlpha, duration: flashDuration), .fadeAlpha(to: lowAlpha, duration: flashDuration)])))
        blueLight.run(.repeatForever(.sequence([.fadeAlpha(to: lowAlpha, duration: flashDuration), .fadeAlpha(to: highAlpha, duration: flashDuration)])))
        redGlow.run(.repeatForever(.sequence([.fadeAlpha(to: glowHigh, duration: flashDuration), .fadeAlpha(to: glowLow, duration: flashDuration)])))
        blueGlow.run(.repeatForever(.sequence([.fadeAlpha(to: glowLow, duration: flashDuration), .fadeAlpha(to: glowHigh, duration: flashDuration)])))
    }

    private func addWheels(to vehicle: SKSpriteNode, size: CGSize, style: WheelStyle) {
        let wheelSize: CGSize
        let xOffset: CGFloat
        let yOffset: CGFloat

        switch style {
        case .standard:
            wheelSize = CGSize(width: 8, height: size.height * 0.22)
            xOffset = size.width * 0.5
            yOffset = size.height * 0.23
        case .sport:
            wheelSize = CGSize(width: 7, height: size.height * 0.2)
            xOffset = size.width * 0.51
            yOffset = size.height * 0.24
        case .heavy:
            wheelSize = CGSize(width: 9, height: size.height * 0.24)
            xOffset = size.width * 0.52
            yOffset = size.height * 0.26
        }

        for x in [-xOffset, xOffset] {
            for y in [-yOffset, yOffset] {
                let wheel = SKShapeNode(rectOf: wheelSize, cornerRadius: 3)
                wheel.fillColor = SKColor.black
                wheel.strokeColor = SKColor.white.withAlphaComponent(0.12)
                wheel.position = CGPoint(x: x, y: y)
                wheel.zPosition = -1
                vehicle.addChild(wheel)

                let hub = SKShapeNode(rectOf: CGSize(width: wheelSize.width * 0.45, height: wheelSize.height * 0.42), cornerRadius: 2)
                hub.fillColor = SKColor(white: 0.28, alpha: 1)
                hub.strokeColor = .clear
                hub.position = CGPoint(x: x, y: y)
                hub.zPosition = 0
                vehicle.addChild(hub)
            }
        }
    }

    // MARK: - City Themes

    private func palette(for city: CityTheme) -> ThemePalette {
        if currentWorld.audioCity.cityTheme == city {
            return currentWorld.palette
        }
        return WorldThemeCatalog.legacyTheme(for: city).palette
    }

    private func showCityBanner(_ text: String) {
        let palette = palette(for: currentCity)
        let reducedFlashing = SaveManager.shared.data.reducedFlashingEnabled
        let flash = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        flash.fillColor = palette.accent.withAlphaComponent(reducedFlashing ? 0.06 : 0.18)
        flash.strokeColor = .clear
        flash.alpha = 0
        floatingTextNode.addChild(flash)

        let wipe = SKShapeNode(rect: CGRect(x: -size.width, y: size.height * 0.66, width: size.width, height: 64))
        wipe.fillColor = palette.secondAccent.withAlphaComponent(reducedFlashing ? 0.16 : 0.34)
        wipe.strokeColor = .clear
        floatingTextNode.addChild(wipe)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = text.count > 9 ? 38 : 46
        label.fontColor = palette.accent
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        label.alpha = 0
        fitLabel(label, maxWidth: size.width - 36)

        let shadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        shadow.text = text
        shadow.fontSize = label.fontSize
        shadow.fontColor = SKColor.black.withAlphaComponent(0.8)
        shadow.horizontalAlignmentMode = .center
        shadow.verticalAlignmentMode = .center
        shadow.position = CGPoint(x: 4, y: -4)
        shadow.zPosition = -1
        label.addChild(shadow)
        floatingTextNode.addChild(label)

        flash.run(.sequence([.fadeIn(withDuration: 0.08), .fadeOut(withDuration: 0.34), .removeFromParent()]))
        wipe.run(.sequence([
            .moveTo(x: size.width * 1.5, duration: 0.42),
            .removeFromParent()
        ]))

        let appear = SKAction.fadeIn(withDuration: 0.18)
        let hold = SKAction.wait(forDuration: 0.8)
        let rise = SKAction.moveBy(x: 0, y: 26, duration: 0.45)
        let fade = SKAction.fadeOut(withDuration: 0.45)
        let scaleIn = SKAction.scale(to: 1.08, duration: 0.18)
        let settle = SKAction.scale(to: 1, duration: 0.18)
        label.setScale(0.88)
        label.run(.sequence([.group([appear, scaleIn]), settle, hold, .group([rise, fade]), .removeFromParent()]))
    }
}
