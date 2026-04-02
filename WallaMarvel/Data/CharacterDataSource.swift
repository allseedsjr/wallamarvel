import Foundation

protocol CharacterDataSourceProtocol {
    func getCharacters() async throws -> CharacterDataContainer
}

final class CharacterDataSource: CharacterDataSourceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getCharacters() async throws -> CharacterDataContainer {
        try await apiClient.getCharacters()
    }
}
