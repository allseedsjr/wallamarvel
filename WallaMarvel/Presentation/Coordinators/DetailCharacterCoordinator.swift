import UIKit

final class DetailCharacterCoordinator: NavigationCoordinator {
    private let viewController: DetailCharacterViewController

    override var rootViewController: UIViewController { viewController }

    init(navigationController: UINavigationController, viewController: DetailCharacterViewController) {
        self.viewController = viewController
        super.init(navigationController: navigationController)
    }

    @MainActor
    override func start() {
        navigationController.pushViewController(viewController, animated: true)
    }
}
