import XCTest
@testable import WallaMarvel

final class EpisodeDataSourceTests: XCTestCase {
    private let apiClientSpy = APIClientSpy()
    private lazy var sut = EpisodeDataSource(apiClient: apiClientSpy)

    // MARK: - request delegation

    func test_whenGetEpisode_called_shouldCallAPIClient() async throws {
        apiClientSpy.resultProvider = { _ in EpisodeDataModel.fixture() }

        _ = try await sut.getEpisode(url: "https://rickandmortyapi.com/api/episode/1")

        XCTAssertTrue(apiClientSpy.requestCalled)
    }

    // MARK: - URL passthrough

    func test_whenGetEpisode_called_shouldPassCorrectURL() async throws {
        let episodeURL = "https://rickandmortyapi.com/api/episode/1"
        apiClientSpy.resultProvider = { _ in EpisodeDataModel.fixture() }

        _ = try await sut.getEpisode(url: episodeURL)

        let requestedURL = try XCTUnwrap(apiClientSpy.lastRequest?.makeURL())
        XCTAssertEqual(requestedURL.absoluteString, episodeURL)
    }

    // MARK: - result forwarding

    func test_whenGetEpisode_succeeds_shouldReturnResultFromAPIClient() async throws {
        let expected = EpisodeDataModel.fixture(id: 1, name: "Pilot")
        apiClientSpy.resultProvider = { _ in expected }

        let result = try await sut.getEpisode(url: "https://rickandmortyapi.com/api/episode/1")

        XCTAssertEqual(result.id, expected.id)
        XCTAssertEqual(result.name, expected.name)
    }

    // MARK: - error handling

    func test_whenGetEpisode_withURLError_shouldMapToNetworkAppError() async {
        apiClientSpy.error = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.getEpisode(url: "https://rickandmortyapi.com/api/episode/1")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            if case .network = error { } else {
                XCTFail("Expected .network error, got \(error)")
            }
        } catch {
            XCTFail("Expected AppError")
        }
    }

    func test_whenGetEpisode_withAppError_shouldRethrow() async {
        let appError = AppError.decoding("Decoding failed")
        apiClientSpy.error = appError

        do {
            _ = try await sut.getEpisode(url: "https://rickandmortyapi.com/api/episode/1")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, appError)
        } catch {
            XCTFail("Expected AppError")
        }
    }
}
