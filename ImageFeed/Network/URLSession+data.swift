import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("[Network] Request failed: \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "")")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[Network] Invalid response: no HTTP response, URL: \(request.url?.absoluteString ?? "")")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    print("[Network] HTTP error: status \(httpResponse.statusCode), URL: \(request.url?.absoluteString ?? "")")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    print("[Network] No data received, URL: \(request.url?.absoluteString ?? "")")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                    print("[Network] Decoding failed: \(error), Response: \(responseString), URL: \(request.url?.absoluteString ?? "")")
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}

