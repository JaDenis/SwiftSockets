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

            print(json)

            // If we receive a uuid and action, then add that action to the player's move history.
            if let (uuid, action) = Player.decodeUUIDAndPlayerAction(fromJSON: json),
                let player = players[uuid] {
                players[uuid] = player.add(playerAction: action, socket: ws)

            // If we don't receive a uuid, create a new player and add that to the match.
            } else {
                let uuid = String.random()
                let newPlayer = try Player.initNewPlayer(fromJSON: json, uuid: uuid, socket: ws)
                players[uuid] = newPlayer

                // Track matches.
                if matches[newPlayer.matchID]?.append(uuid) == nil {
                    matches[newPlayer.matchID] = [uuid]
                }
                let outgoingJson = newPlayer.encodePlayerToJsonPlayer()

                try ws.send(outgoingJson)
                print("outgoing: \(outgoingJson)")

                if matches[newPlayer.matchID]?.count ?? 0 > 1 {
                    // We need to send relevant information for these dudes to play a game.
                    // name, health, charges, new move
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
