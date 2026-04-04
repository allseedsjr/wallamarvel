import UIKit

final class ListCharactersViewController: UIViewController {
    private enum Constants {
        static let paginationThreshold = 5
    }

    private enum Strings {
        static let paginationErrorTitle = "Error loading more"
        static let retry = "Retry"
        static let dismiss = "Dismiss"
        static let searchPlaceholder = "Search characters"
        static let searchAccessibilityLabel = "Search characters"
    }
    var mainView: ListCharactersView { return view as! ListCharactersView }

    var presenter: ListCharactersPresenterProtocol?
    var listCharactersProvider: ListCharactersAdapter?
    weak var coordinator: ListCharactersCoordinatorProtocol?

    private let paginationThreshold = Constants.paginationThreshold
    private var isPaginatingFromScroll = false
    private var searchDebounceTask: Task<Void, Never>?

    private let searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = Strings.searchPlaceholder
        sc.searchBar.accessibilityLabel = Strings.searchAccessibilityLabel
        return sc
    }()

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
        setupSearchController()
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
}

extension ListCharactersViewController: ListCharactersUI {
    func showLoading() {
        mainView.showLoading()
    }

    func hideLoading() {
        mainView.hideLoading()
    }

    func update(characters: [CharacterCellViewModel]) {
        mainView.showCharacters()
        listCharactersProvider?.setCharacters(characters)
    }

    func appendCharacters(_ newCharacters: [CharacterCellViewModel]) {
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

    func showEmptySearch() {
        mainView.showEmptySearch()
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
        guard let character = presenter?.character(at: indexPath.row) else { return }
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

extension ListCharactersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                self?.presenter?.clearSearch()
                self?.mainView.showCharacters()
            } else {
                self?.presenter?.searchCharacters(name: query)
            }
        }
    }
}

extension ListCharactersViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchDebounceTask?.cancel()
        presenter?.clearSearch()
        mainView.showCharacters()
    }
}
