import Foundation

protocol EpisodeDataSourceProtocol {
    func getEpisode(url: String) async throws -> EpisodeDataModel
}

final class EpisodeDataSource: EpisodeDataSourceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getEpisode(url: String) async throws -> EpisodeDataModel {
        do {
            return try await apiClient.request(GetEpisodeRequest(urlString: url))
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
