import UIKit

final class ListCharactersViewController: UIViewController {
    var mainView: ListCharactersView { return view as! ListCharactersView  }
    
    var presenter: ListCharactersPresenterProtocol?
    var listCharactersProvider: ListCharactersAdapter?
    
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
        listCharactersProvider?.characters = characters
    }
    
    func showError(_ error: AppError) {
        mainView.showError(message: error.userMessage)
        mainView.setRetryEnabled(true)
        mainView.setRetryTarget(self, action: #selector(handleRetryTap))
    }
    
    @objc
    private func handleRetryTap() {
        mainView.setRetryEnabled(false)
        showLoading()
        Task { [weak self] in
            await self?.presenter?.getCharacters()
        }
    }
}

extension ListCharactersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let presenter = ListCharactersPresenter()
        let listCharactersViewController = ListCharactersViewController()
        listCharactersViewController.presenter = presenter
        
        // TODO: add navigation in another task
    }
}
