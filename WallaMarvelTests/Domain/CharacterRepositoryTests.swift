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
    
    func test_whenGetCharacters_withDataSourceError_shouldThrowAppError() async {
        let appError = AppError.network("Connection failed")
        dataSourceSpy.error = appError

        do {
            _ = try await sut.getCharacters()
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, appError)
        } catch {
            XCTFail("Expected AppError, got different error type")
        }
    }
    
    func test_whenGetCharacters_withMappingError_shouldThrowAppError() async {
        dataSourceSpy.result = CharacterDataContainer(
            results: [
                CharacterDataModel.fixture(image: "")
            ],
            info: PageInfo.fixture()
        )

        do {
            _ = try await sut.getCharacters()
            XCTFail("Expected AppError to be thrown")
        } catch let error as AppError {
            if case .invalidData = error {
            } else {
                XCTFail("Expected invalidData error, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError, got different error type")
        }
    }
}
