import XCTest
@testable import WallaMarvel

final class CharacterDataSourceTests: XCTestCase {
    private let apiClientSpy = APIClientSpy()
    private lazy var sut = CharacterDataSource(apiClient: apiClientSpy)

    func test_whenGetCharacters_called_shouldCallAPIClient() async throws {
        _ = try await sut.getCharacters(page: 1)

        XCTAssertTrue(apiClientSpy.getCharactersCalled)
    }

    func test_whenGetCharacters_called_shouldPassPageToAPIClient() async throws {
        _ = try await sut.getCharacters(page: 2)

        XCTAssertEqual(apiClientSpy.lastRequestedPage, 2)
    }

    func test_whenGetCharacters_succeeds_shouldReturnResultFromAPIClient() async throws {
        let expectedContainer = CharacterDataContainer.fixture(results: [.fixture(id: 42)])
        apiClientSpy.result = expectedContainer

        let result = try await sut.getCharacters(page: 1)

        XCTAssertEqual(result.results.count, expectedContainer.results.count)
        XCTAssertEqual(result.results.first?.id, expectedContainer.results.first?.id)
    }

    func test_whenGetCharacters_fails_shouldThrowError() async {
        apiClientSpy.error = TestError.any

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(apiClientSpy.getCharactersCalled)
        }
    }

    func test_whenGetCharacters_withAPIError_shouldMapToAppError() async {
        let urlError = URLError(.notConnectedToInternet)
        apiClientSpy.error = urlError

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            if case .network = error {
            } else {
                XCTFail("Expected network error, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError, got different error type")
        }
    }
}
