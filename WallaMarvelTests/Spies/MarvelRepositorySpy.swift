@testable import WallaMarvel

final class MarvelRepositorySpy: MarvelRepositoryProtocol {
    private(set) var getHeroesCalled: Bool = false
    var result: [Character] = []
    var error: Error?

    func getHeroes() async throws -> [Character] {
        getHeroesCalled = true
        if let error {
            throw error
        }
        return result
    }
}
