import UIKit

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    
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
                    Photo(
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
}
