@testable import WallaMarvel

extension Character {
    static func fixture(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        gender: String = "Male",
        imageURL: String = "https://example.com/character/1.png",
        originName: String = "Earth",
        locationName: String = "Earth",
        episodeCount: Int = 10,
        firstEpisodeURL: String? = "https://rickandmortyapi.com/api/episode/1"
    ) -> Self {
        try! Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            imageURL: imageURL,
            originName: originName,
            locationName: locationName,
            episodeCount: episodeCount,
            firstEpisodeURL: firstEpisodeURL
        )
    }
}
