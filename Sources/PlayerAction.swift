import Foundation

/// Possible set of moves a player can choose from.
enum PlayerAction {
    case block
    case charge
    case shoot
    case steal

    static func decode(fromStr str: String) -> PlayerAction? {
        switch str {
        case "Block": return .block
        case "Charge": return .charge
        case "Shoot": return .shoot
        case "Steal": return .steal
        default: return nil
        }
    }
}
