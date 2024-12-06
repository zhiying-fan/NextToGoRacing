//
//  RacingService.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

protocol RacingService {
    func fetchRaces() async throws -> RacesDTO
}

final class RemoteRacingService: RacingService {
    private let racesURL = "https://api.neds.com.au/rest/v1/racing/?method=nextraces&count=10"
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient = DefaultHTTPClient()) {
        self.httpClient = httpClient
    }

    func fetchRaces() async throws -> RacesDTO {
        let data = try await httpClient.getRequest(url: racesURL)
        let response = try JSONDecoder().decode(APIResponse<RacesDTO>.self, from: data)
        return response.data
    }
}

#if DEBUG
    final class FakeRacingService: RacingService {
        static let dummyRace = RaceSummary(
            raceID: "e2e041dc-53f4-40c5-975d-4baf775e13a0",
            raceNumber: 6,
            meetingName: "Parx Racing",
            category: .horse,
            advertisedStart: AdvertisedStart(seconds: 1_733_253_900)
        )

        static let dummyRacesDTO = RacesDTO(
            raceSummaries: [
                "6cb1e96c-acf1-471f-b5bd-0947692b90cc": dummyRace,
                "e2e041dc-53f4-40c5-975d-4baf775e13a0": dummyRace,
                "d2e041dc-53f4-40c5-975d-4baf775e13a0": dummyRace,
                "a2e041dc-53f4-40c5-975d-4baf775e13a0": dummyRace,
                "b2e041dc-53f4-40c5-975d-4baf775e13a0": dummyRace,
                "f2e041dc-53f4-40c5-975d-4baf775e13a0": dummyRace,
            ]
        )

        func fetchRaces() async throws -> RacesDTO {
            if let stateString = ProcessInfo.processInfo.environment["STATE"],
               let stateData = stateString.data(using: .utf8),
               let state = try? JSONDecoder().decode(LoadState.self, from: stateData)
            {
                switch state {
                case .idle, .loading:
                    return RacesDTO(raceSummaries: [:])
                case .finish:
                    return FakeRacingService.dummyRacesDTO
                case let .error(noInternet):
                    if noInternet {
                        throw RequestError.noInternet
                    } else {
                        throw RequestError.invalidResponse
                    }
                }
            } else {
                throw RequestError.invalidResponse
            }
        }
    }
#endif

extension DependencyContainer {
    static let racingService: RacingService = ProcessInfo.processInfo.arguments.contains("UI-TESTING") ? FakeRacingService() : RemoteRacingService()
}
