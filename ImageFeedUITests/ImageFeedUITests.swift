//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Георгий on 23.05.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        print("Current app elements hierarchy:", app.debugDescription)
        
        let webView = app.otherElements["myWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 20), "WebView нет")
        
        print("Current app elements hierarchy:", app.debugDescription)
        sleep(2)
        
//        let loginTextField = webView.descendants(matching: .secureTextField).element
        let loginTextField = webView.textFields.firstMatch
//        let loginTextField = webView.textFields["Email address"]
//        let loginTextField = webView.descendants(matching: .any).matching(NSPredicate(format: "identifier CONTAINS 'Email address' OR placeholderValue CONTAINS 'Email address'")).firstMatch
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поля логина нет")
        
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поля пароля нет")
        
        
        passwordTextField.tap()
        UIPasteboard.general.string = ""
        passwordTextField.doubleTap()
        app.menuItems["Paste"].tap()
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ленты нет")
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like_button_off"].tap()
        cellToLike.buttons["like_button_on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackwardButton = app.buttons["Backward"]
        navBackwardButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
