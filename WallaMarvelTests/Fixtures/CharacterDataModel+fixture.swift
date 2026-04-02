@testable import WallaMarvel

extension CharacterDataModel {
    static func fixture(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        gender: String = "Male",
        origin: Origin = .fixture(),
        location: Location = .fixture(),
        image: String = "https://example.com/character/1.png",
        episode: [String] = ["https://example.com/episode/1"],
        url: String = "https://example.com/character/1",
        created: String = "2020-01-01T00:00:00.000Z"
    ) -> Self {
        CharacterDataModel(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            origin: origin,
            location: location,
            image: image,
            episode: episode,
            url: url,
            created: created
        )
    }
}
