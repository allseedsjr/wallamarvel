@testable import WallaMarvel

final class GetHeroesUseCaseSpy: GetHeroesUseCaseProtocol {
    private(set) var executeCalled: Bool = false
    var result: CharacterDataContainer = .fixture()
    var error: Error?

    func execute() async throws -> CharacterDataContainer {
        executeCalled = true
        if let error {
            throw error
        }
        return result
    }
}
