@testable import WallaMarvel

extension Character {
    static func fixture(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        gender: String = "Male",
        imageURL: String = "https://example.com/character/1.png",
        originName: String = "Earth",
        locationName: String = "Earth",
        episodeCount: Int = 10
    ) -> Self {
        try! Character(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            imageURL: imageURL,
            originName: originName,
            locationName: locationName,
            episodeCount: episodeCount
        )
    }
}
