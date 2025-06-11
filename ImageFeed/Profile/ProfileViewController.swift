import UIKit
import SwiftKeychainWrapper
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar()
    func showLogoutConfirmationAlert()
    func switchToAuthViewController()
    func showSplashScreen()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    //    Закомментил для тестирования (убираю приватность)
    //    private let profileImageView = UIImageView()
    //    private let nameLabel = UILabel()
    //    private let loginNameLabel = UILabel()
    //    private let descriptionLabel = UILabel()
    //    private let logoutButton = UIButton()
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let loginNameLabel = UILabel()
    let descriptionLabel = UILabel()
    let logoutButton = UIButton()
    
    private let profileService = ProfileService.shared
    private var presenter: ProfilePresenterProtocol!
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    // совет от Практикума
    //    private var presenter: ProfilePresenterProtocol!
    //
    //    func configure(_ presenter: ProfilePresenterProtocol) {
    //        self.presenter = presenter
    //        presenter.view = self
    //    }
    /*
     Чтобы иметь возможность подменять presenter при тестировании View Controller'ов, создаваемых из Storyboard, можно добавить во View Controller метод configure. Например, так:
     
     Тогда для production-кода (то есть кода приложения, а не тестов) нужно будет вызвать метод configure из prepareForSegue при переходе на соответствующий контроллер.
     А в тестах можно будет подставлять presenter явным вызовом — например, так: sut.configure(presenterSpy).
     */
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
        setupConstraints()
        setupObserver()
        presenter.viewDidLoad()
    }
    
    private func setupPresenter() {
        presenter = ProfilePresenter()
        presenter.view = self
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presenter.didUpdateAvatar()
        }
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func updateAvatar() {
        ProfileImageService.shared.loadAvatar(
            for: profileImageView,
            placeholder: UIImage(named: "placeholder_avatar")
        )
    }
    
    func showLogoutConfirmationAlert() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter.performLogout()
            self?.showSplashScreen()
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        
        present(alert, animated: true)
    }
    
    func switchToAuthViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = authVC
        })
    }
    
    func showSplashScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Не удается открыть UIWindow")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    private func showPlaceholderProfile() {
        nameLabel.text = "Екатерина Новикова"
        loginNameLabel.text = "@ekaterina_nov"
        descriptionLabel.text = "Hello, World!"
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        profileImageView.backgroundColor = .clear
        profileImageView.tintColor = .gray
        profileImageView.backgroundColor = .clear
        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "placeholder_avatar")
        
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        loginNameLabel.textColor = .gray
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        guard let logoutImage = UIImage(named: "logout_button") else {
            assertionFailure("Не найдена иконка logout_button")
            return
        }
        logoutButton.accessibilityIdentifier = "logoutButton"
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = UIColor(named: "ypRed")
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        [profileImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    @objc
    func didTapButton() {
        showLogoutConfirmationAlert()
    }
    // убрал приватность для тестов
    //    private func didTapButton() {
    //        showLogoutConfirmationAlert()
    //    }
    
    
    private func performLogout() {
        ProfileLogoutService.shared.logout()
        
        switchToAuthViewController()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

