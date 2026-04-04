@testable import WallaMarvel

final class ListCharactersPresenterSpy: ListCharactersPresenterProtocol {
    var ui: ListCharactersUI?
    private(set) var screenTitleCalled = false
    private(set) var getCharactersCalled = false
    private(set) var loadNextPageCalled = false
    private(set) var retryNextPageCalled = false
    private(set) var searchCharactersCalled = false
    private(set) var lastSearchedName: String?
    private(set) var clearSearchCalled = false

    private(set) var characterAtIndexCalled = false
    private(set) var lastRequestedIndex: Int?

    func screenTitle() -> String {
        screenTitleCalled = true
        return "Characters"
    }

    func getCharacters() async {
        getCharactersCalled = true
    }

    func loadNextPage() async {
        loadNextPageCalled = true
    }

    func retryNextPage() async {
        retryNextPageCalled = true
    }

    func searchCharacters(name: String) {
        searchCharactersCalled = true
        lastSearchedName = name
    }

    func clearSearch() {
        clearSearchCalled = true
    }

    func character(at index: Int) -> Character? {
        characterAtIndexCalled = true
        lastRequestedIndex = index
        return nil
    }
}
