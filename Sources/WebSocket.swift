import JSON
import WebSockets

extension WebSocket {
    func send(_ json: JSON) throws {
        let js = try json.makeBytes()
        try send(js.string)
    }
}

extension JSON {
    func decode(key: String) -> String? {
        return self.object?[key]?.string
    }
}
