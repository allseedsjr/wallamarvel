import XCTest
@testable import WallaMarvel

final class ListHeroesUISpy: ListHeroesUI {
    private(set) var updatedHeroesCount: Int?
    private let updateExpectation: XCTestExpectation?

    init(updateExpectation: XCTestExpectation? = nil) {
        self.updateExpectation = updateExpectation
    }

    func update(heroes: [CharacterDataModel]) {
        updatedHeroesCount = heroes.count
        updateExpectation?.fulfill()
    }
}
