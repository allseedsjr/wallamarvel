import UIKit

final class AppCoordinator: NavigationCoordinator {
    private let window: UIWindow
    private let rootCoordinator: Coordinator

    override var rootViewController: UIViewController { navigationController }

    init(window: UIWindow, navigationController: UINavigationController, rootCoordinator: Coordinator) {
        self.window = window
        self.rootCoordinator = rootCoordinator
        super.init(navigationController: navigationController)
    }

    @MainActor
    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        addChild(rootCoordinator)
    }
}
