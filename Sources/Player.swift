import Foundation
import WebSockets
import JSON

/// Player is a reference type with value semantics.
struct Player {
    typealias UUID = String

    /// A Player's starting (health, charges)
    static let startingStats: (health: Int, charges: Int) = (5, 0)

    /// What is the player's name?
    let name: String

    /// What is the player's unique identifier?
    let uuid: Player.UUID

    /// What match is the player a part of?
    let matchID: String

    /// Cumulative history of moves.
    let actionHistory: [PlayerAction]

    /// How is the player connected?
    let socket: WebSocket

    /// How many charges does the player have?
    let charges: Int

    /// How much health does the player have?
    let health: Int

    /// Starting initializer used to create a new player.
    init(name: String, matchID: String, uuid: Player.UUID, socket: WebSocket) {
        self.name = name
        self.matchID = matchID
        self.socket = socket
        self.uuid = uuid
        self.actionHistory = []
        self.health = Player.startingStats.health
        self.charges = Player.startingStats.charges
    }

    /// Private initializer used to redefine player's move history.
    private init(name: String,
                 playerID: Player.UUID,
                 matchID: String,
                 socket: WebSocket,
                 moveHistory: [PlayerAction]) {
        self.name = name
        self.uuid = playerID
        self.matchID = matchID
        self.socket = socket
        self.actionHistory = moveHistory
        self.health = Player.startingStats.health
        self.charges = Player.startingStats.charges
    }

    /// Private initializer used to update player's health and charges.
    private init(player: Player, health: Int? = nil, charges: Int? = nil) {
        self.name = player.name
        self.uuid = player.uuid
        self.matchID = player.matchID
        self.socket = player.socket
        self.actionHistory = player.actionHistory
        self.health = health ?? player.health
        self.charges = charges ?? player.charges
    }


    /// Returns an updated player model with the specified health and charges.
    static func update(player: Player, health: Int? = nil, charges: Int? = nil) -> Player {
        return self.init(player: player,
                         health: health,
                         charges: charges)

    }

    /// Returns a new player with the playerAction added to the current player's move history.
    func add(playerAction: PlayerAction, socket: WebSocket) -> Player {
        return Player(name: self.name,
                      playerID: self.uuid,
                      matchID: self.matchID,
                      socket: socket,
                      moveHistory: self.actionHistory + [playerAction])
    }
}

// MARK: - JSON Processing
extension Player {
    /// Translate json into a player uuid and a player action.
    static func decodeUUIDAndPlayerAction(fromJSON json: JSON) -> (Player.UUID, PlayerAction)?  {
        guard let uuid = json.decode(key: Strings.jPlayer.uuidKey),
            let str = json.decode(key: Strings.jPlayer.playerActionKey),
            let action = PlayerAction.decode(fromStr: str) else {
                return nil
        }
        return (uuid, action)
    }

    /// Encode the current player into json format.
    func encodePlayerToJsonPlayer() -> JSON {
        let json = try! JSON(node: [
            Strings.jPlayer.uuidKey: self.uuid,
            Strings.jPlayer.usernameKey: self.name,
            Strings.jPlayer.chargesKey: "\(self.charges)",
            Strings.jPlayer.healthKey: "\(self.health)",
            Strings.jPlayer.actionHistoryKey: PlayerAction.encode(self.actionHistory)
            ])

        return json
    }

    /// Decode a new player from JSON.
    static func initNewPlayer(fromJSON json: JSON, uuid: Player.UUID, socket: WebSocket) throws -> Player {
        // Decode player and match name. These fields will be attached to every request.
        guard let playerName = json.decode(key: Strings.jPlayer.usernameKey),
            let matchName = json.decode(key: Strings.jPlayer.matchNameKey) else {
                throw PlayerError.invalidUsernameOrMatchName
        }

        return Player(name: playerName, matchID: matchName, uuid: uuid, socket: socket)
    }
}

// MARK: - Player Strings

extension Strings {
    struct jPlayer {
        static let uuidKey = "uuid"
        static let usernameKey = "username"
        static let chargesKey = "charges"
        static let healthKey = "health"
        static let actionHistoryKey = "actionHistory"
        static let matchNameKey = "matchName"
        static let playerActionKey = "playerAction"
    }
}

// MARK: - Player Json Errors

public enum PlayerError: Error {
    case jsonInvalidKeys
    case matchCombineError
    case invalidTurnNumber
    case invalidUsernameOrMatchName
}
