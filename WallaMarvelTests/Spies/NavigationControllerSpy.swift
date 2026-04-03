import UIKit
@testable import WallaMarvel

final class NavigationControllerSpy: UINavigationController {
    private(set) var pushedViewControllers: [UIViewController] = []
    private(set) var pushAnimated: [Bool] = []

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        pushAnimated.append(animated)
    }
}
