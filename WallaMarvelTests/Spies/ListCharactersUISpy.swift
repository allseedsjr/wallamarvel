import XCTest
@testable import WallaMarvel

final class ListCharactersUISpy: ListCharactersUI {
    private(set) var updatedCharactersCount: Int?
    private(set) var updatedCharacters: [CharacterCellViewModel] = []
    private(set) var appendedCharacters: [CharacterCellViewModel] = []
    private(set) var lastShownError: AppError?
    private(set) var lastPaginationError: AppError?
    private(set) var isLoadingShown: Bool = false
    private(set) var showLoadingWasCalled: Bool = false
    private(set) var hideLoadingWasCalled: Bool = false
    private(set) var isPaginationLoadingShown: Bool = false
    private(set) var showPaginationLoadingWasCalled: Bool = false
    private(set) var showEmptySearchWasCalled: Bool = false
    private let updateExpectation: XCTestExpectation?

    init(updateExpectation: XCTestExpectation? = nil) {
        self.updateExpectation = updateExpectation
    }

    func showLoading() {
        isLoadingShown = true
        showLoadingWasCalled = true
    }

    func hideLoading() {
        isLoadingShown = false
        hideLoadingWasCalled = true
    }

    func update(characters: [CharacterCellViewModel]) {
        updatedCharacters = characters
        updatedCharactersCount = characters.count
        updateExpectation?.fulfill()
    }

    func appendCharacters(_ newCharacters: [CharacterCellViewModel]) {
        appendedCharacters.append(contentsOf: newCharacters)
    }

    func showPaginationLoading() {
        isPaginationLoadingShown = true
        showPaginationLoadingWasCalled = true
    }

    func hidePaginationLoading() {
        isPaginationLoadingShown = false
    }

    func showError(_ error: AppError) {
        lastShownError = error
    }

    func showPaginationError(_ error: AppError) {
        lastPaginationError = error
    }

    func showEmptySearch() {
        showEmptySearchWasCalled = true
    }
}
