import Vapor
import WebSockets
import Foundation

let drop = Droplet()

drop.get("hello") { request in
    return "Hello World!"
}

typealias Username = String
typealias Payload = String
typealias Payloads = [Payload]

fileprivate var connections = [Username : Payloads]()

drop.socket("ws") { req, ws in
    print("New WebSocket connected: \(ws)")
    print("Websocket: \(req)")
    // ping the socket to keep it open
    try background {
        while ws.state == .open {
            try? ws.ping()
            drop.console.wait(seconds: 10) // every 10 seconds
        }
    }

    ws.onText = { ws, text in
        // Convert text from String to JSON.
        let json = try JSON(bytes: Array(text.utf8))
        print("json: ", json)

        // Save username and payload to a dictionary.
        if let username = json.object?["username"]?.string,
            let payload = json.object?["payload"]?.string {

            // Save payload.
            if connections[username]?.append(payload) == nil {
                connections[username] = [payload]
            }
        }

        let outgoingJson = try JSON(node: [
            "username": "test",
            "message": "testing"
            ])

        try ws.send(outgoingJson)
    }

    ws.onClose = { ws, code, reason, clean in
        print("Closed: \(ws), \(code), \(reason), \(clean)")
    }
}

drop.run()
