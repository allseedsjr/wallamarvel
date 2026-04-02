@testable import WallaMarvel

final class CharacterRepositorySpy: CharacterRepositoryProtocol {
    private(set) var getCharactersCalled: Bool = false
    var result: [Character] = []
    var error: Error?

    func getCharacters() async throws -> [Character] {
        getCharactersCalled = true
        if let error {
            throw error
        }
        return result
    }
}
