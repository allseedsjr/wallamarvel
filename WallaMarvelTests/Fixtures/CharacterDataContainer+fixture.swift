@testable import WallaMarvel

extension CharacterDataContainer {
    static func fixture(
        info: PageInfo = .fixture(),
        results: [CharacterDataModel] = []
    ) -> Self {
        CharacterDataContainer(info: info, results: results)
    }

    static func fixture(next: String?) -> Self {
        CharacterDataContainer(info: .fixture(next: next), results: [CharacterDataModel.fixture()])
    }
}
