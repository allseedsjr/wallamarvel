import XCTest
@testable import WallaMarvel

final class ListHeroesPresenterTests: XCTestCase {
    private let getHeroesUseCaseSpy = GetHeroesUseCaseSpy()
    private lazy var sut = ListHeroesPresenter(getHeroesUseCase: getHeroesUseCaseSpy)
    
    func test_whenScreenTitle_called_shouldReturnCorrectTitle() {
        let result = sut.screenTitle()
        XCTAssertEqual(result, "List of Heroes")
    }

    func test_whenGetHeroes_called_shouldExecuteUseCase() async {
        await sut.getHeroes()

        XCTAssertTrue(getHeroesUseCaseSpy.executeCalled)
    }

    func test_whenGetHeroes_succeeds_shouldUpdateUI() async {
        let expectedHeroes = [Character.fixture()]
        getHeroesUseCaseSpy.result = expectedHeroes

        let uiSpy = ListHeroesUISpy()
        sut.ui = uiSpy

        await sut.getHeroes()

        XCTAssertEqual(uiSpy.updatedHeroesCount, expectedHeroes.count)
    }

    func test_whenGetHeroes_fails_shouldNotUpdateUI() async {
        getHeroesUseCaseSpy.error = TestError.any

        let uiSpy = ListHeroesUISpy()
        sut.ui = uiSpy

        await sut.getHeroes()

        XCTAssertTrue(getHeroesUseCaseSpy.executeCalled)
        XCTAssertNil(uiSpy.updatedHeroesCount)
    }
}
