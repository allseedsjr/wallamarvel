import Foundation

extension EpisodeDataModel {
    func toDomain() -> Episode {
        Episode(id: id, name: name, airDate: airDate, code: episode)
    }
}
