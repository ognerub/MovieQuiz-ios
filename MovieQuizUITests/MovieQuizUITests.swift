//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Admin on 16.06.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
//    func testScreenCast() throws {
//        app.buttons["Да"].tap()
//        app/*@START_MENU_TOKEN@*/.staticTexts["Нет"]/*[[".buttons[\"Нет\"].staticTexts[\"Нет\"]",".staticTexts[\"Нет\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//
//    }
    
    func testYesButton() {
        sleep(1)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(1)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        //XCTAssertTrue(firstPoster.exists) // нет необходимости проверять, упадет раньше
        //XCTAssertTrue(secondPoster.exists) // при отсутствии скриншота
        //XCTAssertFalse(firstPosterData == secondPosterData) // запись ниже идентична
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testIndexLabel() {
        sleep(1)
        let indexLabel = app.staticTexts["Index"]
        app.buttons["No"].tap()
        sleep(1)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    /// тестируем появление алерта в конце рауда
    func testEndRoundAlert() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        let endRoundAlert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(endRoundAlert.exists)
        XCTAssertTrue(endRoundAlert.label == "Этот раунд окончен!")
        XCTAssertTrue(endRoundAlert.buttons.firstMatch.label == "Сыграть еще раз!")
    }
    
    /// тестируем исчезновение алерта
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        let alert = app.alerts["Этот раунд окончен!"]
        sleep(2)
        alert.buttons.firstMatch.tap()
        sleep(2)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
