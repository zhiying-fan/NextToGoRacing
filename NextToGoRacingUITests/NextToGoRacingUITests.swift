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
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    func testRacingView_whenUnselectedHorse_shouldRemoveAllHorseRaces() {
        let displayState = ViewState.display
        if let data = try? JSONEncoder().encode(displayState) {
            app.launchEnvironment["STATE"] = String(data: data, encoding: .utf8)
        }
        app.launch()

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

    func testRacingView_whenNoData_shouldDisplayEmptyView() {
        let emptyState = ViewState.empty
        if let data = try? JSONEncoder().encode(emptyState) {
            app.launchEnvironment["STATE"] = String(data: data, encoding: .utf8)
        }
        app.launch()

        let title = app.staticTexts["No Upcoming Races"]
        let refreshButton = app.buttons["Refresh"]
        XCTAssert(title.waitForExistence(timeout: 0.1), "Failed to find title on racing screen")
        XCTAssert(refreshButton.waitForExistence(timeout: 0.1), "Failed to find refresh button on racing screen")

        refreshButton.tap()

        XCTAssert(title.waitForExistence(timeout: 0.1), "Failed to find title on racing screen")
    }

    func testRacingView_whenNoInternet_shouldDisplayNoInternetErrorView() {
        let errorState = ViewState.error(true)
        if let data = try? JSONEncoder().encode(errorState) {
            app.launchEnvironment["STATE"] = String(data: data, encoding: .utf8)
        }
        app.launch()

        let title = app.staticTexts["Please check your network connection"]
        let retryButton = app.buttons["Retry"]
        XCTAssert(title.waitForExistence(timeout: 0.1), "Failed to find title on racing screen")
        XCTAssert(retryButton.waitForExistence(timeout: 0.1), "Failed to find retry button on racing screen")

        retryButton.tap()

        XCTAssert(title.waitForExistence(timeout: 0.1), "Failed to find title on racing screen")
    }

    func testRacingView_whenGetInvalidResponse_shouldDisplayUnknownErrorView() {
        let errorState = ViewState.error(false)
        if let data = try? JSONEncoder().encode(errorState) {
            app.launchEnvironment["STATE"] = String(data: data, encoding: .utf8)
        }
        app.launch()

        let title = app.staticTexts["Something went wrong"]
        let retryButton = app.buttons["Retry"]
        XCTAssert(title.waitForExistence(timeout: 0.1), "Failed to find title on racing screen")
        XCTAssert(retryButton.waitForExistence(timeout: 0.1), "Failed to find retry button on racing screen")

        retryButton.tap()

        XCTAssert(title.waitForExistence(timeout: 0.1), "Failed to find title on racing screen")
    }
}

enum ViewState: Equatable, Codable {
    typealias NoInternet = Bool

    case loading
    case empty
    case display
    case error(NoInternet)
}
