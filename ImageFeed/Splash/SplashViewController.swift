import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    //    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let splashLogoImageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        splashLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            showAuthScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func splashLogo() {
        splashLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashLogoImageView)
        NSLayoutConstraint.activate([
            splashLogoImageView.widthAnchor.constraint(equalToConstant: 73),
            splashLogoImageView.heightAnchor.constraint(equalToConstant: 75),
//            splashLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
//            splashLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            splashLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
            }, completion: { _ in
                print("Transition to TabBarController completed")
            })
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    self.switchToTabBarController()
                    
                case .failure(let error):
                    print("Failed to fetch profile: \(error.localizedDescription)")
                    self.showErrorAlert()
                }
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.showAuthScreen()
        })
        present(alert, animated: true)
    }
    

    private func showAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                assertionFailure("Не удалось создать AuthViewController из storyboard")
                return
            }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let token):
                    self.oauth2TokenStorage.token = token
                    self.fetchProfile(token: token)
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("Authentication error: \(error.localizedDescription)")
                    self.showAuthScreen()
                }
            }
        }
    }
}
