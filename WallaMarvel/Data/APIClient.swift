import Foundation

protocol APIClientProtocol {
    func getHeroes() async throws -> CharacterDataContainer
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func getHeroes() async throws -> CharacterDataContainer {
        let endpoint = "https://rickandmortyapi.com/api/character"
        
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        let (data, _) = try await session.data(from: url)
        let dataModel = try JSONDecoder().decode(CharacterDataContainer.self, from: data)
        return dataModel
    }
}
