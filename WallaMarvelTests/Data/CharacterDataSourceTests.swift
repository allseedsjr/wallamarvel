import XCTest
@testable import WallaMarvel

final class CharacterDataSourceTests: XCTestCase {
    private let apiClientSpy = APIClientSpy()
    private lazy var sut = CharacterDataSource(apiClient: apiClientSpy)

    // MARK: - request delegation

    func test_whenGetCharacters_called_shouldCallAPIClient() async throws {
        apiClientSpy.resultProvider = { _ in CharacterDataContainer.fixture() }

        _ = try await sut.getCharacters(page: 1)

        XCTAssertTrue(apiClientSpy.requestCalled)
    }

    // MARK: - result forwarding

    func test_whenGetCharacters_succeeds_shouldReturnResultFromAPIClient() async throws {
        let expectedContainer = CharacterDataContainer.fixture(results: [.fixture(id: 42)])
        apiClientSpy.resultProvider = { _ in expectedContainer }

        let result = try await sut.getCharacters(page: 1)

        XCTAssertEqual(result.results.count, expectedContainer.results.count)
        XCTAssertEqual(result.results.first?.id, expectedContainer.results.first?.id)
    }

    // MARK: - error handling

    func test_whenGetCharacters_fails_shouldThrowError() async {
        apiClientSpy.error = TestError.any

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(apiClientSpy.requestCalled)
        }
    }

    func test_whenGetCharacters_withAPIError_shouldMapToNetworkAppError() async {
        apiClientSpy.error = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            if case .network = error { } else {
                XCTFail("Expected .network error, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError, got different error type")
        }
    }
}
