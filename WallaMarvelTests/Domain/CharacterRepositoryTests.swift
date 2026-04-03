import XCTest
@testable import WallaMarvel

final class CharacterRepositoryTests: XCTestCase {
    private let dataSourceSpy = CharacterDataSourceSpy()
    private lazy var sut = CharacterRepository(dataSource: dataSourceSpy)

    func test_whenGetCharacters_called_shouldCallDataSource() async throws {
        _ = try await sut.getCharacters(page: 1)

        XCTAssertTrue(dataSourceSpy.getCharactersCalled)
    }

    func test_whenGetCharacters_called_shouldPassPageToDataSource() async throws {
        _ = try await sut.getCharacters(page: 3)

        XCTAssertEqual(dataSourceSpy.lastRequestedPage, 3)
    }

    func test_whenGetCharacters_succeeds_shouldReturnResultFromDataSource() async throws {
        let container = CharacterDataContainer.fixture()
        dataSourceSpy.result = container

        let result = try await sut.getCharacters(page: 1)

        XCTAssertEqual(result.characters.count, container.results.count)
    }

    func test_whenGetCharacters_withNextPage_shouldReturnHasNextPageTrue() async throws {
        dataSourceSpy.result = .fixture(next: "https://rickandmortyapi.com/api/character?page=2")

        let result = try await sut.getCharacters(page: 1)

        XCTAssertTrue(result.hasNextPage)
    }

    func test_whenGetCharacters_withoutNextPage_shouldReturnHasNextPageFalse() async throws {
        dataSourceSpy.result = .fixture(next: nil)

        let result = try await sut.getCharacters(page: 42)

        XCTAssertFalse(result.hasNextPage)
    }

    func test_whenGetCharacters_fails_shouldThrowError() async {
        dataSourceSpy.error = TestError.any

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(dataSourceSpy.getCharactersCalled)
        }
    }

    func test_whenGetCharacters_withDataSourceError_shouldThrowAppError() async {
        let appError = AppError.network("Connection failed")
        dataSourceSpy.error = appError

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, appError)
        } catch {
            XCTFail("Expected AppError, got different error type")
        }
    }

    func test_whenGetCharacters_withMappingError_shouldThrowAppError() async {
        dataSourceSpy.result = CharacterDataContainer(
            info: PageInfo.fixture(), results: [.fixture(image: "")]
        )

        do {
            _ = try await sut.getCharacters(page: 1)
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            if case .invalidData = error { } else {
                XCTFail("Expected invalidData error, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError, got different error type")
        }
    }
}
