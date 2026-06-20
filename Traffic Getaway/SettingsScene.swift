import SpriteKit

private enum SettingsOverlay {
    case none
    case resetConfirm
    case message(String)
}

final class SettingsScene: SKScene {
    private let contentNode = SKNode()
    private let overlayNode = SKNode()
    private var isTransitioning = false
    private var overlay: SettingsOverlay = .none
    private var musicSliderFrame = CGRect.zero
    private var sfxSliderFrame = CGRect.zero

    override func didMove(to view: SKView) {
        anchorPoint = .zero
        AudioManager.shared.configure()
        buildSettings()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        buildSettings()
    }

    private func buildSettings() {
        removeAllChildren()
        contentNode.removeAllChildren()
        overlayNode.removeAllChildren()
        overlay = .none
        addChild(contentNode)
        addChild(overlayNode)
        overlayNode.zPosition = 100

        backgroundColor = SKColor(red: 0.014, green: 0.015, blue: 0.045, alpha: 1)
        buildBackground()

        let title = UIHelpers.label("SETTINGS", size: 36, color: SKColor(red: 1, green: 0.82, blue: 0.08, alpha: 1), width: size.width - 32)
        title.position = CGPoint(x: size.width / 2, y: size.height - 70)
        contentNode.addChild(title)

        let panelWidth = min(size.width - 30, 370)
        let panel = UIHelpers.panel(size: CGSize(width: panelWidth, height: min(size.height - 150, 620)), stroke: SKColor.cyan.withAlphaComponent(0.75))
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 12)
        contentNode.addChild(panel)

        let topY = panel.position.y + panel.frame.height / 2 - 54
        addSlider(title: "MUSIC VOLUME", value: AudioManager.shared.musicVolume, y: topY, isMusic: true, width: panelWidth - 70)
        addSlider(title: "SFX VOLUME", value: AudioManager.shared.sfxVolume, y: topY - 62, isMusic: false, width: panelWidth - 70)

        var y = topY - 124
        addToggle(title: "MUSIC", value: AudioManager.shared.isMusicEnabled, name: "settings.music.toggle", y: y)
        y -= 42
        addToggle(title: "SFX", value: AudioManager.shared.isSFXEnabled, name: "settings.sfx.toggle", y: y)
        y -= 42
        addToggle(title: "HAPTICS", value: AudioManager.shared.isHapticsEnabled, name: "settings.haptics.toggle", y: y)
        y -= 42
        addToggle(title: "SCREEN SHAKE", value: SaveManager.shared.data.screenShakeEnabled, name: "settings.shake.toggle", y: y)
        y -= 42
        addToggle(title: "REDUCED FLASHING", value: SaveManager.shared.data.reducedFlashingEnabled, name: "settings.flash.toggle", y: y)
        y -= 42
        addToggle(title: "LARGER HUD", value: SaveManager.shared.data.largerHUDTextEnabled, name: "settings.hudsize.toggle", y: y)
        y -= 42
        addToggle(title: "HIGH CONTRAST HUD", value: SaveManager.shared.data.highContrastHUDEnabled, name: "settings.contrast.toggle", y: y)
        y -= 48
        addControlPreference(y: y, width: panelWidth - 70)

        let bottomY = max(62, panel.position.y - panel.frame.height / 2 + 36)
        let replay = UIHelpers.button(text: "REPLAY ONBOARDING", name: "settings.onboarding", size: CGSize(width: panelWidth - 70, height: 34), fill: SKColor.magenta.withAlphaComponent(0.16), stroke: .magenta)
        replay.position = CGPoint(x: size.width / 2, y: bottomY + 126)
        contentNode.addChild(replay)

        let infoWidth = (panelWidth - 82) / 3
        addSmallButton(text: "CREDITS", name: "settings.credits", x: size.width / 2 - infoWidth - 8, y: bottomY + 82, width: infoWidth)
        addSmallButton(text: "PRIVACY", name: "settings.privacy", x: size.width / 2, y: bottomY + 82, width: infoWidth)
        addSmallButton(text: "SUPPORT", name: "settings.support", x: size.width / 2 + infoWidth + 8, y: bottomY + 82, width: infoWidth)

        let reset = UIHelpers.button(text: "RESET SAVE DATA", name: "settings.reset", size: CGSize(width: panelWidth - 70, height: 34), fill: SKColor.red.withAlphaComponent(0.18), stroke: .red)
        reset.position = CGPoint(x: size.width / 2, y: bottomY + 38)
        contentNode.addChild(reset)

        let back = UIHelpers.button(text: "BACK", name: "settings.back", size: CGSize(width: 124, height: 38), fill: SKColor.white.withAlphaComponent(0.12), stroke: .white)
        back.position = CGPoint(x: size.width / 2, y: 34)
        contentNode.addChild(back)
    }

    private func buildBackground() {
        for index in 0..<18 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            dot.fillColor = (index.isMultiple(of: 2) ? SKColor.cyan : SKColor.magenta).withAlphaComponent(0.24)
            dot.strokeColor = .clear
            dot.glowWidth = 8
            dot.position = CGPoint(x: CGFloat.random(in: 0...max(size.width, 1)), y: CGFloat.random(in: 0...max(size.height, 1)))
            contentNode.addChild(dot)
        }
    }

    private func addSlider(title: String, value: Float, y: CGFloat, isMusic: Bool, width: CGFloat) {
        let label = UIHelpers.bodyLabel(title, size: 12, color: SKColor(white: 0.72, alpha: 1))
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: size.width / 2 - width / 2, y: y + 20)
        contentNode.addChild(label)

        let valueLabel = UIHelpers.bodyLabel("\(Int(round(value * 100)))%", size: 12, color: .white)
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.position = CGPoint(x: size.width / 2 + width / 2, y: y + 20)
        contentNode.addChild(valueLabel)

        let trackWidth = width
        let frame = CGRect(x: size.width / 2 - trackWidth / 2, y: y - 8, width: trackWidth, height: 16)
        if isMusic {
            musicSliderFrame = frame
        } else {
            sfxSliderFrame = frame
        }

        let track = SKShapeNode(rectOf: CGSize(width: trackWidth, height: 8), cornerRadius: 4)
        track.name = isMusic ? "settings.music.slider" : "settings.sfx.slider"
        track.fillColor = SKColor.black.withAlphaComponent(0.45)
        track.strokeColor = SKColor.white.withAlphaComponent(0.14)
        track.position = CGPoint(x: size.width / 2, y: y)
        contentNode.addChild(track)

        let fillWidth = max(8, trackWidth * CGFloat(value))
        let fill = SKShapeNode(rectOf: CGSize(width: fillWidth, height: 8), cornerRadius: 4)
        fill.name = track.name
        fill.fillColor = isMusic ? SKColor.cyan : SKColor.magenta
        fill.strokeColor = .clear
        fill.position = CGPoint(x: frame.minX + fillWidth / 2, y: y)
        contentNode.addChild(fill)

        let knob = SKShapeNode(circleOfRadius: 10)
        knob.name = track.name
        knob.fillColor = .white
        knob.strokeColor = isMusic ? SKColor.cyan : SKColor.magenta
        knob.lineWidth = 2
        knob.position = CGPoint(x: frame.minX + trackWidth * CGFloat(value), y: y)
        contentNode.addChild(knob)
    }

    private func addToggle(title: String, value: Bool, name: String, y: CGFloat) {
        let label = UIHelpers.bodyLabel(title, size: 13, color: SKColor(white: 0.86, alpha: 1))
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: size.width / 2 - 145, y: y)
        contentNode.addChild(label)

        let toggle = UIHelpers.button(
            text: value ? "ON" : "OFF",
            name: name,
            size: CGSize(width: 84, height: 30),
            fill: value ? SKColor.green.withAlphaComponent(0.22) : SKColor.white.withAlphaComponent(0.08),
            stroke: value ? .green : SKColor.white.withAlphaComponent(0.45)
        )
        toggle.position = CGPoint(x: size.width / 2 + 112, y: y)
        contentNode.addChild(toggle)
    }

    private func addControlPreference(y: CGFloat, width: CGFloat) {
        let label = UIHelpers.bodyLabel("CONTROLS", size: 13, color: SKColor(white: 0.86, alpha: 1))
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: size.width / 2 - width / 2, y: y)
        contentNode.addChild(label)

        let value = UIHelpers.button(text: SaveManager.shared.data.controlPreference.displayName, name: "settings.controls.cycle", size: CGSize(width: 152, height: 32), fill: SKColor.cyan.withAlphaComponent(0.14), stroke: .cyan)
        value.position = CGPoint(x: size.width / 2 + width / 2 - 76, y: y)
        contentNode.addChild(value)
    }

    private func addSmallButton(text: String, name: String, x: CGFloat, y: CGFloat, width: CGFloat) {
        let button = UIHelpers.button(text: text, name: name, size: CGSize(width: width, height: 30), fill: SKColor.white.withAlphaComponent(0.1), stroke: SKColor.white.withAlphaComponent(0.55))
        button.position = CGPoint(x: x, y: y)
        contentNode.addChild(button)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        updateSliderIfNeeded(at: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        updateSliderIfNeeded(at: location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              let location = touches.first?.location(in: self) else { return }

        if updateSliderIfNeeded(at: location) {
            return
        }

        guard let name = UIHelpers.nodeName(at: location, in: self) else { return }
        AudioManager.shared.play(.menuClick, volume: 0.72, cooldown: 0.04)

        switch overlay {
        case .resetConfirm:
            handleResetOverlay(name)
            return
        case .message:
            overlay = .none
            overlayNode.removeAllChildren()
            return
        case .none:
            break
        }

        switch name {
        case "settings.back":
            isTransitioning = true
            UIHelpers.present(MainMenuScene(size: size), from: self)
        case "settings.music.toggle":
            AudioManager.shared.toggleMusic()
            buildSettings()
        case "settings.sfx.toggle":
            AudioManager.shared.toggleSFX()
            buildSettings()
        case "settings.haptics.toggle":
            AudioManager.shared.toggleHaptics()
            buildSettings()
        case "settings.shake.toggle":
            SaveManager.shared.setScreenShakeEnabled(!SaveManager.shared.data.screenShakeEnabled)
            buildSettings()
        case "settings.flash.toggle":
            SaveManager.shared.setReducedFlashingEnabled(!SaveManager.shared.data.reducedFlashingEnabled)
            buildSettings()
        case "settings.hudsize.toggle":
            SaveManager.shared.setLargerHUDTextEnabled(!SaveManager.shared.data.largerHUDTextEnabled)
            buildSettings()
        case "settings.contrast.toggle":
            SaveManager.shared.setHighContrastHUDEnabled(!SaveManager.shared.data.highContrastHUDEnabled)
            buildSettings()
        case "settings.controls.cycle":
            SaveManager.shared.setControlPreference(SaveManager.shared.data.controlPreference.next)
            buildSettings()
        case "settings.onboarding":
            isTransitioning = true
            UIHelpers.present(OnboardingScene(size: size), from: self)
        case "settings.reset":
            showResetConfirmation()
        case "settings.credits":
            showMessage("Created with SpriteKit shapes, procedural audio, and no external assets.")
        case "settings.privacy":
            showMessage("No personal data leaves this build. Diagnostic events stay local in debug builds; ads and online services are disabled.")
        case "settings.support":
            showMessage("For TestFlight feedback, send crashes, device model, and what happened before the issue.")
        default:
            break
        }
    }

    @discardableResult
    private func updateSliderIfNeeded(at location: CGPoint) -> Bool {
        if musicSliderFrame.insetBy(dx: -8, dy: -10).contains(location) {
            let progress = Float((location.x - musicSliderFrame.minX) / max(1, musicSliderFrame.width))
            AudioManager.shared.setMusicVolume(progress)
            buildSettings()
            return true
        }

        if sfxSliderFrame.insetBy(dx: -8, dy: -10).contains(location) {
            let progress = Float((location.x - sfxSliderFrame.minX) / max(1, sfxSliderFrame.width))
            AudioManager.shared.setSFXVolume(progress)
            buildSettings()
            return true
        }

        return false
    }

    private func showResetConfirmation() {
        overlay = .resetConfirm
        overlayNode.removeAllChildren()
        addDimmer()
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 44, 320), height: 182), stroke: .red)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.addChild(panel)

        let title = UIHelpers.label("RESET SAVE?", size: 25, color: .red)
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 48)
        overlayNode.addChild(title)

        let body = UIHelpers.bodyLabel("This clears cash, cars, missions, achievements, and settings.", size: 12, color: .white, width: panel.frame.width - 32)
        body.position = CGPoint(x: size.width / 2, y: size.height / 2 + 12)
        overlayNode.addChild(body)

        let cancel = UIHelpers.button(text: "CANCEL", name: "settings.reset.cancel", size: CGSize(width: 104, height: 34), fill: SKColor.white.withAlphaComponent(0.1), stroke: .white)
        cancel.position = CGPoint(x: size.width / 2 - 64, y: size.height / 2 - 48)
        overlayNode.addChild(cancel)

        let confirm = UIHelpers.button(text: "RESET", name: "settings.reset.confirm", size: CGSize(width: 104, height: 34), fill: SKColor.red.withAlphaComponent(0.22), stroke: .red)
        confirm.position = CGPoint(x: size.width / 2 + 64, y: size.height / 2 - 48)
        overlayNode.addChild(confirm)
    }

    private func handleResetOverlay(_ name: String) {
        switch name {
        case "settings.reset.cancel":
            overlay = .none
            overlayNode.removeAllChildren()
        case "settings.reset.confirm":
            SaveManager.shared.resetSaveData()
            AudioManager.shared.setMusicVolume(0.72)
            AudioManager.shared.setSFXVolume(0.82)
            AudioManager.shared.setMusicEnabled(true)
            AudioManager.shared.setSFXEnabled(true)
            AudioManager.shared.setHapticsEnabled(true)
            buildSettings()
            showMessage("Save data reset.")
        default:
            break
        }
    }

    private func showMessage(_ text: String) {
        overlay = .message(text)
        overlayNode.removeAllChildren()
        addDimmer()
        let panel = UIHelpers.panel(size: CGSize(width: min(size.width - 44, 330), height: 160), stroke: .cyan)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlayNode.addChild(panel)

        let label = UIHelpers.bodyLabel(text, size: 14, color: .white, width: panel.frame.width - 34)
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 + 18)
        overlayNode.addChild(label)

        let ok = UIHelpers.button(text: "OK", name: "settings.message.ok", size: CGSize(width: 96, height: 34), fill: SKColor.cyan.withAlphaComponent(0.18), stroke: .cyan)
        ok.position = CGPoint(x: size.width / 2, y: size.height / 2 - 48)
        overlayNode.addChild(ok)
    }

    private func addDimmer() {
        let dimmer = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dimmer.fillColor = SKColor.black.withAlphaComponent(0.78)
        dimmer.strokeColor = .clear
        overlayNode.addChild(dimmer)
    }
}
