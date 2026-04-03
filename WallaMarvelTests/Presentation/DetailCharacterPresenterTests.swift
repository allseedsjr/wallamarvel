import XCTest
@testable import WallaMarvel

@MainActor
final class DetailCharacterPresenterTests: XCTestCase {
    private let useCaseSpy = GetCharacterFirstEpisodeUseCaseSpy()
    private let uiSpy = DetailCharacterUISpy()

    private func makeSUT(
        firstEpisodeURL: String? = "https://rickandmortyapi.com/api/episode/1"
    ) -> DetailCharacterPresenter {
        let character = Character.fixture(firstEpisodeURL: firstEpisodeURL)
        let sut = DetailCharacterPresenter(character: character, getFirstEpisodeUseCase: useCaseSpy)
        sut.ui = uiSpy
        return sut
    }

    // MARK: - use case delegation

    func test_whenLoadEpisode_called_shouldCallUseCase() async {
        let sut = makeSUT()
        await sut.loadEpisode()

        XCTAssertTrue(useCaseSpy.executeCalled)
    }

    func test_whenLoadEpisode_withNilEpisodeURL_shouldNotCallUseCase() async {
        let sut = makeSUT(firstEpisodeURL: nil)
        await sut.loadEpisode()

        XCTAssertFalse(useCaseSpy.executeCalled)
    }

    func test_whenLoadEpisode_called_shouldPassCorrectURL() async {
        let episodeURL = "https://rickandmortyapi.com/api/episode/1"
        let sut = makeSUT(firstEpisodeURL: episodeURL)
        await sut.loadEpisode()

        XCTAssertEqual(useCaseSpy.lastRequestedURL, episodeURL)
    }

    // MARK: - loading state

    func test_whenLoadEpisode_called_shouldShowLoading() async {
        let sut = makeSUT()
        await sut.loadEpisode()

        XCTAssertTrue(uiSpy.showEpisodeLoadingCalled)
    }

    // MARK: - success

    func test_whenLoadEpisode_succeeds_shouldShowEpisode() async {
        let expected = Episode.fixture()
        useCaseSpy.result = expected
        let sut = makeSUT()
        await sut.loadEpisode()

        XCTAssertEqual(uiSpy.shownEpisode?.id, expected.id)
        XCTAssertEqual(uiSpy.shownEpisode?.name, expected.name)
    }

    // MARK: - error handling

    func test_whenLoadEpisode_withAppError_shouldShowError() async {
        let appError = AppError.network("No connection")
        useCaseSpy.error = appError
        let sut = makeSUT()
        await sut.loadEpisode()

        XCTAssertEqual(uiSpy.shownError, appError)
    }

    func test_whenLoadEpisode_withUnknownError_shouldMapAndShowError() async {
        useCaseSpy.error = TestError.any
        let sut = makeSUT()
        await sut.loadEpisode()

        if case .unknown = uiSpy.shownError { } else {
            XCTFail("Expected .unknown error, got \(String(describing: uiSpy.shownError))")
        }
    }
}
