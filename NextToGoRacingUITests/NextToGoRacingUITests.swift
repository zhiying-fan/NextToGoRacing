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

    func testRacingView_whenUnselectedHorse_shouldRemoveAllHorseRaces() {
        // Check race info on racing list
        let listView = app.collectionViews
        let meetingName = listView.staticTexts["Parx Racing"]
        let raceNumber = listView.staticTexts["Race 6"]
        let state = listView.staticTexts["Ongoing"]

        XCTAssert(meetingName.waitForExistence(timeout: 0.1), "Failed to find meeting name on racing screen")
        XCTAssert(raceNumber.waitForExistence(timeout: 0.1), "Failed to find race number on racing screen")
        XCTAssert(state.waitForExistence(timeout: 0.1), "Failed to find state on racing screen")

        // Tap filter button
        let filterMenu = app.navigationBars.staticTexts["Filter"]

        XCTAssert(filterMenu.waitForExistence(timeout: 0.1), "Failed to find filter menu on racing screen")

        filterMenu.tap()

        let filterView = app.collectionViews
        let horseButton = filterView.buttons["Horse"]

        XCTAssert(horseButton.waitForExistence(timeout: 0.1), "Failed to find horse button on filter screen")

        // Unselect horse category
        horseButton.tap()
        app.tap()

        // Check horse races are removed
        XCTAssertFalse(meetingName.waitForExistence(timeout: 0.1), "Failed to filter out horse races")
    }
}
