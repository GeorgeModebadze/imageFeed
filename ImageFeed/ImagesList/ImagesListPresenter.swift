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
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var photos: [PhotoModels.Photo] = []
    private var observer: NSObjectProtocol?
    private let dateFormatter = ISO8601DateFormatter()
    
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
    
    private func updatePhotos() {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLike: Bool) {
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("Like changed successfully")
                //                self.updatePhotos()
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.view?.reloadRow(at: IndexPath(row: index, section: 0))
                }
                case .failure:
                    print("Like change failed")
                    self.view?.showLikeErrorAlert()
                }
            }
        }
        
        func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo {
            guard indexPath.row < photos.count else {
                fatalError("Index out of range")
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
