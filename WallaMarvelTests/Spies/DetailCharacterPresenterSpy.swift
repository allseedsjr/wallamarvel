@testable import WallaMarvel

@MainActor
final class DetailCharacterPresenterSpy: DetailCharacterPresenterProtocol {
    var ui: DetailCharacterUI?
    private(set) var loadEpisodeCalled = false

    func loadEpisode() async {
        loadEpisodeCalled = true
    }
}
