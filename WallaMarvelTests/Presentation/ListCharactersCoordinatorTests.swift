import XCTest
@testable import WallaMarvel

@MainActor
final class ListCharactersCoordinatorTests: XCTestCase {
    private let navigationController = NavigationControllerSpy()
    private let viewController = ListCharactersViewController()
    private let presenter = ListCharactersPresenterSpy()
    private lazy var sut = ListCharactersCoordinator(
        navigationController: navigationController,
        viewController: viewController,
        presenter: presenter
    )

    // MARK: - start

    func test_whenStart_called_shouldPushViewControllerIntoNavigationStack() {
        sut.start()

        XCTAssertTrue(navigationController.pushedViewControllers.contains(viewController))
    }

    func test_whenStart_called_shouldPushWithoutAnimation() {
        sut.start()

        XCTAssertEqual(navigationController.pushAnimated.first, false)
    }

    func test_whenStart_called_shouldAssignPresenterToViewController() {
        sut.start()

        XCTAssertTrue(viewController.presenter === presenter as AnyObject)
    }

    func test_whenStart_called_shouldAssignCoordinatorToViewController() {
        sut.start()

        XCTAssertTrue(viewController.coordinator === sut)
    }

    func test_whenStart_called_shouldSetNavigationControllerDelegate() {
        sut.start()

        XCTAssertTrue(navigationController.delegate === sut)
    }

    // MARK: - showDetail

    func test_whenShowDetail_called_shouldAddDetailCoordinatorToChildCoordinators() {
        sut.start()
        sut.showDetail(for: .fixture())

        XCTAssertEqual(sut.childCoordinators.count, 1)
        XCTAssertTrue(sut.childCoordinators.first is DetailCharacterCoordinator)
    }

    func test_whenShowDetail_called_shouldPushDetailViewControllerIntoNavigationStack() {
        sut.start()
        sut.showDetail(for: .fixture())

        XCTAssertTrue(navigationController.pushedViewControllers.contains { $0 is DetailCharacterViewController })
    }

    func test_whenShowDetail_calledMultipleTimes_shouldAccumulateChildCoordinators() {
        sut.start()
        sut.showDetail(for: .fixture())
        sut.showDetail(for: .fixture(id: 2))

        XCTAssertEqual(sut.childCoordinators.count, 2)
    }
}
