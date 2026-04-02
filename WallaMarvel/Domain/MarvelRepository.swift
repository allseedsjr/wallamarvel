import Foundation

protocol MarvelRepositoryProtocol {
    func getHeroes() async throws -> [Character]
}

final class MarvelRepository: MarvelRepositoryProtocol {
    private let dataSource: MarvelDataSourceProtocol
    
    init(dataSource: MarvelDataSourceProtocol = MarvelDataSource()) {
        self.dataSource = dataSource
    }
    
    func getHeroes() async throws -> [Character] {
        let container = try await dataSource.getHeroes()
        return try container.toDomainCharacters()
    }
}
