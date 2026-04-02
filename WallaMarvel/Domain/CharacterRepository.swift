import Foundation

protocol CharacterRepositoryProtocol {
    func getCharacters() async throws -> [Character]
}

final class CharacterRepository: CharacterRepositoryProtocol {
    private let dataSource: CharacterDataSourceProtocol
    
    init(dataSource: CharacterDataSourceProtocol = CharacterDataSource()) {
        self.dataSource = dataSource
    }
    
    func getCharacters() async throws -> [Character] {
        let container = try await dataSource.getCharacters()
        return try container.toDomainCharacters()
    }
}
