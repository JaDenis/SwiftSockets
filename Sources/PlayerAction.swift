import Foundation

/// Possible set of moves a player can choose from.
enum PlayerAction {
    case block
    case charge
    case shoot
    case steal

    static func decode(fromStr str: String) -> PlayerAction? {
        switch str {
        case "block": return .block
        case "charge": return .charge
        case "shoot": return .shoot
        case "steal": return .steal
        default: return nil
        }
    }
}
