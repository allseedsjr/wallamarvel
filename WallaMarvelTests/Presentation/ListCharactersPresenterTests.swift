import XCTest
@testable import WallaMarvel

final class ListCharactersPresenterTests: XCTestCase {
    private let getCharactersUseCaseSpy = GetCharactersUseCaseSpy()
    private lazy var sut = ListCharactersPresenter(getCharactersUseCase: getCharactersUseCaseSpy)
    
    func test_whenScreenTitle_called_shouldReturnCorrectTitle() {
        let result = sut.screenTitle()
        XCTAssertEqual(result, "List of Characters")
    }

    func test_whenGetCharacters_called_shouldExecuteUseCase() async {
        await sut.getCharacters()

        XCTAssertTrue(getCharactersUseCaseSpy.executeCalled)
    }

    func test_whenGetCharacters_succeeds_shouldUpdateUI() async {
        let expectedCharacters = [Character.fixture()]
        getCharactersUseCaseSpy.result = expectedCharacters

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

        XCTAssertTrue(uiSpy.isLoadingShown)
    }
    
    func test_whenGetCharacters_succeeds_shouldHideLoading() async {
        let expectedCharacters = [Character.fixture()]
        getCharactersUseCaseSpy.result = expectedCharacters
        
        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertFalse(uiSpy.isLoadingShown)
    }
    
    func test_whenGetCharacters_withAppError_shouldShowErrorWithUserFriendlyMessage() async {
        let appError = AppError.network("Connection failed")
        getCharactersUseCaseSpy.error = appError

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertEqual(uiSpy.lastShownError, appError)
    }
    
    func test_whenGetCharacters_withGenericError_shouldMapToAppError() async {
        getCharactersUseCaseSpy.error = TestError.any

        let uiSpy = ListCharactersUISpy()
        sut.ui = uiSpy

        await sut.getCharacters()

        XCTAssertNotNil(uiSpy.lastShownError)
    }
