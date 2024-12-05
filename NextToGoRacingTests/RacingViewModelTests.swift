//
//  RacingViewModelTests.swift
//  NextToGoRacingTests
//
//  Created by Zhiying Fan on 5/12/2024.
//

import Combine
import Foundation
@testable import NextToGoRacing
import XCTest

final class RacingViewModelTests: XCTestCase {
    private var viewModel: RacingViewModel!
    private var cancellableSet: Set<AnyCancellable> = []

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

    func testViewModel_whenInit_shouldHaveIdleStateAndEmptyRaces() {
        // Given
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()

        // When
        let viewModel = RacingViewModel(racingService: racingServiceStub)

        // Then
        XCTAssertEqual(viewModel.loadState, LoadState.idle)
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFetchPeriodically_whenRequestSuccessfully_shouldSetStateAndRaces() {
        // Given
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectedRaces = [RacingServiceRequestSuccessfullyStub.raceOne, RacingServiceRequestSuccessfullyStub.raceTwo]
        let expectation = XCTestExpectation(description: "Set state to finish")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        XCTAssertEqual(viewModel.loadState, LoadState.loading)
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.loadState, .finish)
        XCTAssertEqual(viewModel.filteredRacesInOrder, expectedRaces)
    }

    func testFetchPeriodically_whenNoConnection_shouldSetStateToNoInternetError() {
        // Given
        let racingServiceStub = RacingServiceNoConnectionStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to no internet error")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.loadState, .error(true))
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFetchPeriodically_whenRequestFailed_shouldSetStateToError() {
        // Given
        let racingServiceStub = RacingServiceRequestFailedStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to failed error")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.loadState, .error(false))
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFilterByCategory_whenHorseIsNotSelected_shouldNotReturnHorseRaces() {
        // Given
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectedRaces = [RacingServiceRequestSuccessfullyStub.raceTwo]
        let expectation = XCTestExpectation(description: "Set state to finish")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        viewModel.fetchRacesPeriodically()
        wait(for: [expectation], timeout: 1.5)

        // When
        if let index = viewModel.categories.firstIndex(where: { $0.category == .horse }) {
            viewModel.categories[index].selected = false
        }

        // Then
        XCTAssertEqual(viewModel.filteredRacesInOrder, expectedRaces)
    }

    func testTakeTheFirstFive_whenThereAreMoreThanFiveRaces_shouldOnlyTakeTheFirstFive() {
        // Given
        let racingServiceStub = RacingServiceResponseSixRacesStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to finish")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 5)
    }
}

final class RacingServiceRequestSuccessfullyStub: RacingService {
    static let raceTwo = RaceSummary(
        raceID: "6cb1e96c-acf1-471f-b5bd-0947692b90cc",
        raceNumber: 5,
        meetingName: "Swindon Bags",
        category: .greyhound,
        advertisedStart: AdvertisedStart(seconds: 1_733_253_960)
    )
    static let raceOne = RaceSummary(
        raceID: "e2e041dc-53f4-40c5-975d-4baf775e13a0",
        raceNumber: 6,
        meetingName: "Parx Racing",
        category: .horse,
        advertisedStart: AdvertisedStart(seconds: 1_733_253_900)
    )

    func fetchRaces() async throws -> RacesDTO {
        let dummyRacesDTO = RacesDTO(
            nextToGoIDS: [
                "e2e041dc-53f4-40c5-975d-4baf775e13a0",
                "6cb1e96c-acf1-471f-b5bd-0947692b90cc",
            ],
            raceSummaries: [
                "6cb1e96c-acf1-471f-b5bd-0947692b90cc": RacingServiceRequestSuccessfullyStub.raceTwo,
                "e2e041dc-53f4-40c5-975d-4baf775e13a0": RacingServiceRequestSuccessfullyStub.raceOne,
            ]
        )
        return dummyRacesDTO
    }
}

final class RacingServiceResponseSixRacesStub: RacingService {
    func fetchRaces() async throws -> RacesDTO {
        let dummyRacesDTO = RacesDTO(
            nextToGoIDS: Array(repeating: "e2e041dc-53f4-40c5-975d-4baf775e13a0", count: 6),
            raceSummaries: [
                "6cb1e96c-acf1-471f-b5bd-0947692b90cc": RacingServiceRequestSuccessfullyStub.raceTwo,
                "e2e041dc-53f4-40c5-975d-4baf775e13a0": RacingServiceRequestSuccessfullyStub.raceOne,
                "d2e041dc-53f4-40c5-975d-4baf775e13a0": RacingServiceRequestSuccessfullyStub.raceOne,
                "a2e041dc-53f4-40c5-975d-4baf775e13a0": RacingServiceRequestSuccessfullyStub.raceOne,
                "b2e041dc-53f4-40c5-975d-4baf775e13a0": RacingServiceRequestSuccessfullyStub.raceOne,
                "f2e041dc-53f4-40c5-975d-4baf775e13a0": RacingServiceRequestSuccessfullyStub.raceOne,
            ]
        )
        return dummyRacesDTO
    }
}

final class RacingServiceNoConnectionStub: RacingService {
    func fetchRaces() async throws -> RacesDTO {
        throw RequestError.noInternet
    }
}

final class RacingServiceRequestFailedStub: RacingService {
    func fetchRaces() async throws -> RacesDTO {
        throw RequestError.invalidResponse
    }
}
