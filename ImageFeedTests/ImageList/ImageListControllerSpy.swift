import XCTest
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLikeErrorAlertCalled = false
    var reloadRowCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
    }
}
