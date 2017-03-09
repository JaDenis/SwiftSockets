import Vapor
import WebSockets
import Foundation

let drop = Droplet()

// Test that the droplet is running.
drop.get("hello") { request in
    return "Hello World!"
}

//typealias Username = String
//typealias Payload = String
//typealias Payloads = [Payload]

//fileprivate var connections = [Username : Payloads]()

typealias MatchName = String

/// Track matches based on match name.
fileprivate var matches: [MatchName: [Player.UUID]] = [:]

/// Track players based on username.
fileprivate var players: [Player.UUID: Player] = [:]

func readThe(json: JSON) {

}

drop.socket("ws") { req, ws in

    // ping the socket to keep it open
    try background {
        while ws.state == .open {
            try? ws.ping()
            drop.console.wait(seconds: 10) // every 10 seconds
        }
    }

    ws.onText = { ws, text in
        // Convert text from String to JSON.
        do {
            let json = try JSON(bytes: Array(text.utf8))

            print("received json: \(json)")

            // If we receive a uuid and action, then add that action to the player's move history.
            if let (uuid, action) = Player.decodeUUIDAndPlayerAction(fromJSON: json),
                let player = players[uuid] {
                players[uuid] = player.add(playerAction: action, socket: ws)

                //TODO: Notify all players of the updated action.

            // If we don't receive a uuid, create a new player and add that to the match.
            } else {
                let uuid = String.random()
                let newPlayer = try Player.initNewPlayer(fromJSON: json, uuid: uuid, socket: ws)
                let matchID = newPlayer.matchID
                players[uuid] = newPlayer

                // Track matches.
                if matches[matchID]?.append(uuid) == nil {
                    matches[matchID] = [uuid]
                }

                // We need to send info on the new player to all players in the match.

                // Use the match name to find the player UUIDs.
                if let matchPlayerUUIDs = matches[matchID] {

                    // TODO: Use error handling.
                    let matchPlayers = matchPlayerUUIDs.map { players[$0]! }

                    // Encode all players.
                    let playerJson = matchPlayers.map { $0.encodePlayerToJsonPlayer() }

                    // Encode the new player.
                    let newPlayerJson = newPlayer.encodePlayerToJsonPlayer()

                    // New player information must be in the first position.
                    let jsonMessages = [newPlayerJson] + playerJson

                    // Send out new player details to each websocket connection.
                    for player in matchPlayers {
                        // TODO: Potential race condition? What if many new players join at the same time? How does vapor deal with that?
                        try player.socket.send(jsonMessages)
                    }

                    print("sent to \(matchPlayers.count) clients:")
                    print("outgoingjson: \(newPlayerJson)")
                }
            }
        } catch {
            print("there was an error.")
        }

//        print("players: \(players)")
//        print()
//        print("matches: \(matches)")
        print()
    }
}

            // If a match with the same name already exists, then combine the two matches.
//            if let existingMatch = matches[match.name] {
//                matches[match.name] = try Match.combine(matches: [existingMatch, match])
//            } else {
//                matches[match.name] = match
//            }
//        } catch {
//            // TODO: Process error messages and send back to client.
//            print("unable to append matches")
//        }
//
//        print("matches: \(matches)")



        // Save username and payload to a dictionary.
//        if let username = json.object?["username"]?.string,
//            let payload = json.object?["payload"]?.string {
//
//            // Save payload.
//            if connections[username]?.append(payload) == nil {
//                connections[username] = [payload]
//            }
//        }

//        let outgoingJson = try JSON(node: [
//            "username": "test",
//            "message": "testing"
//            ])
//
//        try ws.send(outgoingJson)
//    }
//
//    ws.onClose = { ws, code, reason, clean in
//        print("Closed: \(ws), \(code), \(reason), \(clean)")
//    }
//}

// transform json to something usable -

drop.run()
