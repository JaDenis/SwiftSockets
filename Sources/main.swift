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

fileprivate var matches: [String: Match] = [:]

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
            let match = try Match.decode(jsonMatchInit: json)

            // If a match with the same name already exists, then combine the two matches.
            if let existingMatch = matches[match.name] {
                matches[match.name] = try Match.combine(matches: [existingMatch, match])
            } else {
                matches[match.name] = match
            }
        } catch {
            print("unable to append matches")
        }

        print("match successfully registered! \(matches)")

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
    }
}

// transform json to something usable -

drop.run()
