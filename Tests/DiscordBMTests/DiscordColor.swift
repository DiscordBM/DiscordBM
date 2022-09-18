@testable import DiscordBM
import XCTest

class DiscordColorTests: XCTestCase {
    
    func testInitFromRGB() {
        let color = DiscordColor(red: 100, green: 67, blue: 188)
        XCTAssertEqual(color.value, 6_570_940)
        let rgb = color.asRGB
        XCTAssertEqual(rgb.red, 100)
        XCTAssertEqual(rgb.green, 67)
        XCTAssertEqual(rgb.blue, 188)
    }
    
    func testInitFromHex() {
        let color = DiscordColor(hex: "#A0B9FF")
        XCTAssertEqual(color.value, DiscordColor(hex: "A0B9FF").value)
        XCTAssertEqual(color.value, 10_533_375)
        let hex = color.asHex
        XCTAssertEqual(hex, "#A0B9FF")
    }
}
