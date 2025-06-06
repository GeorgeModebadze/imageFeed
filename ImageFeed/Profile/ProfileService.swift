import UIKit

struct Profile {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    init(username: String, firstName: String, lastName: String, bio: String) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.bio = bio
    }
    
    var name: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    var loginName: String {
        return "@\(username)"
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private init() {}
    
    private func makeGETRequest(url: URL, bearerToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL"])
            print("[ProfileService] Invalid URL for profile request")
            completion(.failure(error))
            return
        }
        
        let request = makeGETRequest(url: url, bearerToken: token)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profileResult):
                    let profile = Profile(
                        username: profileResult.username,
                        firstName: profileResult.firstName ?? "",
                        lastName: profileResult.lastName ?? "",
                        bio: profileResult.bio ?? ""
                    )
                    self.profile = profile
                    print("[ProfileService] Profile loaded successfully: \(profile.username)")
                    completion(.success(profile))
                    
                case .failure(let error):
                    let errorMessage: String
                    
                    if let urlError = error as? URLError {
                        errorMessage = "Network error: \(urlError.code.rawValue) - \(urlError.localizedDescription)"
                    } else if let decodingError = error as? DecodingError {
                        errorMessage = "Decoding error: \(decodingError.localizedDescription)"
                    } else if let networkError = error as? NetworkError {
                        switch networkError {
                        case .httpStatusCode(let code):
                            errorMessage = "HTTP error \(code)"
                        case .urlRequestError(let error):
                            errorMessage = "Request error: \(error.localizedDescription)"
                        case .urlSessionError:
                            errorMessage = "Session error"
                        }
                    } else {
                        errorMessage = "Unknown error: \(error.localizedDescription)"
                    }
                    
                    print("[ProfileService] \(errorMessage)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
}
