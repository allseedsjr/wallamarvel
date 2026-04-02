import Foundation

protocol MarvelRepositoryProtocol {
    func getHeroes() async throws -> CharacterDataContainer
}

final class MarvelRepository: MarvelRepositoryProtocol {
    private let dataSource: MarvelDataSourceProtocol
    
    init(dataSource: MarvelDataSourceProtocol = MarvelDataSource()) {
        self.dataSource = dataSource
    }
    
    func getHeroes() async throws -> CharacterDataContainer {
        try await dataSource.getHeroes()
    }
}
