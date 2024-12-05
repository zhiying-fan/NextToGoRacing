//
//  HTTPClientTests.swift
//  NextToGoRacingTests
//
//  Created by Zhiying Fan on 4/12/2024.
//

@testable import NextToGoRacing
import XCTest

final class HTTPClientTests: XCTestCase {
    func testGetRequest_whenPassEmptyURL_shouldThrowInvalidURL() async {
        // Given
        let httpAPIStub = HTTPAPIRequestSuccessfullyStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)
        var thrownError: Error?

        // When
        do {
            _ = try await httpClient.getRequest(url: "")
        } catch {
            thrownError = error
        }

        // Then
        XCTAssertEqual(thrownError as? RequestError, RequestError.invalidURL)
    }

    func testGetRequest_whenAPIReturn1003Error_shouldThrowNoInternet() async {
        // Given
        let httpAPIStub = HTTPAPINoInternetStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)
        var thrownError: Error?

        // When
        do {
            _ = try await httpClient.getRequest(url: "https://abc.com")
        } catch {
            thrownError = error
        }

        // Then
        XCTAssertEqual(thrownError as? RequestError, RequestError.noInternet)
    }

    func testGetRequest_whenAPIReturn401_shouldThrowInvalidResponse() async {
        // Given
        let httpAPIStub = HTTPAPIInvalidResponseStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)
        var thrownError: Error?

        // When
        do {
            _ = try await httpClient.getRequest(url: "https://abc.com")
        } catch {
            thrownError = error
        }

        // Then
        XCTAssertEqual(thrownError as? RequestError, RequestError.invalidResponse)
    }

    func testGetRequest_whenThereIsNoError_shouldReturnData() async {
        // Given
        let httpAPIStub = HTTPAPIRequestSuccessfullyStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)

        // When
        let data = try? await httpClient.getRequest(url: "https://abc.com")

        // Then
        XCTAssertEqual(data, Data())
    }
}

final class HTTPAPIRequestSuccessfullyStub: HTTPAPI {
    func data(from _: URL) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(url: URL(string: "https://abc.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(), response)
    }
}

final class HTTPAPINoInternetStub: HTTPAPI {
    func data(from _: URL) async throws -> (Data, URLResponse) {
        throw NSError(domain: "", code: -1003)
    }
}

final class HTTPAPIInvalidResponseStub: HTTPAPI {
    func data(from _: URL) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(url: URL(string: "https://abc.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        return (Data(), response)
    }
}
