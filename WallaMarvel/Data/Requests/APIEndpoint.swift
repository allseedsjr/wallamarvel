import Foundation

enum APIEndpoint {
    static let baseURL = "https://rickandmortyapi.com"

    enum Path: String {
        case characters = "/api/character"
        case episode    = "/api/episode"
    }
}
