import XCTest
@testable import WallaMarvel

@MainActor
final class ListCharactersPresenterTests: XCTestCase {
    private let getCharactersUseCaseSpy = GetCharactersUseCaseSpy()
    private lazy var sut = ListCharactersPresenter(getCharactersUseCase: getCharactersUseCaseSpy)

    // MARK: - screenTitle

    func test_whenScreenTitle_called_shouldReturnCorrectTitle() {
        let result = sut.screenTitle()
        XCTAssertEqual(result, "List of Characters")
    }

    // MARK: - getCharacters (initial load)

    func test_whenGetCharacters_called_shouldExecuteUseCase() async {
        await sut.getCharacters()

        XCTAssertTrue(getCharactersUseCaseSpy.executeCalled)
    }

    func test_whenGetCharacters_called_shouldRequestPageOne() async {
        await sut.getCharacters()

        XCTAssertEqual(getCharactersUseCaseSpy.lastRequestedPage, 1)
    }

    func test_whenGetCharacters_succeeds_shouldUpdateUI() async {
        let expectedCharacters = [Character.fixture()]
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: expectedCharacters, hasNextPage: false)

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.updatedCharactersCount, expectedCharacters.count)
    }

    func test_whenGetCharacters_fails_shouldNotUpdateUI() async {
        getCharactersUseCaseSpy.error = TestError.any

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertTrue(getCharactersUseCaseSpy.executeCalled)
        XCTAssertNil(uiSpy.updatedCharactersCount)
    }

    func test_whenGetCharacters_called_shouldShowLoading() async {
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertTrue(uiSpy.showLoadingWasCalled)
    }

    func test_whenGetCharacters_succeeds_shouldHideLoading() async {
        let expectedCharacters = [Character.fixture()]
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: expectedCharacters, hasNextPage: false)

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertTrue(uiSpy.hideLoadingWasCalled)
        XCTAssertFalse(uiSpy.isLoadingShown)
    }

    func test_whenGetCharacters_withAppError_shouldShowErrorWithUserFriendlyMessage() async {
        let appError = AppError.network("Connection failed")
        getCharactersUseCaseSpy.error = appError

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertTrue(uiSpy.hideLoadingWasCalled)
        XCTAssertEqual(uiSpy.lastShownError, appError)
    }

    func test_whenGetCharacters_withGenericError_shouldMapToAppError() async {
        getCharactersUseCaseSpy.error = TestError.any

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertNotNil(uiSpy.lastShownError)
    }

    // MARK: - loadNextPage

    func test_whenLoadNextPage_withoutHasNextPage_shouldNotCallUseCase() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        getCharactersUseCaseSpy.resetCallTracking()

        await sut.loadNextPage()

        XCTAssertFalse(getCharactersUseCaseSpy.executeCalled)
    }

    func test_whenLoadNextPage_withHasNextPage_shouldRequestNextPage() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture(id: 2)], hasNextPage: false)

        await sut.loadNextPage()

        XCTAssertEqual(getCharactersUseCaseSpy.lastRequestedPage, 2)
    }

    func test_whenLoadNextPage_succeeds_shouldAppendCharactersToUI() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        let nextPageCharacters = [Character.fixture(id: 2), Character.fixture(id: 3)]
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: nextPageCharacters, hasNextPage: false)

        await sut.loadNextPage()

        XCTAssertEqual(uiSpy.appendedCharacters.count, nextPageCharacters.count)
    }

    func test_whenLoadNextPage_succeeds_shouldShowAndHidePaginationLoading() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture(id: 2)], hasNextPage: false)

        await sut.loadNextPage()

        XCTAssertTrue(uiSpy.showPaginationLoadingWasCalled)
        XCTAssertFalse(uiSpy.isPaginationLoadingShown)
    }

    func test_whenLoadNextPage_fails_shouldShowPaginationError() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.error = AppError.network("Page load failed")
        await sut.loadNextPage()

        XCTAssertNotNil(uiSpy.lastPaginationError)
    }

    func test_whenLoadNextPage_fails_shouldNotUpdateExistingCharacters() async {
        let initialCharacters = [Character.fixture()]
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: initialCharacters, hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.error = AppError.network("Page load failed")
        await sut.loadNextPage()

        XCTAssertEqual(uiSpy.updatedCharactersCount, initialCharacters.count)
        XCTAssertTrue(uiSpy.appendedCharacters.isEmpty)
    }

    func test_whenLoadNextPage_fails_shouldAllowRetryViaRetryNextPage() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.error = AppError.network("Page load failed")
        await sut.loadNextPage()

        getCharactersUseCaseSpy.error = nil
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture(id: 2)], hasNextPage: false)
        await sut.retryNextPage()

        XCTAssertEqual(uiSpy.appendedCharacters.count, 1)
    }

    func test_whenLoadNextPage_fails_shouldBlockSubsequentAutoLoads() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.error = AppError.network("failed")
        await sut.loadNextPage()
        getCharactersUseCaseSpy.error = nil
        getCharactersUseCaseSpy.resetCallTracking()

        // Simulating willDisplay triggering again after error — should be blocked
        await sut.loadNextPage()

        XCTAssertFalse(getCharactersUseCaseSpy.executeCalled)
    }

    func test_whenRetryNextPage_afterError_shouldCallUseCaseAgain() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.error = AppError.network("failed")
        await sut.loadNextPage()

        getCharactersUseCaseSpy.error = nil
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture(id: 2)], hasNextPage: false)
        getCharactersUseCaseSpy.resetCallTracking()

        await sut.retryNextPage()

        XCTAssertTrue(getCharactersUseCaseSpy.executeCalled)
        XCTAssertEqual(uiSpy.appendedCharacters.count, 1)
    }

    // MARK: - searchCharacters

    func test_whenSearchCharacters_withMatchingName_shouldUpdateUIWithFilteredResults() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "Morty")

        XCTAssertEqual(uiSpy.updatedCharacters.count, 1)
        XCTAssertEqual(uiSpy.updatedCharacters.first?.name, "Morty Smith")
    }

    func test_whenSearchCharacters_isCaseInsensitive() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "morty")

        XCTAssertEqual(uiSpy.updatedCharacters.count, 1)
        XCTAssertEqual(uiSpy.updatedCharacters.first?.name, "Morty Smith")
    }

    func test_whenSearchCharacters_withNoMatch_shouldShowEmptySearch() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "Zorg")

        XCTAssertTrue(uiSpy.showEmptySearchWasCalled)
    }

    func test_whenSearchCharacters_withEmptyString_shouldRestoreFullList() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "Morty")
        sut.searchCharacters(name: "")

        XCTAssertEqual(uiSpy.updatedCharacters.count, 2)
    }

    func test_whenSearchCharacters_withWhitespaceOnly_shouldRestoreFullList() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "   ")

        XCTAssertEqual(uiSpy.updatedCharacters.count, 1)
    }

    func test_whenClearSearch_shouldRestoreFullList() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "Morty")
        sut.clearSearch()

        XCTAssertEqual(uiSpy.updatedCharacters.count, 2)
    }

    func test_whenLoadNextPage_withSearchActive_shouldNotCallUseCase() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()
        sut.searchCharacters(name: "Morty")
        getCharactersUseCaseSpy.resetCallTracking()

        await sut.loadNextPage()

        XCTAssertFalse(getCharactersUseCaseSpy.executeCalled)
    }
}
