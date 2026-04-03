@testable import WallaMarvel

final class APIClientSpy: APIClientProtocol {
    private(set) var getCharactersCalled: Bool = false
    private(set) var lastRequestedPage: Int = 0
    var result: CharacterDataContainer = .fixture()
    var error: Error?

    func getCharacters(page: Int) async throws -> CharacterDataContainer {
        getCharactersCalled = true
        lastRequestedPage = page
        if let error {
            throw error
        }
        return result
    }
}
