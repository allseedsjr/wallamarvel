import Foundation

protocol MarvelDataSourceProtocol {
    func getHeroes() async throws -> CharacterDataContainer
}

final class MarvelDataSource: MarvelDataSourceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getHeroes() async throws -> CharacterDataContainer {
        try await apiClient.getHeroes()
    }
}
