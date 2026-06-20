import SpriteKit

enum UITheme {
    enum Color {
        static let background = SKColor(red: 0.012, green: 0.014, blue: 0.045, alpha: 1)
        static let panel = SKColor(red: 0.024, green: 0.026, blue: 0.075, alpha: 0.94)
        static let panelDeep = SKColor(red: 0.012, green: 0.014, blue: 0.04, alpha: 0.96)
        static let text = SKColor.white
        static let secondaryText = SKColor(white: 0.78, alpha: 1)
        static let mutedText = SKColor(white: 0.58, alpha: 1)
        static let gold = SKColor(red: 1, green: 0.82, blue: 0.08, alpha: 1)
        static let cyan = SKColor(red: 0, green: 0.86, blue: 1, alpha: 1)
        static let magenta = SKColor(red: 1, green: 0.12, blue: 0.66, alpha: 1)
        static let red = SKColor(red: 1, green: 0.18, blue: 0.2, alpha: 1)
        static let green = SKColor(red: 0.35, green: 1, blue: 0.42, alpha: 1)
        static let orange = SKColor(red: 1, green: 0.45, blue: 0.16, alpha: 1)
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
        static let button: CGFloat = 8
        static let panel: CGFloat = 10
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
                return UITheme.Color.red.withAlphaComponent(0.3)
            case .secondary:
                return UITheme.Color.cyan.withAlphaComponent(0.18)
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
            case .primary, .danger:
                return UITheme.Color.red
            case .secondary:
                return UITheme.Color.cyan
            case .gold:
                return UITheme.Color.gold
            case .ghost:
                return SKColor.white.withAlphaComponent(0.72)
            }
        }
    }
}
