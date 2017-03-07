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
