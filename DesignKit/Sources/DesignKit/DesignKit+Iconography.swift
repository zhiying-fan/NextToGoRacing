//
//  DesignKit+Iconography.swift
//
//
//  Created by Zhiying Fan on 4/12/2024.
//

import Foundation
import UIKit

public extension DesignKit {
    enum Icon {}
}

public extension DesignKit.Icon {
    static let horse = imageInModule(named: "ic_horse")
    static let greyhound = imageInModule(named: "ic_greyhound")
    static let harness = imageInModule(named: "ic_harness")

    static func imageInModule(named: String) -> UIImage {
        if let image = UIImage(named: named, in: Bundle.module, compatibleWith: nil) {
            image
        } else {
            fatalError("Can not find matched image in DesignKit named: \(named)")
        }
    }
}
