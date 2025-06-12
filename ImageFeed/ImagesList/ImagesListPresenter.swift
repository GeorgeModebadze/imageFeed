import Foundation
import UIKit

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool)
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo
    func countOfPhotos() -> Int
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
    
    func thumbImageURL(for photo: PhotoModels.Photo) -> URL?
    func formatPhotoDate(_ photo: PhotoModels.Photo) -> String
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var photos: [PhotoModels.Photo] = []
    private var observer: NSObjectProtocol?
    private let dateFormatter = ISO8601DateFormatter()
    
    private lazy var DisplayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
        dateFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    }
    
    func viewDidLoad() {
        setupNotificationObserver()
        fetchPhotosNextPage()
    }
    
    private func setupNotificationObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updatePhotos()
        }
    }
    
    func formatPhotoDate(_ photo: PhotoModels.Photo) -> String {
        do {
            let date = try photo.requireCreatedAt()
            print("Formatting date:", date)
            print("Formatter locale:", DisplayDateFormatter.locale?.identifier ?? "nil")
            return DisplayDateFormatter.string(from: date)
        } catch PhotoModels.Error.missingCreationDate {
            return ""
        } catch {
            return ""
        }
    }
    
    private func updatePhotos() {
        DispatchQueue.main.async {
            let oldCount = self.photos.count
            self.photos = self.imagesListService.photos
            let newCount = self.photos.count
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLike: Bool) {
        
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            photos[index].isLiked = isLike
            view?.reloadRow(at: IndexPath(row: index, section: 0))
        }
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("Like changed successfully")
            case .failure:
                print("Like change failed")
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index].isLiked = !isLike
                    self.view?.reloadRow(at: IndexPath(row: index, section: 0))
                }
                self.view?.showLikeErrorAlert()
            }
        }
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo {
        guard indexPath.row < photos.count else {
            return PhotoModels.Photo(
                id: "",
                size: CGSize(width: 0, height: 0),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        }
        return photos[indexPath.row]
    }
    
    func countOfPhotos() -> Int {
        return photos.count
    }
    
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photoForIndexPath(indexPath)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        
        guard photo.size.width > 0 else {
            return 0
        }
        
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

extension ImagesListPresenter {
    func thumbImageURL(for photo: PhotoModels.Photo) -> URL? {
        return URL(string: photo.thumbImageURL)
    }
}
