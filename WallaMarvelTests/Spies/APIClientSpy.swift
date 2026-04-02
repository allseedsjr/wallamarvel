@testable import WallaMarvel

final class APIClientSpy: APIClientProtocol {
    private(set) var getHeroesCalled: Bool = false
    var result: CharacterDataContainer = .fixture()
    var error: Error?

    func getHeroes() async throws -> CharacterDataContainer {
        getHeroesCalled = true
        if let error {
            throw error
        }
        return result
    }
}
