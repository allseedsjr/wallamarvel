import UIKit

final class ListCharactersViewController: UIViewController {
    private enum Constants {
        static let paginationThreshold = 5
    }

    private enum Strings {
        static let paginationErrorTitle = "Error loading more"
        static let retry = "Retry"
        static let dismiss = "Dismiss"
    }
    var mainView: ListCharactersView { return view as! ListCharactersView }

    var presenter: ListCharactersPresenterProtocol?
    var listCharactersProvider: ListCharactersAdapter?
    weak var coordinator: ListCharactersCoordinatorProtocol?

    private let paginationThreshold = Constants.paginationThreshold
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
            title: Strings.paginationErrorTitle,
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.retry, style: .default) { [weak self] _ in
            Task { [weak self] in await self?.presenter?.retryNextPage() }
        })
        alert.addAction(UIAlertAction(title: Strings.dismiss, style: .cancel))
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
        guard let character = listCharactersProvider?.characters[indexPath.row] else { return }
        coordinator?.showDetail(for: character)
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
