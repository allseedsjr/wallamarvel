import Foundation

struct CharacterDataContainer: Decodable {
    let info: PageInfo
    let results: [CharacterDataModel]
}
