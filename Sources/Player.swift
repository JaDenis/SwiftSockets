import Foundation
import WebSockets
import JSON

/// Player is a reference type with value semantics.
struct Player {
    typealias UUID = String
    /// What is the player's name?
    let name: String

    let uuid: Player.UUID

    let matchID: String

    /// Cumulative history of moves.
    let moveHistory: [PlayerAction]

    let socket: WebSocket

    /// Convenience variable to calculate player charges.
    var charges: Int {
        // Placeholder.
        return 1
    }

    init(name: String, matchID: String, uuid: Player.UUID, socket: WebSocket) {
        self.name = name
        self.matchID = matchID
        self.socket = socket
        self.uuid = uuid
        self.moveHistory = []
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
    }

    // TODO: Fill this in later.
    func calculateHealth(vsPlayer player: Player) -> Int {
        return 0
    }

    static func decodeUUIDAndPlayerAction(fromJSON json: JSON) -> (Player.UUID, PlayerAction)?  {
        guard let uuid = json.decode(key: Strings.playerUUIDKey),
            let str = json.decode(key: Strings.playerActionKey),
            let action = PlayerAction.decode(fromStr: str) else {
                return nil
        }
        return (uuid, action)
    }

    /// Decode a new player from JSON.
    static func initNewPlayer(fromJSON json: JSON, uuid: Player.UUID, socket: WebSocket) throws -> Player {
        // Decode player and match name. These fields will be attached to every request.
        guard let playerName = json.decode(key: Strings.usernameKey),
            let matchName = json.decode(key: Strings.matchNameKey) else {
                throw PlayerError.invalidUsernameOrMatchName
        }

        return Player(name: playerName, matchID: matchName, uuid: uuid, socket: socket)
    }

    func add(playerAction: PlayerAction, socket: WebSocket) -> Player {
        return Player(name: self.name,
                      playerID: self.uuid,
                      matchID: self.matchID,
                      socket: socket,
                      moveHistory: self.moveHistory + [playerAction])
    }
}

public enum PlayerError: Error {
    case jsonInvalidKeys
    case matchCombineError
    case invalidTurnNumber
    case invalidUsernameOrMatchName
}

// TODO: Delete this shit.
public enum MatchError: Error {
    case jsonInvalidKeys
    case matchCombineError
    case invalidTurnNumber
    case invalidUsername
}
