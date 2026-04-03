import XCTest
@testable import WallaMarvel

@MainActor
final class DetailCharacterCoordinatorTests: XCTestCase {
    private let navigationController = NavigationControllerSpy()
    private let detailViewController = DetailCharacterViewController(character: .fixture())
    private lazy var sut = DetailCharacterCoordinator(
        navigationController: navigationController,
        viewController: detailViewController
    )

    // MARK: - rootViewController

    func test_rootViewController_shouldBeDetailCharacterViewController() {
        XCTAssertTrue(sut.rootViewController === detailViewController)
    }

    // MARK: - start

    func test_whenStart_called_shouldPushDetailViewControllerIntoNavigationStack() {
        sut.start()

        XCTAssertTrue(navigationController.pushedViewControllers.contains(detailViewController))
    }

    func test_whenStart_called_shouldPushWithAnimation() {
        sut.start()

        XCTAssertEqual(navigationController.pushAnimated.first, true)
    }
}
