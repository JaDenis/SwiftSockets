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

// TODO: Move this into a struct to track game state.
/// Track matches based on match name.
fileprivate var matches: [MatchName: [Player.UUID]] = [:]

/// Track players based on username.
fileprivate var players: [Player.UUID: Player] = [:]


// TODO: Support multiple players.
/**
Calculate health and charges for two players based on their collective move history.
Output is `(p1Health, p2Health, p1Charge, p2Charge)`.
 */
func calculateHealthAndCharges(p1: Player, p2: Player) -> (Int, Int, Int, Int) {
    let combinedHistory = Array(zip(p1.moveHistory, p2.moveHistory))

    let charges = combinedHistory.reduce((0,0,0,0)) { (total, tup) in
        // Determine charges and health for this round.
        let (p1m, p2m) = tup
        var (p1h, p2h, p1c, p2c) = total

        if p1m == .charge && p2m != .steal { p1c += 1 }
        if p2m == .charge && p1m != .steal { p2c += 1 }
        if p1m == .shoot { p1c -= 1 }
        if p2m == .shoot { p2c -= 1 }
        if p1m == .charge && p2m == .steal { p2c += 1 }
        if p1m == .steal && p2m == .charge { p1c += 1 }

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

    return charges
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
