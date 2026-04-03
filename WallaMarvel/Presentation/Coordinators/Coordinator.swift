import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var rootViewController: UIViewController { get }
    @MainActor func start()
}
