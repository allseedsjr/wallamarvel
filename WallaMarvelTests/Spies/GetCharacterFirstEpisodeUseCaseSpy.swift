@testable import WallaMarvel

final class GetCharacterFirstEpisodeUseCaseSpy: GetCharacterFirstEpisodeUseCaseProtocol {
    private(set) var executeCalled = false
    private(set) var lastRequestedURL: String?
    var result: Episode = .fixture()
    var error: Error?

    func execute(episodeURL: String) async throws -> Episode {
        executeCalled = true
        lastRequestedURL = episodeURL
        if let error { throw error }
        return result
    }
}
