import SpriteKit

enum UITheme {
    enum Color {
        static let background = ArcadeArt.Palette.navy
        static let panel = ArcadeArt.Palette.navyPanel
        static let panelDeep = ArcadeArt.Palette.navyPanelDeep
        static let text = ArcadeArt.Palette.cream
        static let secondaryText = ArcadeArt.Palette.mutedCream
        static let mutedText = SKColor(red: 0.55, green: 0.52, blue: 0.43, alpha: 1)
        static let gold = ArcadeArt.Palette.gold
        static let cyan = SKColor(red: 0.2, green: 0.72, blue: 0.9, alpha: 1)
        static let magenta = SKColor(red: 0.88, green: 0.28, blue: 0.38, alpha: 1)
        static let red = ArcadeArt.Palette.red
        static let green = ArcadeArt.Palette.green
        static let orange = ArcadeArt.Palette.orange
    }

    enum Font {
        static let title = "AvenirNext-Heavy"
        static let body = "AvenirNext-DemiBold"
        static let titleSize: CGFloat = 38
        static let sectionTitleSize: CGFloat = 27
        static let buttonSize: CGFloat = 17
        static let bodySize: CGFloat = 13
        static let captionSize: CGFloat = 11
    }

    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 36
    }

    enum Radius {
        static let button: CGFloat = 6
        static let panel: CGFloat = 8
        static let card: CGFloat = 8
    }

    enum Animation {
        static let tapDown: TimeInterval = 0.055
        static let tapUp: TimeInterval = 0.12
        static let quick: TimeInterval = 0.18
        static let standard: TimeInterval = 0.28
        static let slow: TimeInterval = 0.55
    }

    enum ButtonStyle {
        case primary
        case secondary
        case danger
        case gold
        case ghost

        var fill: SKColor {
            switch self {
            case .primary:
                return UITheme.Color.orange.withAlphaComponent(0.34)
            case .secondary:
                return UITheme.Color.panelDeep.withAlphaComponent(0.92)
            case .danger:
                return UITheme.Color.red.withAlphaComponent(0.2)
            case .gold:
                return UITheme.Color.gold.withAlphaComponent(0.2)
            case .ghost:
                return SKColor.white.withAlphaComponent(0.1)
            }
        }

        var stroke: SKColor {
            switch self {
            case .primary:
                return UITheme.Color.orange
            case .danger:
                return UITheme.Color.red
            case .secondary:
                return UITheme.Color.gold.withAlphaComponent(0.82)
            case .gold:
                return UITheme.Color.gold
            case .ghost:
                return SKColor.white.withAlphaComponent(0.72)
            }
        }
    }
}
