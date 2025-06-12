import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    func thumbImageURL(for photo: ImageFeed.PhotoModels.Photo) -> URL? { nil }
    func formatPhotoDate(_ photo: ImageFeed.PhotoModels.Photo) -> String { "" }
    
    weak var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool) {
        changeLikeCalled = true
    }
    
    func countOfPhotos() -> Int {
        return 0
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo {
        return PhotoModels.Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://test.com",
            largeImageURL: "https://test.com",
            isLiked: false
        )
    }
    
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        return 200
    }
}
