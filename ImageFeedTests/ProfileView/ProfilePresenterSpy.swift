import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didUpdateAvatarCalled = false
    var performLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateAvatar() {
        didUpdateAvatarCalled = true
    }
    
    func performLogout() {
        performLogoutCalled = true
    }
}
