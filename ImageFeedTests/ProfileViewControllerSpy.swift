@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    private(set) var didCallUpdateProfileDetails = false
    private(set) var name: String?
    private(set) var loginName: String?
    private(set) var bio: String?
    
    private(set) var didCallUpdateAvatar = false
    private(set) var didCallShowLogoutConfirmationAlert = false
    private(set) var didCallSwitchToAuthViewController = false
    private(set) var didCallShowSplashScreen = false
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        didCallUpdateProfileDetails = true
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
    
    func updateAvatar() {
        didCallUpdateAvatar = true
    }
    
    func showLogoutConfirmationAlert() {
        didCallShowLogoutConfirmationAlert = true
    }
    
    func switchToAuthViewController() {
        didCallSwitchToAuthViewController = true
    }
    
    func showSplashScreen() {
        didCallShowSplashScreen = true
    }
}
