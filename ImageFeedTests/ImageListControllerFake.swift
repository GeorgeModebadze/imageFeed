import Foundation
@testable import ImageFeed

final class ImagesListViewControllerFake: ImagesListViewControllerProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        return
    }
    
    func showLikeErrorAlert() {
        return
    }
    
    var presenter: ImageFeed.ImagesListPresenterProtocol?
}
