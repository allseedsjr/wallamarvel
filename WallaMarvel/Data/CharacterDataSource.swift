import Foundation

protocol CharacterDataSourceProtocol {
    func getCharacters(page: Int) async throws -> CharacterDataContainer
}

final class CharacterDataSource: CharacterDataSourceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func getCharacters(page: Int) async throws -> CharacterDataContainer {
        do {
            return try await apiClient.request(GetCharactersRequest(page: page))
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
