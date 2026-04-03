import UIKit

protocol ListCharactersCoordinatorProtocol: AnyObject {
    @MainActor func showDetail(for character: Character)
}

final class ListCharactersCoordinator: NavigationCoordinator {
    private let viewController: ListCharactersViewController
    private let presenter: ListCharactersPresenterProtocol

    override var rootViewController: UIViewController { viewController }

    init(
        navigationController: UINavigationController,
        viewController: ListCharactersViewController,
        presenter: ListCharactersPresenterProtocol
    ) {
        self.viewController = viewController
        self.presenter = presenter
        super.init(navigationController: navigationController)
    }

    @MainActor
    override func start() {
        viewController.presenter = presenter
        viewController.coordinator = self
        navigationController.delegate = self
        navigationController.pushViewController(viewController, animated: false)
    }
}

extension ListCharactersCoordinator: ListCharactersCoordinatorProtocol {
    @MainActor
    func showDetail(for character: Character) {
        let apiClient = APIClient()
        let episodeDataSource = EpisodeDataSource(apiClient: apiClient)
        let episodeRepository = EpisodeRepository(dataSource: episodeDataSource)
        let getFirstEpisodeUseCase = GetCharacterFirstEpisode(repository: episodeRepository)
        let presenter = DetailCharacterPresenter(character: character, getFirstEpisodeUseCase: getFirstEpisodeUseCase)
        let detailViewController = DetailCharacterViewController(character: character, presenter: presenter)
        presenter.ui = detailViewController
        let coordinator = DetailCharacterCoordinator(
            navigationController: navigationController,
            viewController: detailViewController
        )
        addChild(coordinator)
    }
}
