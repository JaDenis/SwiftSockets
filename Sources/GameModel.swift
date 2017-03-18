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
        let updatedPlayer = player.add(playerAction: action, socket: socket)
        self.update(players: [updatedPlayer])
        return updatedPlayer
    }

    func getPlayer(with id: Player.UUID) -> Player? {
        return self.playerModels[id]
    }
    
}
