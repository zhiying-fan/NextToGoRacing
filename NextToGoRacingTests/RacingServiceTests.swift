//
//  RacingServiceTests.swift
//  NextToGoRacingTests
//
//  Created by Zhiying Fan on 4/12/2024.
//

@testable import NextToGoRacing
import XCTest

final class RacingServiceTests: XCTestCase {
    func testFetchRaces_whenGetDataFromClient_shouldReturnRacesDTO() async {
        // Given
        let correctDataClientStub = HTTPClientReturnRacesDTODataStub()
        let racingService = RemoteRacingService(httpClient: correctDataClientStub)

        // When
        let racesDTO = try? await racingService.fetchRaces()

        // Then
        XCTAssertNotNil(racesDTO)
    }

    func testFetchRaces_whenGetWrongDataFromClient_shouldThrow() async {
        // Given
        let wrongDataClientStub = HTTPClientReturnWrongDataStub()
        let racingService = RemoteRacingService(httpClient: wrongDataClientStub)
        var thrownError: Error?

        // When
        do {
            _ = try await racingService.fetchRaces()
        } catch {
            thrownError = error
        }

        // Then
        XCTAssertNotNil(thrownError)
    }

    func testFetchRaces_whenThereIsAnErrorFromClient_shouldThrow() async {
        // Given
        let errorClientStub = HTTPClientGetFailedStub()
        let racingService = RemoteRacingService(httpClient: errorClientStub)
        var thrownError: Error?

        // When
        do {
            _ = try await racingService.fetchRaces()
        } catch {
            thrownError = error
        }

        // Then
        XCTAssertNotNil(thrownError)
    }
}

final class HTTPClientReturnRacesDTODataStub: HTTPClient {
    func getRequest(url _: String) async throws -> Data {
        let response = """
        {
           "status":200,
           "data":{
              "next_to_go_ids":[
                 "e2e041dc-53f4-40c5-975d-4baf775e13a0",
                 "6cb1e96c-acf1-471f-b5bd-0947692b90cc",
              ],
              "race_summaries":{
                 "6cb1e96c-acf1-471f-b5bd-0947692b90cc":{
                    "race_id":"6cb1e96c-acf1-471f-b5bd-0947692b90cc",
                    "race_number":5,
                    "meeting_name":"Swindon Bags",
                    "category_id":"9daef0d7-bf3c-4f50-921d-8e818c60fe61",
                    "advertised_start":{
                       "seconds":1733253960
                    },
                 },
                 "e2e041dc-53f4-40c5-975d-4baf775e13a0":{
                    "race_id":"e2e041dc-53f4-40c5-975d-4baf775e13a0",
                    "race_number":6,
                    "meeting_name":"Parx Racing",
                    "category_id":"4a2788f8-e825-4d36-9894-efd4baf1cfae",
                    "advertised_start":{
                       "seconds":1733253900
                    },
                 },
              }
           },
           "message":"Next 10 races from each category"
        }
        """
        return response.data(using: .utf8)!
    }
}

final class HTTPClientReturnWrongDataStub: HTTPClient {
    func getRequest(url _: String) async throws -> Data {
        Data()
    }
}

final class HTTPClientGetFailedStub: HTTPClient {
    func getRequest(url _: String) async throws -> Data {
        throw RequestError.invalidURL
    }
}
