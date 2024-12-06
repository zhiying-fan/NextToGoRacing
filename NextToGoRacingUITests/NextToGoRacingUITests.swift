//
//  NextToGoRacingUITests.swift
//  NextToGoRacingUITests
//
//  Created by Zhiying Fan on 4/12/2024.
//

import XCTest

final class NextToGoRacingUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    func testRacingViewWithValidRaces() {
        let listView = app.collectionViews
        let meetingName = listView.staticTexts["Parx Racing"]
        let raceNumber = listView.staticTexts["Race 6"]
        let state = listView.staticTexts["Ongoing"]

        XCTAssert(meetingName.waitForExistence(timeout: 1), "Failed to find meeting name in racing screen")
        XCTAssert(raceNumber.waitForExistence(timeout: 1), "Failed to find race number in racing screen")
        XCTAssert(state.waitForExistence(timeout: 1), "Failed to find state in racing screen")
    }
}
