import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    var sut: ProfileViewController!
    var presenterSpy: ProfilePresenterSpy!
    var viewSpy: ProfileViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        presenterSpy = ProfilePresenterSpy()
        viewSpy = ProfileViewControllerSpy()
        
        // Настраиваем связи
        presenterSpy.view = viewSpy
        sut.configure(presenterSpy)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        presenterSpy = nil
        viewSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsPresenter() {
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(presenterSpy.didCallViewDidLoad)
    }
    
    func testUpdateProfileDetails() {
        // given
        let testName = "Test Name"
        let testLogin = "@test_login"
        let testBio = "Test bio"
        
        // when
        sut.updateProfileDetails(name: testName, loginName: testLogin, bio: testBio)
        
        // then
        XCTAssertEqual(sut.nameLabel.text, testName)
        XCTAssertEqual(sut.loginNameLabel.text, testLogin)
        XCTAssertEqual(sut.descriptionLabel.text, testBio)
    }
    
    func testShowLogoutConfirmationAlert() {
        // when
        sut.showLogoutConfirmationAlert()
        
        // then
        XCTAssertTrue(viewSpy.didCallShowLogoutConfirmationAlert)
    }
    
    func testLogoutButtonTap() {
        // when
        sut.didTapButton()
        
        // then
        XCTAssertTrue(presenterSpy.didCallShowLogoutConfirmationAlert)
    }
}
