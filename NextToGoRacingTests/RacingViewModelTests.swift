//
//  RacingViewModelTests.swift
//  NextToGoRacingTests
//
//  Created by Zhiying Fan on 5/12/2024.
//

import Combine
@testable import NextToGoRacing
import XCTest

final class RacingViewModelTests: XCTestCase {
    var viewModel: RacingViewModel!
    private var cancellableSet: Set<AnyCancellable> = []

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

    func testInitShouldHaveIdleStateAndEmptyRaces() {
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()

        let viewModel = RacingViewModel(racingService: racingServiceStub)

        XCTAssertEqual(viewModel.loadState, LoadState.idle)
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFetchPeriodicallyShouldSetStateAndRacesWhenRequestSuccessfully() {
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectedRaces = [RacingServiceRequestSuccessfullyStub.raceOne, RacingServiceRequestSuccessfullyStub.raceTwo]
        let expectation = XCTestExpectation(description: "Set state to finish")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink {
                XCTAssertEqual($0, .finish)
                XCTAssertEqual(viewModel.filteredRacesInOrder, expectedRaces)

                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        viewModel.fetchRacesPeriodically()

        XCTAssertEqual(viewModel.loadState, LoadState.loading)
        wait(for: [expectation], timeout: 1.5)
    }

    func testFetchPeriodicallyShouldSetStateToNoInternetErrorWhenNoConnection() {
        let racingServiceStub = RacingServiceNoConnectionStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to no internet error")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink {
                XCTAssertEqual($0, .error(true))
                XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)

                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        viewModel.fetchRacesPeriodically()

        wait(for: [expectation], timeout: 1.5)
    }

    func testFetchPeriodicallyShouldSetStateToErrorWhenRequestFailed() {
        let racingServiceStub = RacingServiceRequestFailedStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to failed error")

        viewModel.$loadState
            .drop { $0 == .idle || $0 == .loading }
            .sink {
                XCTAssertEqual($0, .error(false))
                XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)

                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        viewModel.fetchRacesPeriodically()

        wait(for: [expectation], timeout: 1.5)
    }

    func testFilterByCategoryShouldNotReturnHorseRacesWhenHorseIsNotSelected() {
        let viewModel = RacingViewModel()
        viewModel.filteredRacesInOrder = [RacingServiceRequestSuccessfullyStub.raceOne, RacingServiceRequestSuccessfullyStub.raceTwo]
        let expectedRaces = [RacingServiceRequestSuccessfullyStub.raceTwo]

        if let index = viewModel.categories.firstIndex(where: { $0.category == .horse }) {
            viewModel.categories[index].selected = false
        }

        XCTAssertEqual(viewModel.filteredRacesInOrder, expectedRaces)
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
