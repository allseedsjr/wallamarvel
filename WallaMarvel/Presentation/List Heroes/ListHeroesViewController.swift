import UIKit

final class ListHeroesViewController: UIViewController {
    var mainView: ListHeroesView { return view as! ListHeroesView  }
    
    var presenter: ListHeroesPresenterProtocol?
    var listHeroesProvider: ListHeroesAdapter?
    
    override func loadView() {
        view = ListHeroesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        listHeroesProvider = ListHeroesAdapter(tableView: mainView.heroesTableView)
        presenter?.ui = self
        Task { [weak self] in
            await self?.presenter?.getHeroes()
        }
        
        title = presenter?.screenTitle()
        
        mainView.heroesTableView.delegate = self
    }
}

extension ListHeroesViewController: ListHeroesUI {
    func update(heroes: [CharacterDataModel]) {
        listHeroesProvider?.heroes = heroes
    }
}

extension ListHeroesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let presenter = ListHeroesPresenter()
        let listHeroesViewController = ListHeroesViewController()
        listHeroesViewController.presenter = presenter
        
        // TODO: add navigation in another task
    }
}
