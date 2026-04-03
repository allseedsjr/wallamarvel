import XCTest
@testable import WallaMarvel

final class ListCharactersUISpy: ListCharactersUI {
    private(set) var updatedCharactersCount: Int?
    private(set) var lastShownError: AppError?
    private(set) var isLoadingShown: Bool = false
    private let updateExpectation: XCTestExpectation?

    init(updateExpectation: XCTestExpectation? = nil) {
        self.updateExpectation = updateExpectation
    }

    func showLoading() {
        isLoadingShown = true
    }
    
    func hideLoading() {
        isLoadingShown = false
    }

    func update(characters: [Character]) {
        updatedCharactersCount = characters.count
        updateExpectation?.fulfill()
    }
    
    func showError(_ error: AppError) {
        lastShownError = error
    }
}
}
