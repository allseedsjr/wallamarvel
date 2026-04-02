import Foundation

protocol GetHeroesUseCaseProtocol {
    func execute() async throws -> [Character]
}

struct GetHeroes: GetHeroesUseCaseProtocol {
    private let repository: MarvelRepositoryProtocol
    
    init(repository: MarvelRepositoryProtocol = MarvelRepository()) {
        self.repository = repository
    }
    
    func execute() async throws -> [Character] {
        try await repository.getHeroes()
    }
}
