import WebSockets

/// Singleton model which tracks game state.
struct GameModel {
    /// Track matches based on match name.
    private var playerIdsInMatch: [MatchName: Set<Player.UUID>] = [:]

    /// Track players based on username.
    private var playerModels: [Player.UUID: Player] = [:]

    /// No init parameters because GameModel is a singleton.
    init() {
        self.playerIdsInMatch = [:]
        self.playerModels = [:]
    }

    func getPlayers(in match: MatchName) -> [Player]? {
        let playerIds = playerIdsInMatch[match] ?? nil
        return playerIds?.flatMap { self.playerModels[$0] }
    }

    mutating func update(players: [Player]) {
        for player in players {
            if self.playerIdsInMatch[player.matchID]?.insert(player.uuid) == nil {
                self.playerIdsInMatch[player.matchID] = Set([player.uuid])
            }

            self.playerModels[player.uuid] = player
        }
    }

    // TODO: Add error handling
    mutating func add(action: PlayerAction, socket: WebSocket, toPlayerWithUUID uuid: Player.UUID) -> Player {
        guard let player = self.getPlayer(with: uuid) else {
            fatalError()
        }
        // Add an action to the player's move history.
        let updatedPlayer = player.add(playerAction: action, socket: socket)

        // Calculate health for the other players. Assumes two players for now.
        guard let players = self.getPlayers(in: updatedPlayer.matchID) else {
            fatalError()
        }

        let (p1h, p2h, p1c, p2c) =
            calculateHealthAndCharges(p1: players[0], p2: players[1])

        let allUpdatedPlayers =
            [Player.update(player: players[0], health: p1h, charges: p1c),
             Player.update(player: players[1], health: p2h, charges: p2c)]

        self.update(players: allUpdatedPlayers)
        return updatedPlayer

    }

    func getPlayer(with id: Player.UUID) -> Player? {
        return self.playerModels[id]
    }
    
}
