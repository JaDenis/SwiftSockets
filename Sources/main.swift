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

                // If we don't receive a uuid, create a new player and add to the match.
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
