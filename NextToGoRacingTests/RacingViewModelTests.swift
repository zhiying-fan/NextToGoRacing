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
        let racingServiceStub = RacingServiceResponseThreeRacesStub()

        // When
        let viewModel = RacingViewModel(racingService: racingServiceStub)

        // Then
        XCTAssertEqual(viewModel.viewState, ViewState.loading)
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFetchPeriodically_whenRequestSuccessfully_shouldSetStateAndFilterRaces() {
        // Given
        let racingServiceStub = RacingServiceResponseThreeRacesStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectedRaces = [FakeRacingService.ongoingHorseRace, FakeRacingService.greyhoundRace]
        let expectation = XCTestExpectation(description: "Set state to display")

        viewModel.$viewState
            .drop { $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        XCTAssertEqual(viewModel.viewState, ViewState.loading)
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.viewState, .display)
        XCTAssertEqual(viewModel.filteredRacesInOrder, expectedRaces)
    }

    func testFetchPeriodically_whenNoConnection_shouldSetStateToNoInternetError() {
        // Given
        let racingServiceStub = RacingServiceNoConnectionStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to no internet error")

        viewModel.$viewState
            .drop { $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.viewState, .error(true))
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFetchPeriodically_whenRequestFailed_shouldSetStateToError() {
        // Given
        let racingServiceStub = RacingServiceRequestFailedStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Set state to failed error")

        viewModel.$viewState
            .drop { $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.viewState, .error(false))
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }

    func testFilterByCategory_whenHorseIsNotSelected_shouldNotReturnHorseRaces() {
        // Given
        let racingServiceStub = RacingServiceResponseThreeRacesStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectedRaces = [FakeRacingService.greyhoundRace]
        let expectation = XCTestExpectation(description: "Set state to finish")

        viewModel.$viewState
            .drop { $0 == .loading }
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

        viewModel.$viewState
            .drop { $0 == .loading }
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

    func testFetchPeriodically_whenThereIsNoRace_shouldSetStateToEmpty() {
        // Given
        let racingServiceStub = RacingServiceResponseZeroRacesStub()
        let viewModel = RacingViewModel(racingService: racingServiceStub)
        let expectation = XCTestExpectation(description: "Request done")

        viewModel.$viewState
            .drop { $0 == .loading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellableSet)

        // When
        viewModel.fetchRacesPeriodically()

        // Then
        XCTAssertEqual(viewModel.viewState, ViewState.loading)
        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(viewModel.viewState, .empty)
        XCTAssertEqual(viewModel.filteredRacesInOrder.count, 0)
    }
}

final class RacingServiceResponseThreeRacesStub: RacingService {
    func fetchRaces() async throws -> RacesDTO {
        let dummyRacesDTO = RacesDTO(
            raceSummaries: [
                "6cb1e96c-acf1-471f-b5bd-0947692b90cc": FakeRacingService.greyhoundRace,
                "e2e041dc-53f4-40c5-975d-4baf775e13a0": FakeRacingService.ongoingHorseRace,
                "32e041dc-53f4-40c5-975d-4baf775e13a0": FakeRacingService.pastHarnessRace,
            ]
        )
        return dummyRacesDTO
    }
}

final class RacingServiceResponseSixRacesStub: RacingService {
    func fetchRaces() async throws -> RacesDTO {
        FakeRacingService.dummyRacesDTO
    }
}

final class RacingServiceResponseZeroRacesStub: RacingService {
    func fetchRaces() async throws -> RacesDTO {
        RacesDTO(raceSummaries: [:])
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
