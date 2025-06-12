//@testable import ImageFeed
//
//final class ProfilePresenterSpy: ProfilePresenterProtocol {
//    weak var view: ProfileViewControllerProtocol?
//    
//    private(set) var didCallViewDidLoad = false
//    private(set) var didCallDidUpdateAvatar = false
//    private(set) var didCallShowLogoutConfirmationAlert = false
//    private(set) var didCallPerformLogout = false
//    private(set) var didCallExitProfile = false
//    
//    
//    func viewDidLoad() {
//        didCallViewDidLoad = true
//    }
//    
//    func didUpdateAvatar() {
//        didCallDidUpdateAvatar = true
//    }
//    
//    func showLogoutConfirmationAlert() {
//        didCallShowLogoutConfirmationAlert = true
//        view?.showLogoutConfirmationAlert()
//    }
//    
//    func performLogout() {
//        didCallPerformLogout = true
//    }
//    
//    func exitProfile() {
//        didCallExitProfile = true
//    }
//}
