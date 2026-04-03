import UIKit

final class ListCharactersViewController: UIViewController {
    var mainView: ListCharactersView { return view as! ListCharactersView }

    var presenter: ListCharactersPresenterProtocol?
    var listCharactersProvider: ListCharactersAdapter?

    private let paginationThreshold = 5
    private var isPaginatingFromScroll = false

    override func loadView() {
        view = ListCharactersView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listCharactersProvider = mainView.configureTableView(delegate: self)
        presenter?.ui = self
        Task { [weak self] in
            await self?.presenter?.getCharacters()
        }

        title = presenter?.screenTitle()
    }
}

extension ListCharactersViewController: ListCharactersUI {
    func showLoading() {
        mainView.showLoading()
    }

    func hideLoading() {
        mainView.hideLoading()
    }

    func update(characters: [Character]) {
        mainView.showCharacters()
        listCharactersProvider?.setCharacters(characters)
    }

    func appendCharacters(_ newCharacters: [Character]) {
        listCharactersProvider?.appendCharacters(newCharacters)
    }

    func showPaginationLoading() {
        listCharactersProvider?.showLoadingFooter()
    }

    func hidePaginationLoading() {
        listCharactersProvider?.hideLoadingFooter()
    }

    func showError(_ error: AppError) {
        mainView.showError(message: error.userMessage)
        mainView.setRetryEnabled(true)
        mainView.setRetryTarget(self, action: #selector(handleRetryTap))
    }

    func showPaginationError(_ error: AppError) {
        let alert = UIAlertController(
            title: "Error loading more",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            Task { [weak self] in await self?.presenter?.retryNextPage() }
        })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }

    @objc
    private func handleRetryTap() {
        mainView.setRetryEnabled(false)
        Task { [weak self] in
            await self?.presenter?.getCharacters()
        }
    }
}

extension ListCharactersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: add navigation in another task
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isPaginatingFromScroll else { return }
        let total = tableView.numberOfRows(inSection: 0)
        guard total > 0, indexPath.row >= total - paginationThreshold else { return }
        isPaginatingFromScroll = true
        Task { @MainActor [weak self] in
            await self?.presenter?.loadNextPage()
            self?.isPaginatingFromScroll = false
        }
    }
}
