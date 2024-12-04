//
//  RequestError.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

enum RequestError: Error {
    case invalidURL
    case noInternet
    case invalidResponse
}

extension Error {
    var isConnectionError: Bool {
        let connectionErrorCodes = [
            NSURLErrorBackgroundSessionInUseByAnotherProcess, /// Error Code: `-996`
            NSURLErrorCannotFindHost, /// Error Code: ` -1003`
            NSURLErrorCannotConnectToHost, /// Error Code: ` -1004`
            NSURLErrorNetworkConnectionLost, /// Error Code: ` -1005`
            NSURLErrorNotConnectedToInternet, /// Error Code: ` -1009`
            NSURLErrorSecureConnectionFailed, /// Error Code: ` -1200`
        ]
        return connectionErrorCodes.contains(_code)
    }
}
