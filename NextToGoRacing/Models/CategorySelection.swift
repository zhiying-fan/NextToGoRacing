//
//  CategorySelection.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 5/12/2024.
//

import DesignKit
import Foundation
import UIKit

enum RaceCategory: String, Decodable, CaseIterable {
    case horse = "4a2788f8-e825-4d36-9894-efd4baf1cfae"
    case greyhound = "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
    case harness = "161d9be2-e909-4326-8c2c-35ed71fb460b"
}

extension RaceCategory {
    var icon: UIImage {
        switch self {
        case .horse:
            DesignKit.Icon.horse
        case .greyhound:
            DesignKit.Icon.greyhound
        case .harness:
            DesignKit.Icon.harness
        }
    }
}

struct CategorySelection {
    var category: RaceCategory
    var selected: Bool
}
