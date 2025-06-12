import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(viewController.updateProfileDetailsCalled)
        }
    }
    
    func testPresenterCallsUpdateAvatar() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.didUpdateAvatar()
        
        // then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testLogoutButtonCallsConfirmationAlert() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        viewController.didTapButton()
        
        // then
        XCTAssertTrue(presenter.performLogoutCalled)
    }
    
    func testLogoutCallsSwitchToAuth() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.performLogout()
        
        // then
        XCTAssertTrue(viewController.switchToAuthViewControllerCalled)
    }
}
