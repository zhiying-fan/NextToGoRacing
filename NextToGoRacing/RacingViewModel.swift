//
//  RacingViewModel.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Combine
import Foundation

enum ViewState: Equatable, Codable {
    typealias NoInternet = Bool

    case loading
    case empty
    case display
    case error(NoInternet)
}

final class RacingViewModel: ObservableObject {
    @Published var viewState = ViewState.loading
    @Published var filteredRacesInOrder = [RaceSummary]()
    @Published var categories = RaceCategory.allCases.map { CategorySelection(category: $0, selected: true) } {
        didSet {
            updateFilteredRacesInOrder()
        }
    }

    private let racingService: RacingService
    private var cancellable: AnyCancellable?
    private var allRaces = [RaceSummary]()

    init(racingService: RacingService = DependencyContainer.racingService) {
        self.racingService = racingService
    }

    func fetchRacesPeriodically() {
        viewState = .loading

        subscribeTimer()
    }

    // MARK: Private Methods

    private func fetchRaces() {
        Task { @MainActor in
            do {
                let racesDTO = try await racingService.fetchRaces()
                allRaces = transformToOrderedRaces(racesDTO: racesDTO)

                updateFilteredRacesInOrder()
            } catch {
                if let requestError = error as? RequestError, requestError == .noInternet {
                    viewState = .error(true)
                } else {
                    viewState = .error(false)
                }
            }
        }
    }

    private func subscribeTimer() {
        cancellable?.cancel()

        cancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { [weak self] _ in
                self?.fetchRaces()
            }
    }

    private func transformToOrderedRaces(racesDTO: RacesDTO) -> [RaceSummary] {
        racesDTO.raceSummaries.values.sorted { $0.advertisedStart.seconds < $1.advertisedStart.seconds }
    }

    private func updateFilteredRacesInOrder() {
        filterRaces()

        if filteredRacesInOrder.isEmpty {
            viewState = .empty
        } else {
            takeTheFirstFiveRaces()
            viewState = .display
        }
    }

    private func filterRaces() {
        let selectedCategories = categories
            .filter(\.selected)
            .map(\.category)

        filteredRacesInOrder = allRaces
            .filter { isRaceAfterLastMinute(race: $0) }
            .filter { selectedCategories.contains($0.category) }
    }

    private func isRaceAfterLastMinute(race: RaceSummary) -> Bool {
        let currentTimestamp = Date().timeIntervalSince1970
        let oneMinuteAgoTimestamp = currentTimestamp - 60
        return race.advertisedStart.seconds > oneMinuteAgoTimestamp
    }

    private func takeTheFirstFiveRaces() {
        let sliceFive = filteredRacesInOrder.prefix(5)
        filteredRacesInOrder = Array(sliceFive)
    }
}
