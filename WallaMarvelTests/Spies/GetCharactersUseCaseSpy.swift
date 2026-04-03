@testable import WallaMarvel

final class GetCharactersUseCaseSpy: GetCharactersUseCaseProtocol {
    private(set) var executeCalled: Bool = false
    private(set) var lastRequestedPage: Int = 0
    var pageResult: CharactersPage = CharactersPage(characters: [], hasNextPage: false)
    var error: Error?

    func execute(page: Int) async throws -> CharactersPage {
        executeCalled = true
        lastRequestedPage = page
        if let error {
            throw error
        }
        return pageResult
    }

    func resetCallTracking() {
        executeCalled = false
        lastRequestedPage = 0
    }
}
