@testable import WallaMarvel

extension EpisodeDataModel {
    static func fixture(
        id: Int = 1,
        name: String = "Pilot",
        airDate: String = "December 2, 2013",
        episode: String = "S01E01"
    ) -> Self {
        EpisodeDataModel(id: id, name: name, airDate: airDate, episode: episode)
    }
}
