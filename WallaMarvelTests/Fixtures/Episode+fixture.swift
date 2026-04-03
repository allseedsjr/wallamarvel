@testable import WallaMarvel

extension Episode {
    static func fixture(
        id: Int = 1,
        name: String = "Pilot",
        airDate: String = "December 2, 2013",
        code: String = "S01E01"
    ) -> Self {
        Episode(id: id, name: name, airDate: airDate, code: code)
    }
}
