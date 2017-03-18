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

var gameModel = GameModel()

// TODO: Support multiple players.
/**
 Calculate health and charges for two players based on their collective move history.
 Output is `(p1Health, p2Health, p1Charge, p2Charge)`.
 */
func calculateHealthAndCharges(p1: Player, p2: Player) -> (Int, Int, Int, Int) {
    let combinedHistory = Array(zip(p1.moveHistory, p2.moveHistory))

    let healthAndCharges = combinedHistory.reduce((0,0,0,0)) { (total, tup) in
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

    return healthAndCharges
}

func send(updatedPlayer: Player, with gameModel: GameModel) {
    guard let players = gameModel.getPlayers(in: updatedPlayer.matchID) else {
        print("error sending \(updatedPlayer)")
        return
    }

    let currentPlayerJson = updatedPlayer.encodePlayerToJsonPlayer()
    let otherPlayersJson = players.map { $0.encodePlayerToJsonPlayer() }

    let json = [currentPlayerJson] + otherPlayersJson

    for p in players {
        do {
            try p.socket.send(json)
        } catch(let err) {
            print("unable to send json: ", err)
        }
    }
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
            if let (uuid, action) = Player.decodeUUIDAndPlayerAction(fromJSON: json) {
                let updatedPlayer = gameModel.add(action: action, socket: ws, toPlayerWithUUID: uuid)
                print("updatedPlayer: \(updatedPlayer)")
                send(updatedPlayer: updatedPlayer, with: gameModel)

                // If we don't receive a uuid, create a new player and add that to the match.
            } else {
                let newPlayer = try Player.initNewPlayer(fromJSON: json,
                                                         uuid: String.random(),
                                                         socket: ws)
                gameModel.update(players: [newPlayer])
                print("newPlayer: \(newPlayer)")
                send(updatedPlayer: newPlayer, with: gameModel)
            }
        } catch {
            print("there was an error.")
        }

        print("")
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
