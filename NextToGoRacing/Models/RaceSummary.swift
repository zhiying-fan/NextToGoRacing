//
//  RaceSummary.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation

struct RaceSummary: Decodable, Equatable {
    let raceID: String
    let raceNumber: Int
    let meetingName: String
    let categoryID: String
    let advertisedStart: AdvertisedStart

    enum CodingKeys: String, CodingKey {
        case raceID = "race_id"
        case raceNumber = "race_number"
        case meetingName = "meeting_name"
        case categoryID = "category_id"
        case advertisedStart = "advertised_start"
    }
}