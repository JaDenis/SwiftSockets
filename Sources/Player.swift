import Foundation
import WebSockets
import JSON

/// Player is a reference type with value semantics.
struct Player {
    typealias UUID = String

    /// A Player's starting (health, charges)
    static let startingStats = (5, 0)

    /// What is the player's name?
    let name: String

    let uuid: Player.UUID

    let matchID: String

    /// Cumulative history of moves.
    let moveHistory: [PlayerAction]

    let socket: WebSocket

    let charges: Int

    let health: Int

    init(name: String, matchID: String, uuid: Player.UUID, socket: WebSocket) {
        self.name = name
        self.matchID = matchID
        self.socket = socket
        self.uuid = uuid
        self.moveHistory = []
        self.health = 5
        self.charges = 0
    }

    init(name: String,
         playerID: Player.UUID,
         matchID: String,
         socket: WebSocket,
         moveHistory: [PlayerAction]) {
            self.name = name
            self.uuid = playerID
            self.matchID = matchID
            self.socket = socket
            self.moveHistory = moveHistory
            self.health = 5
            self.charges = 0
    }

    private init(player: Player, health: Int? = nil, charges: Int? = nil) {
        self.name = player.name
        self.uuid = player.uuid
        self.matchID = player.matchID
        self.socket = player.socket
        self.moveHistory = player.moveHistory
        self.health = health ?? player.health
        self.charges = charges ?? player.charges
    }

    static func decodeUUIDAndPlayerAction(fromJSON json: JSON) -> (Player.UUID, PlayerAction)?  {
        guard let uuid = json.decode(key: Strings.jPlayer.uuidKey),
            let str = json.decode(key: Strings.jPlayer.playerActionKey),
            let action = PlayerAction.decode(fromStr: str) else {
                return nil
        }
        return (uuid, action)
    }

    func encodePlayerToJsonPlayer() -> JSON {
        return JsonPlayer(uuid: self.uuid,
                          username: self.name,
                          charges: self.charges,
                          health: self.health,
                          actionHistory: self.moveHistory).encodeToJson()
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

    /// Returns an updated player model with the specified health and charges.
    static func update(player: Player, health: Int? = nil, charges: Int? = nil) -> Player {
        return self.init(player: player,
                         health: health,
                         charges: charges)

    }

    func add(playerAction: PlayerAction, socket: WebSocket) -> Player {
        return Player(name: self.name,
                      playerID: self.uuid,
                      matchID: self.matchID,
                      socket: socket,
                      moveHistory: self.moveHistory + [playerAction])
    }
}

struct JsonPlayer {
    let uuid: Player.UUID
    let username: String
    let charges: Int
    let health: Int
    let actionHistory: [PlayerAction]

    func encodeToJson() -> JSON {

        let json = try! JSON(node: [
            Strings.jPlayer.uuidKey: self.uuid,
            Strings.jPlayer.usernameKey: self.username,
            Strings.jPlayer.chargesKey: "\(self.charges)",
            Strings.jPlayer.healthKey: "\(self.health)",
            Strings.jPlayer.actionHistoryKey: PlayerAction.encode(self.actionHistory)
            ])

        return json
    }
}

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

public enum PlayerError: Error {
    case jsonInvalidKeys
    case matchCombineError
    case invalidTurnNumber
    case invalidUsernameOrMatchName
}
