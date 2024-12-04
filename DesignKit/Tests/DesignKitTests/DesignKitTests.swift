@testable import DesignKit
import SwiftUI
import XCTest

final class DesignKitTests: XCTestCase {
    func testColorShouldReturnOrangeWhenTheTokenIsOrange() {
        let expectedColor = Color.orange

        XCTAssertEqual(DesignKit.Color.orange, expectedColor)
    }

    func testIconShouldReturnHorseWhenTheTokenIsHorse() {
        let expectedIcon = UIImage(named: "ic_horse", in: Bundle.module, compatibleWith: nil)

        XCTAssertEqual(DesignKit.Icon.horse, expectedIcon)
    }

    func testTypographyShouldReturnHeadlineWhenTheTokenIsTitle() {
        let expectedFont = Font.headline

        XCTAssertEqual(DesignKit.Font.title, expectedFont)
    }

    func testSpacingShouldReturn16WhenTheTokenIsSpacing05() {
        let expectedSpacing: CGFloat = 16

        XCTAssertEqual(DesignKit.Spacing.spacing05, expectedSpacing)
    }
}
