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
