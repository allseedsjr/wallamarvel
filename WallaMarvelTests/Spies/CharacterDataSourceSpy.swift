@testable import WallaMarvel

final class CharacterDataSourceSpy: CharacterDataSourceProtocol {
    private(set) var getCharactersCalled: Bool = false
    var result: CharacterDataContainer = .fixture()
    var error: Error?

    func getCharacters() async throws -> CharacterDataContainer {
        getCharactersCalled = true
        if let error {
            throw error
        }
        return result
    }
}
