import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
        }
    }
    
    func testViewControllerCallsShowLikeErrorAlert() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        viewController.showLikeErrorAlert()
        
        // then
        XCTAssertTrue(presenter.view is ImagesListViewController)
        
    }
    
    func testViewControllerCallsReloadRow() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        let testIndexPath = IndexPath(row: 0, section: 0)
        viewController.reloadRow(at: testIndexPath)
        
        // then
        XCTAssertTrue(presenter.view is ImagesListViewController)
        
    }
}
