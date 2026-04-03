@testable import WallaMarvel

final class DetailCharacterUISpy: DetailCharacterUI {
    private(set) var showEpisodeLoadingCalled = false
    private(set) var shownEpisode: Episode?
    private(set) var shownError: AppError?

    func showEpisodeLoading() {
        showEpisodeLoadingCalled = true
    }

    func showEpisode(_ episode: Episode) {
        shownEpisode = episode
    }

    func showEpisodeError(_ error: AppError) {
        shownError = error
    }
}
