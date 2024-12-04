//
//  HTTPAPI.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

protocol HTTPAPI {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPAPI {}
