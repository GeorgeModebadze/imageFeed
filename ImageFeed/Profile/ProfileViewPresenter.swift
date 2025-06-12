import Foundation
import UIKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateAvatar()
    func performLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
        //        tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
        setupObserver()
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.didUpdateAvatar()
        }
    }
    
    func viewDidLoad() {
        updateProfileDetails()
//        loadAvatar()
    }
    
    func didUpdateAvatar() {
//        loadAvatar()
    }
    
    func performLogout() {
        logoutService.logout()
        view?.switchToAuthViewController()
        view?.showSplashScreen()
    }
    
    
//    func updateAvatar() {
//        guard let profile = profileService.profile else { return }
//        
//        profileImageService.fetchProfileImageURL(username: profile.username) { [weak self] result in
//            switch result {
//            case .success(let avatarURL):
//                self?.view?.updateAvatar(url: avatarURL)
//            case .failure(let error):
//                print("Ошибка загрузки URL аватарки: \(error)")
//                self?.view?.updateAvatar(url: nil)
//            }
//        }
//    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            view?.updateProfileDetails(
                name: "Имя не указано",
                loginName: "@username",
                bio: "Нет описания"
            )
            return
        }
        
        view?.updateProfileDetails(
            name: profile.name.isEmpty ? "Имя не указано" : profile.name,
            loginName: profile.loginName,
            bio: profile.bio ?? "Нет описания"
        )
        
        profileImageService.fetchProfileImageURL(username: profile.username) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("Ошибка загрузки URL аватарки: \(error)")
                }
            }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
