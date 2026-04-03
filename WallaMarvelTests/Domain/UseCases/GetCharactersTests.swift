import XCTest
@testable import WallaMarvel

final class GetCharactersTests: XCTestCase {
    private let repositorySpy = CharacterRepositorySpy()
    private lazy var sut = GetCharacters(repository: repositorySpy)

    func test_whenExecute_called_shouldCallRepository() async throws {
        _ = try await sut.execute(page: 1)

        XCTAssertTrue(repositorySpy.getCharactersCalled)
    }

    func test_whenExecute_called_shouldPassPageToRepository() async throws {
        _ = try await sut.execute(page: 3)

        XCTAssertEqual(repositorySpy.lastRequestedPage, 3)
    }

    func test_whenExecute_succeeds_shouldReturnResultFromRepository() async throws {
        let expectedCharacters = [Character.fixture()]
        repositorySpy.pageResult = CharactersPage(characters: expectedCharacters, hasNextPage: false)

        let result = try await sut.execute(page: 1)

        XCTAssertEqual(result.characters.count, expectedCharacters.count)
    }

    func test_whenExecute_withNextPage_shouldReturnHasNextPageTrue() async throws {
        repositorySpy.pageResult = CharactersPage(characters: [], hasNextPage: true)

        let result = try await sut.execute(page: 1)

        XCTAssertTrue(result.hasNextPage)
    }

    func test_whenExecute_fails_shouldThrowError() async {
        repositorySpy.error = TestError.any

        do {
            _ = try await sut.execute(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(repositorySpy.getCharactersCalled)
        }
    }
}
