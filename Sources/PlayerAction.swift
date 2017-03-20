import Foundation

/// Possible set of moves a player can choose from.
enum PlayerAction {
    case block
    case charge
    case shoot
    case steal
    case reflect
}

// MARK: - JSON Processing

extension PlayerAction {
    static func decode(fromStr str: String) -> PlayerAction? {
        switch str {
        case Strings.PlayerAction.blockKey: return .block
        case Strings.PlayerAction.chargeKey: return .charge
        case Strings.PlayerAction.shootKey: return .shoot
        case Strings.PlayerAction.stealKey: return .steal
        case Strings.PlayerAction.reflectKey: return .reflect
        default: return nil
        }
    }

    static func encode(_ action: PlayerAction) -> String {
        switch action {
        case .block: return Strings.PlayerAction.Encode.blockKey
        case .charge: return Strings.PlayerAction.Encode.chargeKey
        case .shoot: return Strings.PlayerAction.Encode.shootKey
        case .steal: return Strings.PlayerAction.Encode.stealKey
        case .reflect: return Strings.PlayerAction.Encode.reflectKey
        }
    }

    static func encode(_ actions: [PlayerAction]) -> String {
        var str = "["
        for action in actions {
            str = str + PlayerAction.encode(action) + ","
        }
        str = String(str.characters.dropLast())
        str = str + "]"
        return str
    }
}

// MARK: - PlayerAction Strings

extension Strings {
    struct PlayerAction {
        static let blockKey = "Block"
        static let chargeKey = "Charge"
        static let shootKey = "Shoot"
        static let stealKey = "Steal"
        static let reflectKey = "Reflect"

        struct Encode {
            static let blockKey = "\"Block\""
            static let chargeKey = "\"Charge\""
            static let shootKey = "\"Shoot\""
            static let stealKey = "\"Steal\""
            static let reflectKey = "\"Reflect\""
        }
    }
}
