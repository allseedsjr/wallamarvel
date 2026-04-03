import UIKit
@testable import WallaMarvel

final class CoordinatorSpy: Coordinator {
    let navigationController: UINavigationController
    private(set) var rootViewControllerValue: UIViewController
    var rootViewController: UIViewController { rootViewControllerValue }
    private(set) var startCalled = false

    init(navigationController: UINavigationController = UINavigationController(), rootViewController: UIViewController = UIViewController()) {
        self.navigationController = navigationController
        self.rootViewControllerValue = rootViewController
    }

    func start() {
        startCalled = true
    }
}
