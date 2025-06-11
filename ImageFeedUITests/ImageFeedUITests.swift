//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Георгий on 23.05.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    func testAuth() throws {
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        
        authButton.tap()
        
        let webView = app.otherElements["myWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        print("Current app elements hierarchy:", app.debugDescription)
        
        let loginTextLabel = webView.staticTexts["Email address"]
        XCTAssertTrue(loginTextLabel.waitForExistence(timeout: 5))
        loginTextLabel.tap()
        app.typeText("")
        webView.swipeUp()
        
        let passwordsTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordsTextField.waitForExistence(timeout: 5))
        passwordsTextField.tap()
        passwordsTextField.typeText("")
        passwordsTextField.swipeUp()
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        sleep(2)
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка не загрузилась")
        sleep(5)
        firstCell.swipeUp()
        sleep(1)
        
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Вторая ячейка не найдена")
        
        let likeButton = cellToLike.buttons.firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3), "Кнопка лайка не найдена")
        sleep(2)
        
        likeButton.tap()
        sleep(3)
        likeButton.tap()
        sleep(3)
        
        cellToLike.tap()
        sleep(1)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Полноразмерное изображение не найдено")
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["Backward"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["George Modebadze"].exists)
        XCTAssertTrue(app.staticTexts["@kubimonsta"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Выход"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
