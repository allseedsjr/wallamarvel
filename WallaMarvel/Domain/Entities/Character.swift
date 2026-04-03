import Foundation

enum CharacterMappingError: Error {
    case invalidImageURL
}

struct Character: Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let imageURL: String
    let originName: String
    let locationName: String
    let episodeCount: Int
    let firstEpisodeURL: String?

    init(
        id: Int,
        name: String,
        status: String,
        species: String,
        type: String,
        gender: String,
        imageURL: String,
        originName: String,
        locationName: String,
        episodeCount: Int,
        firstEpisodeURL: String? = nil
    ) throws {
        guard !imageURL.isEmpty,
              let url = URL(string: imageURL),
              url.scheme == "https" || url.scheme == "http" else {
            throw CharacterMappingError.invalidImageURL
        }
        
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.imageURL = imageURL
        self.originName = originName
        self.locationName = locationName
        self.episodeCount = episodeCount
        self.firstEpisodeURL = firstEpisodeURL
    }
}

struct CharactersPage {
    let characters: [Character]
    let hasNextPage: Bool
}
