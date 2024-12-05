//
//  RacingViewModelTests.swift
//  NextToGoRacingTests
//
//  Created by Zhiying Fan on 5/12/2024.
//

@testable import NextToGoRacing
import XCTest

final class RacingViewModelTests: XCTestCase {
    var viewModel: RacingViewModel!

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

    func testInitShouldHaveIdleStateAndEmptyRaces() {
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()

        let viewModel = RacingViewModel(racingService: racingServiceStub)

        XCTAssertEqual(viewModel.loadState, LoadState.idle)
        XCTAssertEqual(viewModel.orderedRaces.count, 0)
    }

    func testFetchPeriodicallyShouldSetStateAndRacesWhenRequestSuccessfully() async {
        let racingServiceStub = RacingServiceRequestSuccessfullyStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectedRaces = [RacingServiceRequestSuccessfullyStub.raceOne, RacingServiceRequestSuccessfullyStub.raceTwo]

        viewModel.fetchRacesPeriodically()

        XCTAssertEqual(viewModel.loadState, LoadState.loading)

        try? await Task.sleep(nanoseconds: UInt64(1.1 * Double(NSEC_PER_SEC)))

        XCTAssertEqual(viewModel.loadState, LoadState.finish)
        XCTAssertEqual(viewModel.orderedRaces, expectedRaces)
    }

    func testFetchPeriodicallyShouldSetStateToNoInternetErrorWhenNoConnection() async {
        let racingServiceStub = RacingServiceNoConnectionStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)

        viewModel.fetchRacesPeriodically()

        try? await Task.sleep(nanoseconds: UInt64(1.1 * Double(NSEC_PER_SEC)))

        XCTAssertEqual(viewModel.loadState, LoadState.error(true))
        XCTAssertEqual(viewModel.orderedRaces.count, 0)
    }

    func testFetchPeriodicallyShouldSetStateToErrorWhenRequestFailed() async {
        let racingServiceStub = RacingServiceRequestFailedStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)

        viewModel.fetchRacesPeriodically()

        try? await Task.sleep(nanoseconds: UInt64(1.1 * Double(NSEC_PER_SEC)))

        XCTAssertEqual(viewModel.loadState, LoadState.error(false))
        XCTAssertEqual(viewModel.orderedRaces.count, 0)
    }
}

final class RacingServiceRequestSuccessfullyStub: RacingService {
    static let raceTwo = RaceSummary(
        raceID: "6cb1e96c-acf1-471f-b5bd-0947692b90cc",
        raceNumber: 5,
        meetingName: "Swindon Bags",
        categoryID: "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
        advertisedStart: AdvertisedStart(seconds: 1_733_253_960)
    )
    static let raceOne = RaceSummary(
        raceID: "e2e041dc-53f4-40c5-975d-4baf775e13a0",
        raceNumber: 6,
        meetingName: "Parx Racing",
        categoryID: "4a2788f8-e825-4d36-9894-efd4baf1cfae",
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
