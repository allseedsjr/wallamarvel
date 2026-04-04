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

    // MARK: - ViewModel mapping

    func test_whenGetCharacters_withAliveStatus_shouldMapStatusTextAndColorCorrectly() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(
            characters: [.fixture(status: "Alive")],
            hasNextPage: false
        )
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusText, "Alive")
        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusColor, .systemGreen)
    }

    func test_whenGetCharacters_withDeadStatus_shouldMapStatusTextAndColorCorrectly() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(
            characters: [.fixture(status: "dead")],
            hasNextPage: false
        )
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusText, "Dead")
        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusColor, .systemRed)
    }

    func test_whenGetCharacters_withUnknownStatus_shouldMapStatusTextAndColorCorrectly() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(
            characters: [.fixture(status: "unknown")],
            hasNextPage: false
        )
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusText, "Unknown")
        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusColor, .systemGray)
    }

    func test_whenGetCharacters_withArbitraryStatus_shouldFallbackToUnknown() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(
            characters: [.fixture(status: "Zombie")],
            hasNextPage: false
        )
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusText, "Unknown")
        XCTAssertEqual(uiSpy.updatedCharacters.first?.statusColor, .systemGray)
    }

    func test_whenGetCharacters_succeeds_shouldMapNameAndSpeciesCorrectly() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(
            characters: [.fixture(name: "Morty Smith", species: "Human")],
            hasNextPage: false
        )
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.updatedCharacters.first?.name, "Morty Smith")
        XCTAssertEqual(uiSpy.updatedCharacters.first?.species, "Human")
    }

    // MARK: - character(at:)

    func test_whenCharacterAt_withValidIndex_shouldReturnCorrectCharacter() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        sut.ui = ListCharactersUISpy()

        await sut.getCharacters()

        XCTAssertEqual(sut.character(at: 0)?.name, "Morty Smith")
        XCTAssertEqual(sut.character(at: 1)?.name, "Rick Sanchez")
    }

    func test_whenCharacterAt_withOutOfBoundsIndex_shouldReturnNil() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: false)
        sut.ui = ListCharactersUISpy()

        await sut.getCharacters()

        XCTAssertNil(sut.character(at: 99))
    }

    func test_whenCharacterAt_duringActiveSearch_shouldReturnFromFilteredList() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        sut.ui = ListCharactersUISpy()

        await sut.getCharacters()
        sut.searchCharacters(name: "Rick")

        XCTAssertEqual(sut.character(at: 0)?.name, "Rick Sanchez")
        XCTAssertNil(sut.character(at: 1))
    }

    func test_whenCharacterAt_afterClearSearch_shouldReturnFromFullList() async {
        let morty = Character.fixture(id: 1, name: "Morty Smith")
        let rick = Character.fixture(id: 2, name: "Rick Sanchez")
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [morty, rick], hasNextPage: false)
        sut.ui = ListCharactersUISpy()

        await sut.getCharacters()
        sut.searchCharacters(name: "Rick")
        sut.clearSearch()

        XCTAssertEqual(sut.character(at: 0)?.name, "Morty Smith")
        XCTAssertEqual(sut.character(at: 1)?.name, "Rick Sanchez")
    }

    func test_whenCharacterAt_beforeGetCharacters_shouldReturnNil() {
        XCTAssertNil(sut.character(at: 0))
    }

    func test_whenCharacterAt_afterLoadNextPage_shouldReturnCharactersAcrossPages() async {
        let firstPage = [Character.fixture(id: 1, name: "Morty Smith")]
        let secondPage = [Character.fixture(id: 2, name: "Rick Sanchez")]
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: firstPage, hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: secondPage, hasNextPage: false)
        await sut.loadNextPage()

        XCTAssertEqual(sut.character(at: 0)?.name, "Morty Smith")
        XCTAssertEqual(sut.character(at: 1)?.name, "Rick Sanchez")
    }

    func test_whenLoadNextPage_succeeds_shouldMapAppendedCharactersCorrectly() async {
        getCharactersUseCaseSpy.pageResult = CharactersPage(characters: [.fixture()], hasNextPage: true)
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        getCharactersUseCaseSpy.pageResult = CharactersPage(
            characters: [.fixture(id: 2, status: "dead")],
            hasNextPage: false
        )
        await sut.loadNextPage()

        XCTAssertEqual(uiSpy.appendedCharacters.first?.statusText, "Dead")
        XCTAssertEqual(uiSpy.appendedCharacters.first?.statusColor, .systemRed)
    }
}
