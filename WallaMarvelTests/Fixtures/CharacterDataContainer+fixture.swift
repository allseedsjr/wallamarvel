@testable import WallaMarvel

extension CharacterDataContainer {
    static func fixture(
        info: PageInfo = .fixture(),
        results: [CharacterDataModel] = []
    ) -> Self {
        CharacterDataContainer(info: info, results: results)
    }
}
