import Foundation

/// Possible set of moves a player can choose from.
enum PlayerAction {
    case block
    case charge
    case shoot
    case steal
    case reflect

    static func decode(fromStr str: String) -> PlayerAction? {
        switch str {
        case "Block": return .block
        case "Charge": return .charge
        case "Shoot": return .shoot
        case "Steal": return .steal
        case "Reflect": return .reflect
        default: return nil
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

    static func encode(_ action: PlayerAction) -> String {
        switch action {
        case .block: return "\"Block\""
        case .charge: return "\"Charge\""
        case .shoot: return "\"Shoot\""
        case .steal: return "\"Steal\""
        case .reflect: return "\"Reflect\""
        }
    }

}
