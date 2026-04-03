import XCTest
@testable import WallaMarvel

final class GetCharacterFirstEpisodeTests: XCTestCase {
    private let repositorySpy = EpisodeRepositorySpy()
    private lazy var sut = GetCharacterFirstEpisode(repository: repositorySpy)

    // MARK: - request delegation

    func test_whenExecute_called_shouldCallRepository() async throws {
        _ = try await sut.execute(episodeURL: "https://example.com/episode/1")

        XCTAssertTrue(repositorySpy.getEpisodeCalled)
    }

    func test_whenExecute_called_shouldPassURLToRepository() async throws {
        let url = "https://example.com/episode/1"
        _ = try await sut.execute(episodeURL: url)

        XCTAssertEqual(repositorySpy.lastRequestedURL, url)
    }

    // MARK: - result forwarding

    func test_whenExecute_succeeds_shouldReturnEpisode() async throws {
        let expected = Episode.fixture(id: 42, name: "Rickmancing the Stone")
        repositorySpy.result = expected

        let result = try await sut.execute(episodeURL: "https://example.com/episode/42")

        XCTAssertEqual(result.id, expected.id)
        XCTAssertEqual(result.name, expected.name)
    }

    // MARK: - error propagation

    func test_whenExecute_fails_shouldPropagateError() async {
        let appError = AppError.network("No connection")
        repositorySpy.error = appError

        do {
            _ = try await sut.execute(episodeURL: "https://example.com/episode/1")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, appError)
        } catch {
            XCTFail("Expected AppError")
        }
    }
}
