import Foundation

/// Player is a reference type with value semantics.
class Player {
    /// What is the player's name?
    let name: String

    /// Cumulative history of moves.
    let moveHistory: [PlayerAction]

    /// Convenience variable to calculate player charges.
    var charges: Int {
        // Placeholder.
        return 1
    }

    /// Convenience initializer for a new player.
    convenience init(name: String) {
        self.init(name: name, moveHistory: [])
    }

    private init(name: String, moveHistory: [PlayerAction]) {
        self.name = name
        self.moveHistory = moveHistory
    }

    /// Add a PlayerAction to player move history.
    func add(_ playerAction: PlayerAction) -> Player {
        return Player(name: name, moveHistory: [playerAction] + moveHistory)
    }
}
