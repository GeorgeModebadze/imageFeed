import UIKit

final class ProfileViewController: UIViewController {
    private var imageView: UIImageView?
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var logoutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = UIImage(named: "Photo")
        let imageView = UIImageView(image: profileImage)
        imageView.backgroundColor = .clear
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        self.nameLabel = nameLabel
        
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        loginNameLabel.textColor = .gray
        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.textColor = .white
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor, constant: 16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        
        guard let logoutImage = UIImage(named: "logout_button") else {
            assertionFailure("Не найдена иконка logout_button")
            return
        }
        let logoutButton = UIButton.systemButton(with: logoutImage, target: nil, action: #selector(Self.didTapButton))
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .red
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapButton() {
    }
}
