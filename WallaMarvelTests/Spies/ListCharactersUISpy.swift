import XCTest
@testable import WallaMarvel

final class ListCharactersUISpy: ListCharactersUI {
    private(set) var updatedCharactersCount: Int?
    private let updateExpectation: XCTestExpectation?

    init(updateExpectation: XCTestExpectation? = nil) {
        self.updateExpectation = updateExpectation
    }

    func update(characters: [Character]) {
        updatedCharactersCount = characters.count
        updateExpectation?.fulfill()
    }
}
