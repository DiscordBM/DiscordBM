import DiscordBM
import DiscordModels
import XCTest

class SnowflakeTests: XCTestCase {

    func testSnowflakeParse() throws {
        let anySnowflake: AnySnowflake = "1030118727418646629"

        let snowflakeInfo = try XCTUnwrap(anySnowflake.parse())

        XCTAssertEqual(snowflakeInfo.timestamp, 1665669843297)
        XCTAssertEqual(snowflakeInfo.workerId, 2)
        XCTAssertEqual(snowflakeInfo.processId, 1)
        XCTAssertEqual(snowflakeInfo.sequenceNumber, 101)
        XCTAssertEqual(snowflakeInfo.date.description, "2022-10-13 14:04:03 +0000")

        let snowflake: AnySnowflake = AnySnowflake(info: snowflakeInfo)
        XCTAssertEqual(snowflake, anySnowflake)

        let snowflakeInfoWithDate = SnowflakeInfo(
            date: snowflakeInfo.date,
            workerId: snowflakeInfo.workerId,
            processId: snowflakeInfo.processId,
            sequenceNumber: snowflakeInfo.sequenceNumber
        )

        XCTAssertEqual(snowflakeInfoWithDate.timestamp, snowflakeInfo.timestamp)
    }
}
