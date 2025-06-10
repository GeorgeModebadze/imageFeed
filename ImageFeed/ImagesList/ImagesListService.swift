import UIKit

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [PhotoModels.Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

extension ImagesListService: ImagesListServiceProtocol {}

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [PhotoModels.Photo] = []
    
    func cleanPhotos() {
        photos = []
        lastLoadedPage = 0
    }
    
    private let dateFormatter = ISO8601DateFormatter()
    private var lastLoadedPage = 0
    private var isLoading = false
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        let nextPage = lastLoadedPage + 1
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&client_id=\(Constants.accessKey)") else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.isLoading = false }
            
            if let error {
                print("[ImagesListService] Error fetching photos: \(error.localizedDescription)")
                return
            }
            
            guard let data else {
                print("[ImagesListService] No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.map { result in
                    PhotoModels.Photo(
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: self.dateFormatter.date(from: result.createdAt),
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    print("[ImagesListService] Photos loaded: \(self.photos.count)")
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                let dataString = String(data: data, encoding: .utf8) ?? "unavailable"
                print("[ImagesListService] Decoding error: \(error). Data: \(dataString)")
            }
        }.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(NetworkError.urlRequestError(URLError(.badURL))))
            return
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "TokenError", code: 401, userInfo: nil)
            print("Token error - \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                
                let newPhoto = PhotoModels.Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: isLike
                )
                
                DispatchQueue.main.async {
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(URLError(.cannotFindHost))))
                }
            }
        }.resume()
    }
}

extension Array {
    func withReplaced(itemAt index: Index, newValue: Element) -> [Element] {
        var newArray = self
        guard index >= 0 && index < newArray.count else { return newArray }
        newArray[index] = newValue
        return newArray
    }
}
