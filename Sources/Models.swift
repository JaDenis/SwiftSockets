import Foundation

struct Match {
    /// Who is participating in the match?
    let players: [Player]

    /// Convenience variable to calculate player health.
    var playerHealth: [Int] {
        // Placeholder.
        return [1]
    }

    /// What is the name of the match?
    let name: String

    /// How many turns have elapsed?
    let turnNumber: Int

    /// Public initializer to start a new game.
    init(name: String) {
        self.init(name: name, players: [], turnNumber: 0)
    }

    private init(name: String, players: [Player], turnNumber: Int) {
        self.name = name
        self.players = players
        self.turnNumber = turnNumber
    }
}

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

/// Possible set of moves a player can choose from.
enum PlayerAction {
    case block
    case charge
    case shoot
    case steal
}
