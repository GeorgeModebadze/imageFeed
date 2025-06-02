import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var currentTask: URLSessionTask?
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        currentTask?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.handleSuccess(data: data, completion: completion)
                case .failure(let error):
                    self?.handleFailure(error: error, completion: completion)
                }
                self?.currentTask = nil
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    private func handleSuccess(data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            self.tokenStorage.token = tokenResponse.accessToken
            completion(.success(tokenResponse.accessToken))
        } catch {
            print("[OAuth2Service] Decoding error: \(error.localizedDescription)")
            completion(.failure(NetworkError.urlRequestError(error)))
        }
    }
    
    private func handleFailure(error: Error, completion: @escaping (Result<String, Error>) -> Void) {
        if let urlError = error as? URLError {
            print("[OAuth2Service] URL error: \(urlError.errorCode) - \(urlError.localizedDescription)")
            completion(.failure(NetworkError.urlRequestError(urlError)))
        } else {
            print("[OAuth2Service] Unknown error: \(error.localizedDescription)")
            completion(.failure(NetworkError.urlSessionError))
        }
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
            print("[OAuth2Service] URL creation failed")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
