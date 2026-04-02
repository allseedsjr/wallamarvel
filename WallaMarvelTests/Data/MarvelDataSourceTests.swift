import XCTest
@testable import WallaMarvel

final class MarvelDataSourceTests: XCTestCase {
    private let apiClientSpy = APIClientSpy()
    private lazy var sut = MarvelDataSource(apiClient: apiClientSpy)

    func test_whenGetHeroes_called_shouldCallAPIClient() async throws {
        _ = try await sut.getHeroes()

        XCTAssertTrue(apiClientSpy.getHeroesCalled)
    }

    func test_whenGetHeroes_succeeds_shouldReturnResultFromAPIClient() async throws {
        let expectedContainer = CharacterDataContainer.fixture(results: [CharacterDataModel.fixture()])
        apiClientSpy.result = expectedContainer

        let result = try await sut.getHeroes()

        XCTAssertEqual(result.results.count, expectedContainer.results.count)
    }

    func test_whenGetHeroes_fails_shouldThrowError() async {
        apiClientSpy.error = TestError.any

        do {
            _ = try await sut.getHeroes()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(apiClientSpy.getHeroesCalled)
        }
    }
}
