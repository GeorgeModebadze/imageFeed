import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var currentTask: URLSessionTask?
    private var currentAuthCode: String?
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        guard currentAuthCode != code else {
            let error = NetworkError.urlSessionError
            print("[OAuth2Service] Duplicate request with same auth code")
            completion(.failure(error))
            return
        }
        
        currentTask?.cancel()
        currentAuthCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            currentAuthCode = nil
            print("[OAuth2Service] Failed to create token request")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.currentTask = nil
                self?.currentAuthCode = nil
                
                switch result {
                case .success(let tokenResponse):
                    self?.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken))
                case .failure(let error):
                    self?.handleFailure(error: error, completion: completion)
                }
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    private func handleFailure(error: Error, completion: @escaping (Result<String, Error>) -> Void) {
        let errorMessage: String
        
        switch error {
        case let urlError as URLError:
            errorMessage = "URL error \(urlError.code): \(urlError.localizedDescription)"
        case let decodingError as DecodingError:
            errorMessage = "Decoding error: \(decodingError.localizedDescription)"
        case let networkError as NetworkError:
            switch networkError {
            case .httpStatusCode(let code):
                errorMessage = "HTTP error \(code)"
            case .urlRequestError(let error):
                errorMessage = "Request error: \(error.localizedDescription)"
            case .urlSessionError:
                errorMessage = "Session error"
            }
        default:
            errorMessage = "Unknown error: \(error.localizedDescription)"
        }
        
        print("[OAuth2Service] \(errorMessage)")
        completion(.failure(error))
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "unsplash.com"
        components.path = "/oauth/token"
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components.url else {
            print("[OAuth2Service] Failed to create URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
