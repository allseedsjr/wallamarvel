@testable import WallaMarvel

final class ListCharactersPresenterSpy: ListCharactersPresenterProtocol {
    var ui: ListCharactersUI?
    private(set) var screenTitleCalled = false
    private(set) var getCharactersCalled = false
    private(set) var loadNextPageCalled = false
    private(set) var retryNextPageCalled = false

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
}
