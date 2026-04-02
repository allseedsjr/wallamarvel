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
        let expectedHeroes = [Character.fixture()]
        repositorySpy.result = expectedHeroes

        let result = try await sut.execute()

        XCTAssertEqual(result.count, expectedHeroes.count)
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
