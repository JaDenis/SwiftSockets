import JSON
import WebSockets

extension WebSocket {
    func send(_ json: JSON) throws {
        let js = try json.makeBytes()
        try send(js.string)
    }

    func send(_ jsonArray: [JSON]) throws {
        for json in jsonArray {
            try send(json)
        }
    }
}

extension JSON {
    func decode(key: String) -> String? {
        return self.object?[key]?.string
    }
}
