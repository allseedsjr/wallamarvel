import Foundation

protocol GetCharactersUseCaseProtocol {
    func execute() async throws -> [Character]
}

struct GetCharacters: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol
    
    init(repository: CharacterRepositoryProtocol = CharacterRepository()) {
        self.repository = repository
    }
    
    func execute() async throws -> [Character] {
        try await repository.getCharacters()
    }
}
