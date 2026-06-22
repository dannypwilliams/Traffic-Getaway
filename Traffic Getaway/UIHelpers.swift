import SpriteKit

enum UIHelpers {
    static let titleFont = UITheme.Font.title
    static let bodyFont = UITheme.Font.body

    static func label(_ text: String, size: CGFloat, color: SKColor = .white, width: CGFloat? = nil) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: titleFont)
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        if let width {
            fit(label, maxWidth: width)
        }
        return label
    }

    static func bodyLabel(_ text: String, size: CGFloat, color: SKColor = SKColor(white: 0.85, alpha: 1), width: CGFloat? = nil) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: bodyFont)
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        if let width {
            fit(label, maxWidth: width)
        }
        return label
    }

    static func button(text: String, name: String, size: CGSize, fill: SKColor, stroke: SKColor) -> SKNode {
        let node = SKNode()
        node.name = name

        let shadow = SKShapeNode(rectOf: size, cornerRadius: UITheme.Radius.button)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.28)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -3)
        shadow.zPosition = -2
        node.addChild(shadow)

        let backing = SKShapeNode(rectOf: size, cornerRadius: UITheme.Radius.button)
        backing.name = name
        backing.fillColor = fill
        backing.strokeColor = stroke
        backing.lineWidth = 2
        backing.glowWidth = 4
        backing.zPosition = -1
        node.addChild(backing)

        let label = UIHelpers.label(text, size: min(20, size.height * 0.42), color: UITheme.Color.text, width: size.width - 12)
        label.name = name
        node.addChild(label)
        return node
    }

    static func button(text: String, name: String, size: CGSize, style: UITheme.ButtonStyle) -> SKNode {
        button(text: text, name: name, size: size, fill: style.fill, stroke: style.stroke)
    }

    static func panel(size: CGSize, fill: SKColor = UITheme.Color.panel, stroke: SKColor = UITheme.Color.cyan.withAlphaComponent(0.7)) -> SKShapeNode {
        let panel = SKShapeNode(rectOf: size, cornerRadius: UITheme.Radius.panel)
        panel.fillColor = fill
        panel.strokeColor = stroke
        panel.lineWidth = 2
        panel.glowWidth = 3
        return panel
    }

    static func progressBar(width: CGFloat, height: CGFloat, progress: CGFloat, fill: SKColor, back: SKColor = SKColor.black.withAlphaComponent(0.45)) -> SKNode {
        let node = SKNode()
        let clamped = max(0, min(1, progress))

        let background = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2)
        background.fillColor = back
        background.strokeColor = SKColor.white.withAlphaComponent(0.12)
        background.lineWidth = 1
        node.addChild(background)

        let barWidth = max(height, width * clamped)
        let foreground = SKShapeNode(rectOf: CGSize(width: barWidth, height: height), cornerRadius: height / 2)
        foreground.fillColor = fill
        foreground.strokeColor = .clear
        foreground.position = CGPoint(x: -width / 2 + barWidth / 2, y: 0)
        node.addChild(foreground)
        return node
    }

    static func nodeName(at location: CGPoint, in scene: SKScene) -> String? {
        for node in scene.nodes(at: location) {
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

    static func present(_ scene: SKScene, from current: SKScene, transition: SKTransition = .fade(withDuration: 0.24)) {
        scene.scaleMode = .resizeFill
        current.removeAllActions()
        current.view?.presentScene(scene, transition: transition)
    }

    static func topSafeY(in scene: SKScene, padding: CGFloat) -> CGFloat {
        let safeTop = scene.view?.safeAreaInsets.top ?? 0
        return scene.size.height - max(padding, safeTop + 30)
    }

    static func animatePress(_ node: SKNode?) {
        guard let node else { return }
        node.removeAction(forKey: "uiPress")
        let down = SKAction.scale(to: 0.94, duration: UITheme.Animation.tapDown)
        let up = SKAction.scale(to: 1, duration: UITheme.Animation.tapUp)
        up.timingMode = .easeOut
        node.run(.sequence([down, up]), withKey: "uiPress")
    }

    static func entrance(_ node: SKNode, delay: TimeInterval = 0, offsetY: CGFloat = -10) {
        let finalPosition = node.position
        node.alpha = 0
        node.position = CGPoint(x: finalPosition.x, y: finalPosition.y + offsetY)
        node.run(.sequence([
            .wait(forDuration: delay),
            .group([
                .fadeIn(withDuration: UITheme.Animation.standard),
                .move(to: finalPosition, duration: UITheme.Animation.standard)
            ])
        ]))
    }

    static func pulse(_ node: SKNode, scale: CGFloat = 1.04, duration: TimeInterval = 0.8) {
        node.run(.repeatForever(.sequence([
            .scale(to: scale, duration: duration),
            .scale(to: 1, duration: duration)
        ])))
    }

    static func fit(_ label: SKLabelNode, maxWidth: CGFloat) {
        while label.frame.width > maxWidth && label.fontSize > 9 {
            label.fontSize -= 1
        }
    }

    static func selectedCarPreview(size: CGSize = CGSize(width: 86, height: 142)) -> SKNode {
        let save = SaveManager.shared.data
        return carPreview(car: CarCatalog.car(id: save.selectedCarID), paint: CarCatalog.paint(id: save.selectedPaintID), size: size)
    }

    static func carPreview(car: CarDefinition, paint: PaintDefinition, size: CGSize) -> SKNode {
        VehicleRenderer.garagePreview(car: car, paint: paint, size: size)
    }

    private static func bodyPath(size: CGSize, style: VehicleShapeStyle) -> CGPath {
        let frontInset: CGFloat
        let rearInset: CGFloat
        switch style {
        case .bullet, .speeder, .racer, .roadster:
            frontInset = 0.25
            rearInset = 0.16
        case .van, .retro:
            frontInset = 0.06
            rearInset = 0.04
        case .muscle, .interceptor, .desert:
            frontInset = 0.12
            rearInset = 0.06
        default:
            frontInset = 0.18
            rearInset = 0.08
        }

        let frontHalf = size.width * (0.5 - frontInset)
        let rearHalf = size.width * (0.5 - rearInset)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -frontHalf, y: size.height / 2))
        path.addLine(to: CGPoint(x: frontHalf, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.18))
        path.addLine(to: CGPoint(x: rearHalf, y: -size.height / 2))
        path.addLine(to: CGPoint(x: -rearHalf, y: -size.height / 2))
        path.addLine(to: CGPoint(x: -size.width * 0.5, y: size.height * 0.18))
        path.closeSubpath()
        return path
    }
}
