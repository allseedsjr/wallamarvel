@testable import WallaMarvel

final class CharacterRepositorySpy: CharacterRepositoryProtocol {
    private(set) var getCharactersCalled: Bool = false
    private(set) var lastRequestedPage: Int = 0
    var pageResult: CharactersPage = CharactersPage(characters: [], hasNextPage: false)
    var error: Error?

    func getCharacters(page: Int) async throws -> CharactersPage {
        getCharactersCalled = true
        lastRequestedPage = page
        if let error {
            throw error
        }
        return pageResult
    }
}
