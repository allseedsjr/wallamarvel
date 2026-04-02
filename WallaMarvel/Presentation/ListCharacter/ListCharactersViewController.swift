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
        listCharactersProvider = ListCharactersAdapter(tableView: mainView.charactersTableView)
        presenter?.ui = self
        Task { [weak self] in
            await self?.presenter?.getCharacters()
        }
        
        title = presenter?.screenTitle()
        
        mainView.charactersTableView.delegate = self
    }
}

extension ListCharactersViewController: ListCharactersUI {
    func update(characters: [Character]) {
        listCharactersProvider?.characters = characters
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
