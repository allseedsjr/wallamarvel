import Foundation

protocol APIClientProtocol {
    func getCharacters() async throws -> CharacterDataContainer
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func getCharacters() async throws -> CharacterDataContainer {
        let endpoint = "https://rickandmortyapi.com/api/character"
        
        guard let url = URL(string: endpoint) else {
            throw AppError.invalidData("Invalid API endpoint URL")
        }
        
        let (data, response) = try await session.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AppError.network("HTTP \(httpResponse.statusCode): Server error")
            }
        }
        
        let dataModel = try JSONDecoder().decode(CharacterDataContainer.self, from: data)
        return dataModel
    }
}
