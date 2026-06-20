import SpriteKit

final class StoreScene: SKScene {
    private let contentNode = SKNode()
    private let overlayNode = SKNode()
    private var isTransitioning = false
    private var isPurchasing = false

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        AudioManager.shared.configure()
        buildStore()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildStore()
    }

    private func buildStore() {
        removeAllChildren()
        contentNode.removeAllChildren()
        overlayNode.removeAllChildren()
        addChild(contentNode)
        addChild(overlayNode)
        overlayNode.zPosition = 100

        backgroundColor = SKColor(red: 0.015, green: 0.012, blue: 0.045, alpha: 1)
        buildBackground()

        let title = UIHelpers.label("STORE", size: 38, color: SKColor(red: 1, green: 0.82, blue: 0.08, alpha: 1), width: size.width - 32)
        title.position = CGPoint(x: size.width / 2, y: size.height - 72)
        contentNode.addChild(title)

        let cash = UIHelpers.bodyLabel("$\(SaveManager.shared.data.totalCash)", size: 18, color: SKColor(red: 1, green: 0.84, blue: 0.2, alpha: 1))
        cash.position = CGPoint(x: size.width / 2, y: size.height - 108)
        contentNode.addChild(cash)

        let panelWidth = min(size.width - 30, 370)
        let topY = size.height - 168
        for (index, product) in MonetizationManager.ProductID.allCases.enumerated() {
            addProductCard(product, y: topY - CGFloat(index) * 96, width: panelWidth)
        }

        let restore = UIHelpers.button(text: "RESTORE PURCHASES", name: "store.restore", size: CGSize(width: min(size.width - 70, 260), height: 34), fill: SKColor.white.withAlphaComponent(0.1), stroke: SKColor.white.withAlphaComponent(0.65))
        restore.position = CGPoint(x: size.width / 2, y: 86)
        contentNode.addChild(restore)

        let back = UIHelpers.button(text: "BACK", name: "store.back", size: CGSize(width: 124, height: 38), fill: SKColor.white.withAlphaComponent(0.12), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: 38)
        contentNode.addChild(back)
    }

    private func buildBackground() {
        for index in 0..<20 {
            let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 70...160)), cornerRadius: 2)
            line.fillColor = (index.isMultiple(of: 2) ? SKColor.cyan : SKColor(red: 1, green: 0.12, blue: 0.66, alpha: 1)).withAlphaComponent(0.14)
            line.strokeColor = .clear
            line.glowWidth = 6
            line.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(line)
        }
    }

    private func addProductCard(_ product: MonetizationManager.ProductID, y: CGFloat, width: CGFloat) {
        let owned = product == .removeAds && MonetizationManager.shared.isRemoveAdsOwned()
        let card = UIHelpers.panel(size: CGSize(width: width, height: 82), fill: SKColor.black.withAlphaComponent(0.32), stroke: owned ? .green : SKColor.cyan.withAlphaComponent(0.75))
        card.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(card)

        let title = UIHelpers.label(product.displayName, size: 16, color: owned ? .green : .white, width: width - 132)
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: card.position.x - width / 2 + 16, y: y + 22)
        contentNode.addChild(title)

        let desc = UIHelpers.bodyLabel(product.description, size: 11, color: SKColor(white: 0.76, alpha: 1), width: width - 132)
        desc.horizontalAlignmentMode = .left
        desc.position = CGPoint(x: card.position.x - width / 2 + 16, y: y - 1)
        contentNode.addChild(desc)

        let valueText: String
        if owned {
            valueText = "OWNED"
        } else if product == .removeAds {
            valueText = "GET"
        } else {
            valueText = "+$\(product.simulatedCash)"
        }

        let button = UIHelpers.button(
            text: valueText,
            name: owned ? "store.noop" : "store.buy.\(product.rawValue)",
            size: CGSize(width: 92, height: 36),
            fill: owned ? SKColor.green.withAlphaComponent(0.16) : SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 0.18),
            stroke: owned ? .green : SKColor(red: 1, green: 0.84, blue: 0.16, alpha: 1)
        )
        button.position = CGPoint(x: card.position.x + width / 2 - 58, y: y)
        contentNode.addChild(button)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, !isPurchasing,
              let location = touches.first?.location(in: self),
              let name = UIHelpers.nodeName(at: location, in: self) else { return }

        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "store.back":
            isTransitioning = true
            UIHelpers.present(MainMenuScene(size: size), from: self)
        case "store.restore":
            restorePurchases()
        default:
            if name.hasPrefix("store.buy.") {
                let raw = String(name.dropFirst("store.buy.".count))
                if let product = MonetizationManager.ProductID(rawValue: raw) {
                    purchase(product)
                }
            } else {
                overlayNode.removeAllChildren()
            }
        }
    }

    private func purchase(_ product: MonetizationManager.ProductID) {
        isPurchasing = true
        showMessage(product == .removeAds ? "Applying test entitlement..." : "Applying test reward...")
        MonetizationManager.shared.purchase(productID: product) { [weak self] result in
            guard let self else { return }
            self.isPurchasing = false
            switch result {
            case .success:
                self.showMessage(product == .removeAds ? "Test entitlement applied." : "Test reward applied.")
                self.run(.wait(forDuration: 0.55)) { [weak self] in
                    self?.buildStore()
                }
            case .alreadyOwned:
                self.showMessage("Already owned.")
            case .unavailable:
                self.showMessage("Test rewards are unavailable in this build.")
            }
        }
    }

    private func restorePurchases() {
        isPurchasing = true
        showMessage("Checking saved entitlement...")
        MonetizationManager.shared.restorePurchases { [weak self] restored in
            guard let self else { return }
            self.isPurchasing = false
            self.showMessage(restored ? "Entitlement restored." : "No entitlement found.")
        }
    }

    private func showMessage(_ text: String) {
        overlayNode.removeAllChildren()
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 54, 300), height: 104), stroke: .cyan)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.addChild(panel)

        let label = UIHelpers.bodyLabel(text, size: 15, color: .white, width: panel.frame.width - 28)
        label.position = panel.position
        overlayNode.addChild(label)

        panel.setScale(0.9)
        panel.run(.scale(to: 1, duration: 0.12))
    }
}
