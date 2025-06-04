import UIKit

struct ProfileImage: Codable {
    //    let large: String
    let small: String
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let token = tokenStorage.token else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let request: URLRequest
        do {
            request = try makeProfileImageRequest(username: username, token: token)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] (result: Result<Data, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                        let avatarURL = userResult.profileImage.small
                        self.avatarURL = avatarURL
                        completion(.success(avatarURL))
                        NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL]
                        )
                    } catch {
                        completion(.failure(NetworkError.urlRequestError(error)))
                    }
                case .failure(let error):
                    if let error = error as? URLError, error.code == .cancelled {
                        return
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
            throw NetworkError.urlSessionError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
