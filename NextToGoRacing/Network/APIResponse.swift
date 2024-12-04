//
//  APIResponse.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: T
    let message: String
}
