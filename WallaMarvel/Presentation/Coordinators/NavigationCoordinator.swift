import UIKit

class NavigationCoordinator: NSObject, Coordinator {
    let navigationController: UINavigationController
    var rootViewController: UIViewController {
        fatalError("Subclasses of NavigationCoordinator must override rootViewController")
    }
    private(set) var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor
    func start() {}

    @MainActor
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    @MainActor
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

extension NavigationCoordinator: UINavigationControllerDelegate {
    @MainActor
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard
            let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromViewController)
        else { return }

        childCoordinators.removeAll { $0.rootViewController === fromViewController }
    }
}
