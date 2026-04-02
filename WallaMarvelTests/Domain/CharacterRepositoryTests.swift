import XCTest
@testable import WallaMarvel

final class CharacterRepositoryTests: XCTestCase {
    private let dataSourceSpy = CharacterDataSourceSpy()
    private lazy var sut = CharacterRepository(dataSource: dataSourceSpy)

    func test_whenGetCharacters_called_shouldCallDataSource() async throws {
        _ = try await sut.getCharacters()

        XCTAssertTrue(dataSourceSpy.getCharactersCalled)
    }

    func test_whenGetCharacters_succeeds_shouldReturnResultFromDataSource() async throws {
        let container = CharacterDataContainer.fixture()
        dataSourceSpy.result = container

        let result = try await sut.getCharacters()

        let expectedCount = container.results.count
        XCTAssertEqual(result.count, expectedCount)
    }

    func test_whenGetCharacters_fails_shouldThrowError() async {
        dataSourceSpy.error = TestError.any

        do {
            _ = try await sut.getCharacters()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(dataSourceSpy.getCharactersCalled)
        }
    }
}
