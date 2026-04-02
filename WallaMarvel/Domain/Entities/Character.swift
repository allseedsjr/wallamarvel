import Foundation

enum CharacterMappingError: Error {
    case invalidImageURL
}

struct Character: Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let imageURL: String
    let originName: String
    let locationName: String
    let episodeCount: Int
    
    init(
        id: Int,
        name: String,
        status: String,
        species: String,
        gender: String,
        imageURL: String,
        originName: String,
        locationName: String,
        episodeCount: Int
    ) throws {
        guard !imageURL.isEmpty, URL(string: imageURL) != nil else {
            throw CharacterMappingError.invalidImageURL
        }
        
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.gender = gender
        self.imageURL = imageURL
        self.originName = originName
        self.locationName = locationName
        self.episodeCount = episodeCount
    }
}
