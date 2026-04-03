import Foundation

@MainActor
protocol ListCharactersPresenterProtocol: AnyObject {
    var ui: ListCharactersUI? { get set }
    func screenTitle() -> String
    func getCharacters() async
    func loadNextPage() async
    func retryNextPage() async
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
}

@MainActor
final class ListCharactersPresenter: ListCharactersPresenterProtocol {
    var ui: ListCharactersUI?
    private let getCharactersUseCase: GetCharactersUseCaseProtocol

    private var currentPage = 1
    private var hasNextPage = false
    private var isLoadingPage = false
    private var isPaginationBlocked = false

    init(getCharactersUseCase: GetCharactersUseCaseProtocol) {
        self.getCharactersUseCase = getCharactersUseCase
    }

    func screenTitle() -> String {
        "List of Characters"
    }

    func getCharacters() async {
        ui?.showLoading()
        currentPage = 1
        hasNextPage = false
        isLoadingPage = false
        isPaginationBlocked = false

        do {
            let page = try await getCharactersUseCase.execute(page: currentPage)
            hasNextPage = page.hasNextPage
            ui?.hideLoading()
            ui?.update(characters: page.characters)
        } catch let error as AppError {
            ui?.hideLoading()
            ui?.showError(error)
        } catch {
            ui?.hideLoading()
            ui?.showError(AppErrorMapper.map(error))
        }
    }

    func loadNextPage() async {
        guard !isLoadingPage, hasNextPage, !isPaginationBlocked else { return }

        isLoadingPage = true
        ui?.showPaginationLoading()

        do {
            let page = try await getCharactersUseCase.execute(page: currentPage + 1)
            currentPage += 1
            hasNextPage = page.hasNextPage
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
}
