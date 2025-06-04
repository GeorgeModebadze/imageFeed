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
                completion(.failure(error))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = urlSession.data(for: request) { [weak self] (result: Result<Data, Error>) in
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    do {
                        let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                        let profile = Profile(
                            username: profileResult.username,
                            firstName: profileResult.firstName ?? "",
                            lastName: profileResult.lastName ?? "",
                            bio: profileResult.bio ?? ""
                        )
                        self.profile = profile
                        completion(.success(profile))
                        print("Профиль успешно загружен: \(profile)")
                    } catch {
                        completion(.failure(error))
                        print("Ошибка декодирования: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Ошибка сети: \(error.localizedDescription)")
                }
                
                self.task = nil
            }
            
            self.task = task
            task.resume()
        }
}
