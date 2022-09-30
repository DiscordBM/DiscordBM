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
    
    func testLowerBound() {
        _ = DiscordColor(value: 0)
        _ = DiscordColor(red: 0, green: 0, blue: 0)
        _ = DiscordColor(hex: "#000000")
    }
    
    func testUpperBound() {
        _ = DiscordColor(value: 16777215)
        _ = DiscordColor(red: 255, green: 255, blue: 255)
        _ = DiscordColor(hex: "#FFFFFF")
    }
    
    func testInsensitiveHex() {
        XCTAssertEqual(DiscordColor(hex: "#FFFFFF").value, 16777215)
        XCTAssertEqual(DiscordColor(hex: "FFFFFF").value, 16777215)
        XCTAssertEqual(DiscordColor(hex: "#ffffff").value, 16777215)
        XCTAssertEqual(DiscordColor(hex: "ffffff").value, 16777215)
    }
}
