@testable import WallaMarvel

final class EpisodeDataSourceSpy: EpisodeDataSourceProtocol {
    private(set) var getEpisodeCalled = false
    private(set) var lastRequestedURL: String?
    var result: EpisodeDataModel = .fixture()
    var error: Error?

    func getEpisode(url: String) async throws -> EpisodeDataModel {
        getEpisodeCalled = true
        lastRequestedURL = url
        if let error { throw error }
        return result
    }
}
