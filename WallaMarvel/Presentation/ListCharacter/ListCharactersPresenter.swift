import Foundation

@MainActor
protocol ListCharactersPresenterProtocol: AnyObject {
    var ui: ListCharactersUI? { get set }
    func screenTitle() -> String
    func getCharacters() async
    func loadNextPage() async
    func retryNextPage() async
    func searchCharacters(name: String)
    func clearSearch()
}

@MainActor
protocol ListCharactersUI: AnyObject {
    func showLoading()
    func hideLoading()
    func update(characters: [Character])
    func appendCharacters(_ newCharacters: [Character])
    func showPaginationLoading()
    func hidePaginationLoading()
    func showError(_ error: AppError)
    func showPaginationError(_ error: AppError)
    func showEmptySearch()
}

@MainActor
final class ListCharactersPresenter: ListCharactersPresenterProtocol {
    private enum Strings {
        static let screenTitle = "List of Characters"
    }

    var ui: ListCharactersUI?
    private let getCharactersUseCase: GetCharactersUseCaseProtocol

    private var currentPage = 1
    private var hasNextPage = false
    private var isLoadingPage = false
    private var isPaginationBlocked = false
    private var allCharacters: [Character] = []
    private var isSearchActive = false

    init(getCharactersUseCase: GetCharactersUseCaseProtocol) {
        self.getCharactersUseCase = getCharactersUseCase
    }

    func screenTitle() -> String {
        Strings.screenTitle
    }

    func getCharacters() async {
        ui?.showLoading()
        currentPage = 1
        hasNextPage = false
        isLoadingPage = false
        isPaginationBlocked = false
        isSearchActive = false
        allCharacters = []

        do {
            let page = try await getCharactersUseCase.execute(page: currentPage)
            hasNextPage = page.hasNextPage
            allCharacters = page.characters
            ui?.hideLoading()
            ui?.update(characters: allCharacters)
        } catch let error as AppError {
            ui?.hideLoading()
            ui?.showError(error)
        } catch {
            ui?.hideLoading()
            ui?.showError(AppErrorMapper.map(error))
        }
    }

    func loadNextPage() async {
        guard !isLoadingPage, hasNextPage, !isPaginationBlocked, !isSearchActive else { return }

        isLoadingPage = true
        ui?.showPaginationLoading()

        do {
            let page = try await getCharactersUseCase.execute(page: currentPage + 1)
            currentPage += 1
            hasNextPage = page.hasNextPage
            allCharacters.append(contentsOf: page.characters)
            ui?.appendCharacters(page.characters)
        } catch let error as AppError {
            isPaginationBlocked = true
            ui?.showPaginationError(error)
        } catch {
            isPaginationBlocked = true
            ui?.showPaginationError(AppErrorMapper.map(error))
        }

        ui?.hidePaginationLoading()
        isLoadingPage = false
    }

    func retryNextPage() async {
        isPaginationBlocked = false
        await loadNextPage()
    }

    func searchCharacters(name: String) {
        let query = name.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            clearSearch()
            return
        }
        isSearchActive = true
        let filtered = allCharacters.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
        if filtered.isEmpty {
            ui?.showEmptySearch()
        } else {
            ui?.update(characters: filtered)
        }
    }

    func clearSearch() {
        isSearchActive = false
        ui?.update(characters: allCharacters)
    }
}
