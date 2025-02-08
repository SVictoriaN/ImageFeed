import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        sleep(5)
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 10), "Веб-вью 'UnsplashWebView' должно быть доступно.")

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables

        let numberOfCells = tablesQuery.cells.count
        XCTAssertGreaterThan(numberOfCells, 0, "Таблица должна содержать хотя бы один элемент")

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.exists)

        let cellExists = NSPredicate(format: "exists == true")
        expectation(for: cellExists, evaluatedWith: cell, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        cell.swipeUp()

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        let likeButtonOff = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeButtonOff.exists && likeButtonOff.isHittable, "Кнопка 'like button off' должна быть доступна для нажатия.")
        likeButtonOff.tap()

        let likeButtonOn = cellToLike.buttons["like button on"]
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: likeButtonOn, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(likeButtonOn.exists && likeButtonOn.isHittable, "Кнопка 'like button on' должна быть доступна для нажатия.")
        likeButtonOn.tap()

        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        let imageExists = NSPredicate(format: "exists == true")
        expectation(for: imageExists, evaluatedWith: image, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[""].exists) // write your "Name Surname" from profile
        XCTAssertTrue(app.staticTexts[""].exists) // write your username from profile ("@username")
        
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        let authViewController = app.otherElements["AuthViewController"]
        XCTAssertTrue(authViewController.waitForExistence(timeout: 5))
    }
}
