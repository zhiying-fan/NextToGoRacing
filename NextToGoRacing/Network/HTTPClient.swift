//
//  HTTPClient.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

protocol HTTPClient {
    func getRequest(url: String) async throws -> Data
}

final class DefaultHTTPClient: HTTPClient {
    let httpAPI: HTTPAPI

    init(httpAPI: HTTPAPI = URLSession.shared) {
        self.httpAPI = httpAPI
    }

    func getRequest(url: String) async throws -> Data {
        guard
            let requestURL = URL(string: url)
        else {
            throw RequestError.invalidURL
        }

        do {
            let (data, response) = try await httpAPI.data(from: requestURL)
            try validateResponse(response)

            return data
        } catch {
            if error.isConnectionError {
                throw RequestError.noInternet
            } else {
                throw error
            }
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard
            let httpURLResponse = response as? HTTPURLResponse
        else {
            throw RequestError.invalidResponse
        }

        switch httpURLResponse.statusCode {
        case 200 ... 299:
            return
        default:
            throw RequestError.invalidResponse
        }
    }
}
