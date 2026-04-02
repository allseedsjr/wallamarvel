import XCTest
@testable import WallaMarvel

final class CharacterDataSourceTests: XCTestCase {
    private let apiClientSpy = APIClientSpy()
    private lazy var sut = CharacterDataSource(apiClient: apiClientSpy)

    func test_whenGetCharacters_called_shouldCallAPIClient() async throws {
        _ = try await sut.getCharacters()

        XCTAssertTrue(apiClientSpy.getCharactersCalled)
    }

    func test_whenGetCharacters_succeeds_shouldReturnResultFromAPIClient() async throws {
        let expectedContainer = CharacterDataContainer.fixture()
        apiClientSpy.result = expectedContainer

        let result = try await sut.getCharacters()

        XCTAssertEqual(result, expectedContainer)
    }

    func test_whenGetCharacters_fails_shouldThrowError() async {
        apiClientSpy.error = TestError.any

        do {
            _ = try await sut.getCharacters()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(apiClientSpy.getCharactersCalled)
        }
    }
}
