import SpriteKit

/// Lightweight SpriteKit atmosphere layer for weather, lighting, city glow, and feedback overlays.
/// The manager owns reusable nodes and updates them each frame instead of creating effects constantly.
final class AtmosphereManager {
    static let shared = AtmosphereManager()

    enum WeatherMode: String, CaseIterable {
        case clear
        case rain
        case heavyRain
        case fog
        case nightStorm
    }

    private let rootNode = SKNode()
    private let glowNode = SKNode()
    private let reflectionNode = SKNode()
    private let weatherNode = SKNode()
    private let overlayNode = SKNode()
    private let lightningNode = SKShapeNode()
    private let dangerOverlay = SKShapeNode()

    private weak var scene: SKScene?
    private var sceneSize: CGSize = .zero
    private var roadFrame: CGRect = .zero
    private var currentWeather: WeatherMode = .clear
    private var rainDrops: [(node: SKShapeNode, speed: CGFloat)] = []
    private var stormTimer: TimeInterval = 2.8
    private var cityPrimaryGlow = SKColor.cyan
    private var citySecondaryGlow = SKColor.magenta

    private init() {}

    // MARK: - Scene Attachment

    func attach(to scene: SKScene) {
        self.scene = scene
        sceneSize = scene.size

        if rootNode.parent !== scene {
            rootNode.removeFromParent()
            scene.addChild(rootNode)
        }

        rootNode.zPosition = 76

        if glowNode.parent == nil {
            rootNode.addChild(glowNode)
            rootNode.addChild(reflectionNode)
            rootNode.addChild(weatherNode)
            rootNode.addChild(overlayNode)
        }

        if lightningNode.parent == nil {
            lightningNode.zPosition = 10
            lightningNode.fillColor = .white
            lightningNode.strokeColor = .clear
            lightningNode.alpha = 0
            overlayNode.addChild(lightningNode)
        }

        if dangerOverlay.parent == nil {
            dangerOverlay.zPosition = 8
            dangerOverlay.fillColor = SKColor.red.withAlphaComponent(0.25)
            dangerOverlay.strokeColor = .clear
            dangerOverlay.alpha = 0
            overlayNode.addChild(dangerOverlay)
        }

        updateLayout(size: scene.size)
    }

    func updateLayout(size: CGSize) {
        sceneSize = size
        lightningNode.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        dangerOverlay.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        rebuildCityGlow()
        rebuildReflections()
        resetRainPositions()
    }

    func setRoadFrame(_ frame: CGRect) {
        roadFrame = frame
        rebuildReflections()
    }

    // MARK: - Weather and Lighting

    func setWeather(_ weather: WeatherMode, animated: Bool = true) {
        guard weather != currentWeather else { return }
        currentWeather = weather
        rebuildWeather(animated: animated)
    }

    func setCityGlow(primary: SKColor, secondary: SKColor) {
        cityPrimaryGlow = primary
        citySecondaryGlow = secondary
        rebuildCityGlow()
        rebuildReflections()
    }

    func setDangerPulse(_ intensity: CGFloat) {
        let clamped = clamp(intensity, min: 0, max: 1)
        let cap: CGFloat = SaveManager.shared.data.reducedFlashingEnabled ? 0.14 : 0.34
        dangerOverlay.alpha += (clamped * cap - dangerOverlay.alpha) * 0.12
    }

    func triggerCitySweep(primary: SKColor, secondary: SKColor) {
        let sweep = SKShapeNode(rectOf: CGSize(width: 42, height: sceneSize.height * 1.4))
        sweep.fillColor = primary.withAlphaComponent(0.34)
        sweep.strokeColor = secondary.withAlphaComponent(0.55)
        sweep.lineWidth = 6
        sweep.glowWidth = 14
        sweep.zRotation = -0.25
        sweep.position = CGPoint(x: -60, y: sceneSize.height / 2)
        sweep.zPosition = 9
        overlayNode.addChild(sweep)

        let move = SKAction.moveTo(x: sceneSize.width + 80, duration: 0.42)
        move.timingMode = .easeOut
        sweep.run(.sequence([move, .removeFromParent()]))
    }

    func triggerLightning() {
        let reduced = SaveManager.shared.data.reducedFlashingEnabled
        lightningNode.removeAllActions()
        lightningNode.alpha = reduced ? 0.2 : 0.72
        let first = SKAction.fadeAlpha(to: reduced ? 0.06 : 0.08, duration: reduced ? 0.14 : 0.06)
        let second = SKAction.fadeAlpha(to: reduced ? 0.14 : 0.46, duration: reduced ? 0.1 : 0.04)
        let fade = SKAction.fadeOut(withDuration: reduced ? 0.16 : 0.24)
        lightningNode.run(.sequence([first, second, fade]))
        AudioManager.shared.play(.thunder, volume: 0.55, cooldown: 2.8)
    }

    // MARK: - Frame Update

    func update(deltaTime: TimeInterval) {
        guard sceneSize != .zero else { return }
        updateRain(deltaTime: deltaTime)
        updateStorm(deltaTime: deltaTime)
    }

    private func updateRain(deltaTime: TimeInterval) {
        guard currentWeather == .rain || currentWeather == .heavyRain || currentWeather == .nightStorm else { return }

        let wind = currentWeather == .heavyRain ? CGFloat(-82) : CGFloat(-54)
        for index in rainDrops.indices {
            let drop = rainDrops[index].node
            let speed = rainDrops[index].speed
            drop.position.x += wind * CGFloat(deltaTime)
            drop.position.y -= speed * CGFloat(deltaTime)

            if drop.position.y < -40 || drop.position.x < -40 {
                drop.position = CGPoint(
                    x: CGFloat.random(in: 0...max(sceneSize.width, 1)) + 30,
                    y: sceneSize.height + CGFloat.random(in: 10...120)
                )
            }
        }
    }

    private func updateStorm(deltaTime: TimeInterval) {
        guard currentWeather == .nightStorm else { return }
        stormTimer -= deltaTime
        if stormTimer <= 0 {
            stormTimer = Double.random(in: 4.0...7.5)
            triggerLightning()
        }
    }

    // MARK: - Builders

    private func rebuildWeather(animated: Bool) {
        weatherNode.removeAllChildren()
        rainDrops.removeAll()

        switch currentWeather {
        case .clear:
            rebuildReflections()
        case .rain:
            buildRain(count: 52, alpha: 0.34, length: 18, speedRange: 460...620)
            rebuildReflections()
            addScreenWash(alpha: 0.07)
        case .heavyRain:
            buildRain(count: 92, alpha: 0.44, length: 24, speedRange: 620...840)
            rebuildReflections()
            addScreenWash(alpha: 0.12)
        case .fog:
            buildFog()
            rebuildReflections()
        case .nightStorm:
            buildRain(count: 78, alpha: 0.42, length: 24, speedRange: 640...880)
            buildFog(alpha: 0.08)
            rebuildReflections()
        }

        if animated {
            weatherNode.alpha = 0
            weatherNode.run(.fadeIn(withDuration: 0.35))
        } else {
            weatherNode.alpha = 1
        }
    }

    private func buildRain(count: Int, alpha: CGFloat, length: CGFloat, speedRange: ClosedRange<CGFloat>) {
        for _ in 0..<count {
            let drop = SKShapeNode(rectOf: CGSize(width: 1.4, height: length), cornerRadius: 0.7)
            drop.fillColor = SKColor.white.withAlphaComponent(alpha)
            drop.strokeColor = .clear
            drop.glowWidth = 2
            drop.zRotation = -0.22
            drop.position = CGPoint(
                x: CGFloat.random(in: 0...max(sceneSize.width, 1)),
                y: CGFloat.random(in: 0...max(sceneSize.height, 1))
            )
            weatherNode.addChild(drop)
            rainDrops.append((drop, CGFloat.random(in: speedRange)))
        }
    }

    private func buildFog(alpha: CGFloat = 0.13) {
        let wash = SKShapeNode(rect: CGRect(origin: .zero, size: sceneSize))
        wash.fillColor = SKColor.white.withAlphaComponent(alpha)
        wash.strokeColor = .clear
        wash.zPosition = 2
        weatherNode.addChild(wash)

        for index in 0..<5 {
            let oval = SKShapeNode(ellipseOf: CGSize(width: sceneSize.width * 0.72, height: 120 + CGFloat(index) * 24))
            oval.fillColor = SKColor.white.withAlphaComponent(alpha * 0.42)
            oval.strokeColor = .clear
            oval.glowWidth = 12
            oval.position = CGPoint(
                x: sceneSize.width * CGFloat(index % 2 == 0 ? 0.32 : 0.68),
                y: sceneSize.height * (0.2 + CGFloat(index) * 0.16)
            )
            oval.zPosition = 3
            weatherNode.addChild(oval)
        }
    }

    private func addScreenWash(alpha: CGFloat) {
        let wash = SKShapeNode(rect: CGRect(origin: .zero, size: sceneSize))
        wash.fillColor = SKColor.white.withAlphaComponent(alpha)
        wash.strokeColor = .clear
        wash.zPosition = 1
        weatherNode.addChild(wash)
    }

    private func rebuildCityGlow() {
        glowNode.removeAllChildren()
        guard sceneSize.width > 0, sceneSize.height > 0 else { return }

        let leftGlow = SKShapeNode(rectOf: CGSize(width: 44, height: sceneSize.height * 1.1))
        leftGlow.fillColor = cityPrimaryGlow.withAlphaComponent(0.18)
        leftGlow.strokeColor = .clear
        leftGlow.glowWidth = 26
        leftGlow.position = CGPoint(x: 14, y: sceneSize.height / 2)
        leftGlow.zPosition = -1
        glowNode.addChild(leftGlow)

        let rightGlow = SKShapeNode(rectOf: CGSize(width: 44, height: sceneSize.height * 1.1))
        rightGlow.fillColor = citySecondaryGlow.withAlphaComponent(0.18)
        rightGlow.strokeColor = .clear
        rightGlow.glowWidth = 26
        rightGlow.position = CGPoint(x: sceneSize.width - 14, y: sceneSize.height / 2)
        rightGlow.zPosition = -1
        glowNode.addChild(rightGlow)
    }

    private func rebuildReflections() {
        reflectionNode.removeAllChildren()
        guard roadFrame.width > 0, sceneSize.height > 0 else { return }

        let reflectionAlpha: CGFloat
        switch currentWeather {
        case .clear:
            reflectionAlpha = 0.035
        case .fog:
            reflectionAlpha = 0.05
        case .rain:
            reflectionAlpha = 0.12
        case .heavyRain, .nightStorm:
            reflectionAlpha = 0.18
        }

        for index in 0..<9 {
            let width = roadFrame.width * CGFloat.random(in: 0.16...0.32)
            let strip = SKShapeNode(rectOf: CGSize(width: width, height: CGFloat.random(in: 2...5)), cornerRadius: 2)
            let color = index % 2 == 0 ? cityPrimaryGlow : citySecondaryGlow
            strip.fillColor = color.withAlphaComponent(reflectionAlpha)
            strip.strokeColor = .clear
            strip.glowWidth = currentWeather == .clear ? 2 : 7
            strip.position = CGPoint(
                x: roadFrame.minX + CGFloat.random(in: 0...roadFrame.width),
                y: CGFloat(index) / 8 * sceneSize.height + CGFloat.random(in: -24...24)
            )
            strip.zPosition = -2
            reflectionNode.addChild(strip)
        }
    }

    private func resetRainPositions() {
        for index in rainDrops.indices {
            rainDrops[index].node.position = CGPoint(
                x: CGFloat.random(in: 0...max(sceneSize.width, 1)),
                y: CGFloat.random(in: 0...max(sceneSize.height, 1))
            )
        }
    }

    private func clamp<T: Comparable>(_ value: T, min lower: T, max upper: T) -> T {
        Swift.max(lower, Swift.min(value, upper))
    }
}
