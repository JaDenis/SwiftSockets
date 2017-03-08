//import Foundation
//import JSON
//
//struct Match {
//    /// Who is participating in the match?
//    let players: [Player]
//
//    /// Convenience variable to calculate player health.
//    var playerHealth: [Int] {
//        // Placeholder.
//        return [1]
//    }
//
//    /// What is the name of the match?
//    let name: String
//
//    /// How many turns have elapsed?
//    let turnNumber: Int
//
//    /// Public initializer to start a new game.
//    init(name: String, player: Player) {
//        self.init(name: name, players: [player], turnNumber: 0)
//    }
//
//    /// Combine players from different matches.
//    static func combine(matches: [Match]) throws -> Match {
//        // Check that match name is the same.
//        guard Set(matches.map { $0.name }).count == 1 else {
//            throw MatchError.matchCombineError
//        }
//
//        // Check that usernames are unique.
//        guard (Set(matches.map { $0.name }).count) ==
//            (matches.reduce(0) { $0 + $1.players.count }) else {
//                throw MatchError.invalidUsername
//        }
//
//        // Check that the turn number is 0.
//        guard (matches.reduce(0) { $0 + $1.turnNumber } == 0) else {
//            throw MatchError.invalidTurnNumber
//        }
//
//        return Match(name: matches[0].name,
//                     players: matches.reduce([]) { $0 + $1.players } ,
//                     turnNumber: matches[0].turnNumber)
//    }
//
//    private init(name: String, players: [Player], turnNumber: Int) {
//        self.name = name
//        self.players = players
//        self.turnNumber = turnNumber
//    }
//
////    static func decode(jsonMatchInit json: JSON) throws -> Match {
////        if let type = json.object?[Strings.typeKey]?.string,
////            type == Strings.jsonFindMatchType,
////            let playerName = json.object?[Strings.usernameKey]?.string,
////            let matchName = json.object?[Strings.matchNameKey]?.string {
////                return Match(name: matchName, playerName: playerName)
////        }
////        throw MatchError.jsonInvalidKeys
////    }
//}
//
