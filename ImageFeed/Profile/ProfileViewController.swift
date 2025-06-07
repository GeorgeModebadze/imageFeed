import UIKit
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController {
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObserver()
        updateProfileDetails()
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }
    
    private func updateAvatar() {
        ProfileImageService.shared.loadAvatar(
            for: profileImageView,
            placeholder: UIImage(named: "placeholder_avatar")
        )
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            showPlaceholderProfile()
            return
        }
        
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "Нет описания"
        
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
    private func didTapButton() {
        showLogoutConfirmationAlert()
    }
    
    private func showLogoutConfirmationAlert() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.performLogout()
            self?.showSplashScreen()
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        ProfileLogoutService.shared.logout()
        
        switchToAuthViewController()
        
    }
    
    private func switchToAuthViewController() {
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
    
}

