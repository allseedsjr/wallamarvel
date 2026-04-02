import XCTest
@testable import WallaMarvel

final class GetHeroesTests: XCTestCase {
    private let repositorySpy = MarvelRepositorySpy()
    private lazy var sut = GetHeroes(repository: repositorySpy)

    func test_whenExecute_called_shouldCallRepository() async throws {
        _ = try await sut.execute()

        XCTAssertTrue(repositorySpy.getHeroesCalled)
    }

    func test_whenExecute_succeeds_shouldReturnResultFromRepository() async throws {
        let expectedContainer = CharacterDataContainer.fixture(results: [CharacterDataModel.fixture()])
        repositorySpy.result = expectedContainer

        let result = try await sut.execute()

        XCTAssertEqual(result.results.count, expectedContainer.results.count)
    }

    func test_whenExecute_fails_shouldThrowError() async {
        repositorySpy.error = TestError.any

        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(repositorySpy.getHeroesCalled)
        }
    }
}
