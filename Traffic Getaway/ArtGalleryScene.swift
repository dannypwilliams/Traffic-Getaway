import SpriteKit
import UIKit

final class ArtGalleryScene: SKScene {
    private let contentNode = SKNode()
    private var pageIndex = 0
    private var isTransitioning = false
    private let playablePageSize = 8

    private var playablePageCount: Int {
        max(1, Int(ceil(Double(CarCatalog.cars.count) / Double(playablePageSize))))
    }

    private var totalPageCount: Int {
        playablePageCount + 5
    }

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        AudioManager.shared.configure()
        buildGallery()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildGallery()
    }

    private func buildGallery() {
        removeAllChildren()
        contentNode.removeAllChildren()
        addChild(contentNode)
        backgroundColor = UITheme.Color.background
        pageIndex = max(0, min(pageIndex, totalPageCount - 1))

        buildHeader()
        buildCurrentPage()
        buildFooter()
    }

    private func buildHeader() {
        let title = UIHelpers.label("ART GALLERY", size: 31, color: UITheme.Color.gold, width: size.width - 32)
        title.position = CGPoint(x: size.width / 2, y: size.height - 54)
        contentNode.addChild(title)

        let subtitle = UIHelpers.bodyLabel(ArcadeArt.systemName, size: 12, color: UITheme.Color.secondaryText, width: size.width - 40)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 82)
        contentNode.addChild(subtitle)

        let rule = SKShapeNode(rectOf: CGSize(width: min(size.width - 42, 330), height: 3), cornerRadius: 1)
        rule.fillColor = UITheme.Color.orange
        rule.strokeColor = .clear
        rule.position = CGPoint(x: size.width / 2, y: size.height - 104)
        contentNode.addChild(rule)
    }

    private func buildCurrentPage() {
        let topY = size.height - 142
        if pageIndex < playablePageCount {
            let start = pageIndex * playablePageSize
            let cars = Array(CarCatalog.cars.dropFirst(start).prefix(playablePageSize))
            addSectionTitle("PLAYABLE VEHICLES \(pageIndex + 1)/\(playablePageCount)", y: topY)
            addPlayableGrid(cars: cars, topY: topY - 52)
            return
        }

        switch pageIndex - playablePageCount {
        case 0:
            addSectionTitle("WORLD THEMES", y: topY)
            addWorldGrid(topY: topY - 50)
        case 1:
            addSectionTitle("TRAFFIC AND POLICE", y: topY)
            addTrafficGrid(topY: topY - 48)
        case 2:
            addSectionTitle("ROAD AND PROPS", y: topY)
            addRoadAndProps(topY: topY - 44)
        case 3:
            addSectionTitle("EFFECTS", y: topY)
            addEffectsGrid(topY: topY - 52)
        default:
            addSectionTitle("UI AND FALLBACKS", y: topY)
            addUIAndFallbacks(topY: topY - 56)
        }
    }

    private func addSectionTitle(_ text: String, y: CGFloat) {
        let label = UIHelpers.label(text, size: 20, color: UITheme.Color.text, width: size.width - 36)
        label.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(label)
    }

    private func addPlayableGrid(cars: [CarDefinition], topY: CGFloat) {
        let columns = 4
        let cardWidth = min((size.width - 38) / CGFloat(columns), 88)
        let rowHeight: CGFloat = 154
        let startX = size.width / 2 - cardWidth * CGFloat(columns - 1) / 2

        for (index, car) in cars.enumerated() {
            let column = index % columns
            let row = index / columns
            let x = startX + CGFloat(column) * cardWidth
            let y = topY - CGFloat(row) * rowHeight
            addGalleryCard(at: CGPoint(x: x, y: y), size: CGSize(width: cardWidth - 8, height: 136), stroke: car.rarity.color.withAlphaComponent(0.72))

            let preview = VehicleRenderer.garagePreview(car: car, paint: CarCatalog.defaultPaint, size: CGSize(width: 42, height: 74))
            preview.position = CGPoint(x: x, y: y + 18)
            preview.setScale(car.vehicleClass == .motorcycle ? 0.88 : 0.76)
            contentNode.addChild(preview)

            let label = UIHelpers.bodyLabel(car.displayName.uppercased(), size: 8.5, color: UITheme.Color.secondaryText, width: cardWidth - 14)
            label.position = CGPoint(x: x, y: y - 50)
            contentNode.addChild(label)
        }
    }

    private func addTrafficGrid(topY: CGFloat) {
        let types = VehicleType.allCases
        let columns = 4
        let cardWidth = min((size.width - 38) / CGFloat(columns), 88)
        let rowHeight: CGFloat = 128
        let startX = size.width / 2 - cardWidth * CGFloat(columns - 1) / 2

        for (index, type) in types.enumerated() {
            let column = index % columns
            let row = index / columns
            let x = startX + CGFloat(column) * cardWidth
            let y = topY - CGFloat(row) * rowHeight
            addGalleryCard(at: CGPoint(x: x, y: y), size: CGSize(width: cardWidth - 8, height: 112), stroke: UITheme.Color.gold.withAlphaComponent(0.58))

            let spec = ArcadeArt.trafficSpec(for: type, laneWidth: 33, world: WorldThemeCatalog.defaultTheme)
            let vehicle = ArcadeArt.makeVehicleSprite(spec: spec)
            vehicle.position = CGPoint(x: x, y: y + 12)
            vehicle.setScale(type == .boxTruck ? 0.58 : 0.72)
            contentNode.addChild(vehicle)

            let label = UIHelpers.bodyLabel(ArcadeArt.assetID(for: type).displayName.uppercased(), size: 8.5, color: UITheme.Color.secondaryText, width: cardWidth - 12)
            label.position = CGPoint(x: x, y: y - 42)
            contentNode.addChild(label)
        }
    }

    private func addWorldGrid(topY: CGFloat) {
        let themes = WorldThemeCatalog.all
        let columns = 2
        let cardWidth = min((size.width - 46) / CGFloat(columns), 156)
        let rowHeight: CGFloat = 112
        let startX = size.width / 2 - cardWidth * CGFloat(columns - 1) / 2

        for (index, theme) in themes.enumerated() {
            let column = index % columns
            let row = index / columns
            let x = startX + CGFloat(column) * cardWidth
            let y = topY - CGFloat(row) * rowHeight
            addGalleryCard(at: CGPoint(x: x, y: y), size: CGSize(width: cardWidth - 10, height: 96), stroke: theme.palette.accent.withAlphaComponent(0.7))

            let road = ArcadeArt.makeRoadSample(size: CGSize(width: cardWidth - 34, height: 60), theme: theme)
            road.setScale(0.72)
            road.position = CGPoint(x: x, y: y + 16)
            contentNode.addChild(road)

            addSmallLabel(theme.worldSelectTitle, at: CGPoint(x: x, y: y - 30), width: cardWidth - 16)
            addSmallLabel(theme.shortName.uppercased(), at: CGPoint(x: x, y: y - 46), width: cardWidth - 16)
        }
    }

    private func addRoadAndProps(topY: CGFloat) {
        let road = ArcadeArt.makeRoadSample(size: CGSize(width: min(size.width - 70, 280), height: 190))
        road.position = CGPoint(x: size.width / 2, y: topY - 42)
        contentNode.addChild(road)

        let roadLabel = UIHelpers.bodyLabel("FREEWAY SLAB  LANE DASH  SHOULDERS", size: 10, color: UITheme.Color.secondaryText, width: size.width - 48)
        roadLabel.position = CGPoint(x: size.width / 2, y: topY - 152)
        contentNode.addChild(roadLabel)

        let palm = ArcadeArt.makePalmProp(height: 74)
        palm.position = CGPoint(x: size.width * 0.32, y: topY - 236)
        contentNode.addChild(palm)
        let sign = ArcadeArt.makeFreewaySign(size: CGSize(width: 76, height: 72))
        sign.position = CGPoint(x: size.width * 0.68, y: topY - 236)
        contentNode.addChild(sign)

        addSmallLabel("PALM PROP", at: CGPoint(x: size.width * 0.32, y: topY - 292))
        addSmallLabel("FREEWAY SIGN", at: CGPoint(x: size.width * 0.68, y: topY - 292))
    }

    private func addEffectsGrid(topY: CGFloat) {
        let effects = ArcadeArt.EffectAsset.allCases
        let columns = 3
        let cardWidth = min((size.width - 42) / CGFloat(columns), 104)
        let rowHeight: CGFloat = 126
        let startX = size.width / 2 - cardWidth * CGFloat(columns - 1) / 2

        for (index, effect) in effects.enumerated() {
            let column = index % columns
            let row = index / columns
            let x = startX + CGFloat(column) * cardWidth
            let y = topY - CGFloat(row) * rowHeight
            addGalleryCard(at: CGPoint(x: x, y: y), size: CGSize(width: cardWidth - 10, height: 104), stroke: UITheme.Color.orange.withAlphaComponent(0.62))

            let preview = ArcadeArt.makeEffectSample(effect, size: CGSize(width: 80, height: 84))
            preview.position = CGPoint(x: x, y: y + 12)
            contentNode.addChild(preview)
            addSmallLabel(effect.displayName.uppercased(), at: CGPoint(x: x, y: y - 40), width: cardWidth - 14)
        }
    }

    private func addUIAndFallbacks(topY: CGFloat) {
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 64, 260), height: 96), stroke: UITheme.Color.gold.withAlphaComponent(0.78))
        panel.position = CGPoint(x: size.width / 2, y: topY - 12)
        contentNode.addChild(panel)

        let primary = UIHelpers.button(text: "PRIMARY", name: "gallery.sample.primary", size: CGSize(width: 118, height: 36), style: .primary)
        primary.position = CGPoint(x: size.width / 2 - 68, y: topY - 16)
        contentNode.addChild(primary)

        let secondary = UIHelpers.button(text: "GHOST", name: "gallery.sample.ghost", size: CGSize(width: 92, height: 32), style: .ghost)
        secondary.position = CGPoint(x: size.width / 2 + 72, y: topY - 16)
        contentNode.addChild(secondary)

        addSmallLabel("NAVY PANEL  CREAM TYPE  GOLD LINES", at: CGPoint(x: size.width / 2, y: topY - 82), width: size.width - 64)

        let fallback = ArcadeArt.FallbackPolicy.node(assetID: "missing.asset.sunlit_fallback", size: CGSize(width: 120, height: 84))
        fallback.position = CGPoint(x: size.width / 2, y: topY - 178)
        contentNode.addChild(fallback)
        addSmallLabel("STYLED FALLBACK TILE", at: CGPoint(x: size.width / 2, y: topY - 244), width: size.width - 64)
    }

    private func addGalleryCard(at point: CGPoint, size: CGSize, stroke: SKColor) {
        let card = UIHelpers.panel(size: size, fill: UITheme.Color.panelDeep.withAlphaComponent(0.82), stroke: stroke)
        card.position = point
        contentNode.addChild(card)
    }

    private func addSmallLabel(_ text: String, at point: CGPoint, width: CGFloat = 94) {
        let label = UIHelpers.bodyLabel(text, size: 9, color: UITheme.Color.secondaryText, width: width)
        label.position = point
        contentNode.addChild(label)
    }

    private func buildFooter() {
        let y: CGFloat = 38
        let back = UIHelpers.button(text: "BACK", name: "gallery.back", size: CGSize(width: 92, height: 34), style: .ghost)
        back.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(back)

        let prev = UIHelpers.button(text: "PREV", name: "gallery.prev", size: CGSize(width: 76, height: 32), style: .secondary)
        prev.position = CGPoint(x: size.width / 2 - 104, y: y)
        contentNode.addChild(prev)

        let next = UIHelpers.button(text: "NEXT", name: "gallery.next", size: CGSize(width: 76, height: 32), style: .secondary)
        next.position = CGPoint(x: size.width / 2 + 104, y: y)
        contentNode.addChild(next)

        let page = UIHelpers.bodyLabel("\(pageIndex + 1) / \(totalPageCount)", size: 11, color: UITheme.Color.secondaryText)
        page.position = CGPoint(x: size.width / 2, y: y + 35)
        contentNode.addChild(page)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let location = touches.first?.location(in: self),
              let name = UIHelpers.nodeName(at: location, in: self) else { return }

        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch name {
        case "gallery.back":
            isTransitioning = true
            UIHelpers.present(DebugBalanceScene(size: size), from: self)
        case "gallery.prev":
            pageIndex = (pageIndex - 1 + totalPageCount) % totalPageCount
            buildGallery()
        case "gallery.next":
            pageIndex = (pageIndex + 1) % totalPageCount
            buildGallery()
        default:
            break
        }
    }
}
