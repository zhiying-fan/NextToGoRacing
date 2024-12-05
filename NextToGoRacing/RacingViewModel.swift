//
//  RacingViewModel.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Combine
import Foundation

enum LoadState: Equatable {
    typealias NoInternet = Bool

    case idle
    case loading
    case finish
    case error(NoInternet)
}

final class RacingViewModel: ObservableObject {
    @Published var loadState = LoadState.idle
    @Published var orderedRaces = [RaceSummary]()

    private let racingService: RacingService
    private let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    private var cancellableSet: Set<AnyCancellable> = []

    init(racingService: RacingService = RemoteRacingService()) {
        self.racingService = racingService

        subscribeTimer()
    }

    func fetchRacesPeriodically() {
        loadState = .loading

        timerPublisher
            .connect()
            .store(in: &cancellableSet)
    }

    private func fetchRaces() {
        Task { @MainActor in
            do {
                let racesDTO = try await racingService.fetchRaces()
                orderedRaces = transformToOrderRaces(racesDTO: racesDTO)

                loadState = .finish
            } catch {
                if let requestError = error as? RequestError, requestError == .noInternet {
                    loadState = .error(true)
                } else {
                    loadState = .error(false)
                }
            }
        }
    }

    private func subscribeTimer() {
        timerPublisher
            .sink { [weak self] _ in
                self?.fetchRaces()
            }
            .store(in: &cancellableSet)
    }

    private func transformToOrderRaces(racesDTO: RacesDTO) -> [RaceSummary] {
        racesDTO.raceSummaries.values.sorted { $0.advertisedStart.seconds < $1.advertisedStart.seconds }
    }
}
