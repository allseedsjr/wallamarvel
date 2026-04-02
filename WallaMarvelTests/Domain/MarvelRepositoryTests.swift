import XCTest
@testable import WallaMarvel

final class MarvelRepositoryTests: XCTestCase {
    private let dataSourceSpy = MarvelDataSourceSpy()
    private lazy var sut = MarvelRepository(dataSource: dataSourceSpy)

    func test_whenGetHeroes_called_shouldCallDataSource() async throws {
        _ = try await sut.getHeroes()

        XCTAssertTrue(dataSourceSpy.getHeroesCalled)
    }

    func test_whenGetHeroes_succeeds_shouldReturnResultFromDataSource() async throws {
        let expectedContainer = CharacterDataContainer.fixture(results: [CharacterDataModel.fixture()])
        dataSourceSpy.result = expectedContainer

        let result = try await sut.getHeroes()

        XCTAssertEqual(result.count, expectedContainer.results.count)
    }

    func test_whenGetHeroes_fails_shouldThrowError() async {
        dataSourceSpy.error = TestError.any

        do {
            _ = try await sut.getHeroes()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(dataSourceSpy.getHeroesCalled)
        }
    }
}
