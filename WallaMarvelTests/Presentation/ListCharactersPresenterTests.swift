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
}
