//
//  RacesDTO.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

struct RacesDTO: Decodable {
    let raceSummaries: [String: RaceSummary]

    enum CodingKeys: String, CodingKey {
        case raceSummaries = "race_summaries"
    }
}
