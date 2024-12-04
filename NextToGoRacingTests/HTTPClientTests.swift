//
//  HTTPClientTests.swift
//  NextToGoRacingTests
//
//  Created by Zhiying Fan on 4/12/2024.
//

@testable import NextToGoRacing
import XCTest

final class HTTPClientTests: XCTestCase {
    func testGetRequestShouldThrowInvalidURLWhenPassEmpty() async {
        let httpAPIStub = HTTPAPIRequestSuccessfullyStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)

        var thrownError: Error?

        do {
            _ = try await httpClient.getRequest(url: "")
        } catch {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? RequestError, RequestError.invalidURL)
    }

    func testGetRequestShouldThrowNoInternetWhenRequestReturn1003Error() async {
        let httpAPIStub = HTTPAPINoInternetStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)

        var thrownError: Error?

        do {
            _ = try await httpClient.getRequest(url: "https://abc.com")
        } catch {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? RequestError, RequestError.noInternet)
    }

    func testGetRequestShouldThrowInvalidResponseWhenRequestReturn401() async {
        let httpAPIStub = HTTPAPIInvalidResponseStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)

        var thrownError: Error?

        do {
            _ = try await httpClient.getRequest(url: "https://abc.com")
        } catch {
            thrownError = error
        }

        XCTAssertEqual(thrownError as? RequestError, RequestError.invalidResponse)
    }

    func testGetRequestShouldReturnDataWhenThereIsNoError() async {
        let httpAPIStub = HTTPAPIRequestSuccessfullyStub()
        let httpClient = DefaultHTTPClient(httpAPI: httpAPIStub)

        let data = try? await httpClient.getRequest(url: "https://abc.com")

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
