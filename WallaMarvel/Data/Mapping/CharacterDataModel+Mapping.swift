import Foundation

extension CharacterDataModel {
    func toDomain() throws -> Character {
        try Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            imageURL: image,
            originName: origin.name,
            locationName: location.name,
            episodeCount: episode.count,
            firstEpisodeURL: episode.first
        )
    }
}

extension CharacterDataContainer {
    func toDomainCharacters() throws -> [Character] {
        try results.map { try $0.toDomain() }
    }
}
