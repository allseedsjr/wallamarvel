@testable import WallaMarvel

final class EpisodeRepositorySpy: EpisodeRepositoryProtocol {
    private(set) var getEpisodeCalled = false
    private(set) var lastRequestedURL: String?
    var result: Episode = .fixture()
    var error: Error?

    func getEpisode(url: String) async throws -> Episode {
        getEpisodeCalled = true
        lastRequestedURL = url
        if let error { throw error }
        return result
    }
}
