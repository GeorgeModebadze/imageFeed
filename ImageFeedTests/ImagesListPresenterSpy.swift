import Foundation
@testable import ImageFeed

class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: (any ImageFeed.ImagesListViewControllerProtocol)?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        
    }
    
    func changeLike(photoId: String, isLike: Bool) {
        
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> ImageFeed.PhotoModels.Photo {
        return [] as! ImageFeed.PhotoModels.Photo
    }
    
    func countOfPhotos() -> Int {
        return 10
    }
    
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        return 100
    }
    
  
}
