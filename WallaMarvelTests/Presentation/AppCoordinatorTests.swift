import XCTest
@testable import WallaMarvel

@MainActor
final class AppCoordinatorTests: XCTestCase {
    private let navigationController = NavigationControllerSpy()
    private let rootCoordinatorSpy = CoordinatorSpy()
    private lazy var window: UIWindow = UIWindow()
    private lazy var sut = AppCoordinator(
        window: window,
        navigationController: navigationController,
        rootCoordinator: rootCoordinatorSpy
    )

    // MARK: - start

    func test_whenStart_called_shouldSetWindowRootViewController() {
        sut.start()

        XCTAssertTrue(window.rootViewController === navigationController)
    }

    func test_whenStart_called_shouldCallStartOnRootCoordinator() {
        sut.start()

        XCTAssertTrue(rootCoordinatorSpy.startCalled)
    }
}
