import XCTest
@testable import WallaMarvel

final class GetCharactersTests: XCTestCase {
    private let repositorySpy = CharacterRepositorySpy()
    private lazy var sut = GetCharacters(repository: repositorySpy)

    func test_whenExecute_called_shouldCallRepository() async throws {
        _ = try await sut.execute()

        XCTAssertTrue(repositorySpy.getCharactersCalled)
    }

    func test_whenExecute_succeeds_shouldReturnResultFromRepository() async throws {
        let expectedCharacters = [Character.fixture()]
        repositorySpy.result = expectedCharacters

        let result = try await sut.execute()

        XCTAssertEqual(result.count, expectedCharacters.count)
    }

    func test_whenExecute_fails_shouldThrowError() async {
        repositorySpy.error = TestError.any

        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(repositorySpy.getCharactersCalled)
        }
    }
}
