import UIKit
import Kingfisher

struct ProfileImage: Codable {
    let small: String
}

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    func loadAvatar(for imageView: UIImageView, placeholder: UIImage?)
    func cleanAvatarURL()
    
    static var didChangeNotification: Notification.Name { get }
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func cleanAvatarURL() {
        avatarURL = nil
    }
    
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    
    func loadAvatar(for imageView: UIImageView, placeholder: UIImage? = nil) {
        guard let avatarURLString = avatarURL,
              let avatarURL = URL(string: avatarURLString) else {
            imageView.image = placeholder ?? UIImage(named: "placeholder_avatar")
            return
        }
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        DispatchQueue.main.async {
            imageView.kf.indicatorType = .activity
            
            imageView.kf.setImage(
                with: avatarURL,
                placeholder: placeholder,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.25)),
                    .cacheOriginalImage
                ],
                completionHandler: { result in
                    switch result {
                    case .success(let value):
                        print("Аватар загружен: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("Ошибка загрузки аватара: \(error.localizedDescription)")
                    }
                }
            )
        }
    }
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let token = tokenStorage.token else {
            let error = NetworkError.urlSessionError
            print("[ProfileImageService] No auth token available")
            completion(.failure(error))
            return
        }
        
        let request: URLRequest
        do {
            request = try makeProfileImageRequest(username: username, token: token)
        } catch {
            print("[ProfileImageService] Failed to create request: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let userResult):
                    let avatarURL = userResult.profileImage.small
                    self.avatarURL = avatarURL
                    print("[ProfileImageService] Avatar URL loaded: \(avatarURL)")
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                    
                case .failure(let error):
                    if let urlError = error as? URLError {
                        if urlError.code == .cancelled {
                            print("[ProfileImageService] Request cancelled for \(username)")
                            return
                        }
                        print("[ProfileImageService] Network error: \(urlError.code.rawValue) - \(urlError.localizedDescription)")
                    } else if let decodingError = error as? DecodingError {
                        print("[ProfileImageService] Decoding failed: \(decodingError.localizedDescription)")
                    } else {
                        print("[ProfileImageService] Error: \(error.localizedDescription)")
                    }
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(
        username: String,
        token: String
    ) throws -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService] Invalid URL for username: \(username)")
            throw NetworkError.urlSessionError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
