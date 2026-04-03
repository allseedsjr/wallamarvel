import Foundation

protocol GetCharacterFirstEpisodeUseCaseProtocol {
    func execute(episodeURL: String) async throws -> Episode
}

struct GetCharacterFirstEpisode: GetCharacterFirstEpisodeUseCaseProtocol {
    private let repository: EpisodeRepositoryProtocol

    init(repository: EpisodeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(episodeURL: String) async throws -> Episode {
        try await repository.getEpisode(url: episodeURL)
    }
}
