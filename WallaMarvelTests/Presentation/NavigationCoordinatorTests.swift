import XCTest
@testable import WallaMarvel

@MainActor
final class NavigationCoordinatorTests: XCTestCase {
    private let navigationController = UINavigationController()
    private lazy var sut = NavigationCoordinatorSpy(navigationController: navigationController)

    // MARK: - addChild

    func test_whenAddChild_called_shouldAppendToChildCoordinators() {
        let child = CoordinatorSpy()

        sut.addChild(child)

        XCTAssertEqual(sut.childCoordinators.count, 1)
    }

    func test_whenAddChild_called_shouldCallStartOnCoordinator() {
        let child = CoordinatorSpy()

        sut.addChild(child)

        XCTAssertTrue(child.startCalled)
    }

    func test_whenAddChild_calledMultipleTimes_shouldAccumulateChildren() {
        sut.addChild(CoordinatorSpy())
        sut.addChild(CoordinatorSpy())

        XCTAssertEqual(sut.childCoordinators.count, 2)
    }

    // MARK: - removeChild

    func test_whenRemoveChild_called_shouldRemoveFromChildCoordinators() {
        let child = CoordinatorSpy()
        sut.addChild(child)

        sut.removeChild(child)

        XCTAssertTrue(sut.childCoordinators.isEmpty)
    }

    func test_whenRemoveChild_calledWithUnknownCoordinator_shouldNotAffectChildCoordinators() {
        let child = CoordinatorSpy()
        let other = CoordinatorSpy()
        sut.addChild(child)

        sut.removeChild(other)

        XCTAssertEqual(sut.childCoordinators.count, 1)
    }
}

// MARK: - Concrete subclass for testing (fatalError override)

private final class NavigationCoordinatorSpy: NavigationCoordinator {
    override var rootViewController: UIViewController { navigationController }
}
