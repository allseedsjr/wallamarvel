import Foundation

protocol GetHeroesUseCaseProtocol {
    func execute() async throws -> CharacterDataContainer
}

struct GetHeroes: GetHeroesUseCaseProtocol {
    private let repository: MarvelRepositoryProtocol
    
    init(repository: MarvelRepositoryProtocol = MarvelRepository()) {
        self.repository = repository
    }
    
    func execute() async throws -> CharacterDataContainer {
        try await repository.getHeroes()
    }
}
