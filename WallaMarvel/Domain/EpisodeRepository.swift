import Foundation

protocol EpisodeRepositoryProtocol {
    func getEpisode(url: String) async throws -> Episode
}

final class EpisodeRepository: EpisodeRepositoryProtocol {
    private let dataSource: EpisodeDataSourceProtocol

    init(dataSource: EpisodeDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func getEpisode(url: String) async throws -> Episode {
        do {
            let dataModel = try await dataSource.getEpisode(url: url)
            return dataModel.toDomain()
        } catch let error as AppError {
            throw error
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
