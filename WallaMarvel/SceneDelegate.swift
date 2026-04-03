import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    @MainActor
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navigationController = UINavigationController()
        let presenter = ListCharactersPresenter()
        let listViewController = ListCharactersViewController()
        let listCoordinator = ListCharactersCoordinator(
            navigationController: navigationController,
            viewController: listViewController,
            presenter: presenter
        )
        let coordinator = AppCoordinator(
            window: window,
            navigationController: navigationController,
            rootCoordinator: listCoordinator
        )
        appCoordinator = coordinator
        coordinator.start()
    }
}

