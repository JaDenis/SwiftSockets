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

    /**
     Calculate health and charges for two players based on their move history.
     Output is `(p1Health, p2Health, p1Charge, p2Charge)`.
     */
    private func calculateHealthAndCharges(p1: Player, p2: Player) -> (Int, Int, Int, Int) {
        let combinedHistory = Array(zip(p1.moveHistory, p2.moveHistory))
        print("combined history: \(combinedHistory)")

        let (sHealth, sCharges) = Player.startingStats

        let healthAndCharges = combinedHistory
            .reduce((sHealth, sHealth, sCharges, sCharges)) { (total, tup) in
            // Determine charges and health for this round.
                let (p1m, p2m) = tup
                var (p1h, p2h, p1c, p2c) = total

                if p1m == .charge && p2m != .steal { p1c += 1 }
                if p1m == .charge && p2m == .steal { p2c += 1 }

                if p2m == .charge && p1m != .steal { p2c += 1 }
                if p2m == .charge && p1m == .steal { p1c += 1 }

                if p1m == .shoot { p1c -= 1 }
                if p2m == .shoot { p2c -= 1 }

                if p1m == .shoot {
                    if p2m == .reflect {
                        p1h -= 1
                    } else if p2m != .block && p2m != .shoot {
                        p2h -= 1
                    }
                }

                if p2m == .shoot {
                    if p1m == .reflect {
                        p2h -= 1
                    } else if p1m != .block && p1m != .shoot {
                        p1h -= 1
                    }
                }
                
                return (p1h, p2h, p1c, p2c)
        }

        return healthAndCharges
    }
    
}
