import XCTest
@testable import WallaMarvel

final class EpisodeRepositoryTests: XCTestCase {
    private let dataSourceSpy = EpisodeDataSourceSpy()
    private lazy var sut = EpisodeRepository(dataSource: dataSourceSpy)

    // MARK: - request delegation

    func test_whenGetEpisode_called_shouldCallDataSource() async throws {
        _ = try await sut.getEpisode(url: "https://example.com/episode/1")

        XCTAssertTrue(dataSourceSpy.getEpisodeCalled)
    }

    func test_whenGetEpisode_called_shouldPassURLToDataSource() async throws {
        let url = "https://example.com/episode/1"
        _ = try await sut.getEpisode(url: url)

        XCTAssertEqual(dataSourceSpy.lastRequestedURL, url)
    }

    // MARK: - domain mapping

    func test_whenGetEpisode_succeeds_shouldMapToDomain() async throws {
        let dataModel = EpisodeDataModel.fixture(id: 42, name: "Pilot", airDate: "December 2, 2013", episode: "S01E01")
        dataSourceSpy.result = dataModel

        let result = try await sut.getEpisode(url: "https://example.com/episode/1")

        XCTAssertEqual(result.id, 42)
        XCTAssertEqual(result.name, "Pilot")
        XCTAssertEqual(result.airDate, "December 2, 2013")
        XCTAssertEqual(result.code, "S01E01")
    }

    // MARK: - error handling

    func test_whenGetEpisode_withAppError_shouldRethrow() async {
        let appError = AppError.network("Connection failed")
        dataSourceSpy.error = appError

        do {
            _ = try await sut.getEpisode(url: "https://example.com/episode/1")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, appError)
        } catch {
            XCTFail("Expected AppError")
        }
    }

    func test_whenGetEpisode_withUnknownError_shouldMapToUnknownAppError() async {
        dataSourceSpy.error = TestError.any

        do {
            _ = try await sut.getEpisode(url: "https://example.com/episode/1")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            if case .unknown = error { } else {
                XCTFail("Expected .unknown error, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError")
        }
    }
}
