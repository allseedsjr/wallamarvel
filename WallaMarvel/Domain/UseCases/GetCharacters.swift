import Foundation

protocol GetCharactersUseCaseProtocol {
    func execute(page: Int) async throws -> CharactersPage
}

struct GetCharacters: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol
    
    init(repository: CharacterRepositoryProtocol = CharacterRepository()) {
        self.repository = repository
    }
    
    func execute(page: Int) async throws -> CharactersPage {
        try await repository.getCharacters(page: page)
    }
}
