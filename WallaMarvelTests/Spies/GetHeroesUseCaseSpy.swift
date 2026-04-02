@testable import WallaMarvel

final class GetHeroesUseCaseSpy: GetHeroesUseCaseProtocol {
    private(set) var executeCalled: Bool = false
    var result: [Character] = []
    var error: Error?

    func execute() async throws -> [Character] {
        executeCalled = true
        if let error {
            throw error
        }
        return result
    }
}
