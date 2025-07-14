import UIKit
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showLogoutConfirmationAlertCalled = false
    var switchToAuthViewControllerCalled = false
    var showSplashScreenCalled = false
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func showLogoutConfirmationAlert() {
        showLogoutConfirmationAlertCalled = true
    }
    
    func switchToAuthViewController() {
        switchToAuthViewControllerCalled = true
    }
    
    func showSplashScreen() {
        showSplashScreenCalled = true
    }
}
