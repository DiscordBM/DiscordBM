/// Must not import `DiscordModels` as `@testable` to make sure
/// these tests are run using `public` declarations.
@testable import DiscordBM
import XCTest

class DecodeToleranceTests: XCTestCase {

    /// Test that collections of raw-representable codable enums
    /// don't fail on decoding unknown values.
    func testNoThrowEnums() throws {
        do {
            let text = """
            {
                "values": [
                    1,
                    2,
                    3,
                    500
                ]
            }
            """
            
            /// The values include `500` which is not in `DiscordChannel.Kind`.
            /// Decoding the `500` normally fails, but based on our `UnstableEnum` ,acro,
            /// this should never fail in internal `DiscordBM` decode processes.
            let decoded = try JSONDecoder().decode(
                TestContainer<DiscordChannel.Kind>.self,
                from: Data(text.utf8)
            ).values
            XCTAssertEqual(decoded.count, 3)
        }
        
        do {
            let text = """
            {
                "values": [
                    "online",
                    "dnd",
                    "bothOfflineAndOnlineWhichIsInvalid",
                    "idle",
                    "offline"
                ]
            }
            """
            
            /// Refer to the comment above for some explanations.
            let decoded = try JSONDecoder().decode(
                TestContainer<Gateway.Status>.self,
                from: Data(text.utf8)
            ).values
            XCTAssertEqual(decoded.count, 4)
        }
        
        do {
            let text = """
            {
                "scopes": [
                    "something.completely.new",
                    "activities.read",
                    "activities.write",
                    "applications.builds.read",
                    "applications.builds.upload",
                    "applications.commands"
                ],
                "permissions": "15"
            }
            """
            
            /// Refer to the comment above for some explanations.
            let decoded = try JSONDecoder().decode(
                DiscordApplication.InstallParams.self,
                from: Data(text.utf8)
            )
            XCTAssertEqual(decoded.scopes.count, 5)
            XCTAssertEqual(decoded.permissions.rawValue, 15)
        }

        do {
            let text = #"{"values":["BadFeature"]}"#
            _ = try JSONDecoder().decode(TestContainer<Guild.Feature>.self, from: Data(text.utf8))
        }

        do {
            let text = #"[{"id":"1036881950696288277","name":"DiscordBM Test Server","icon":null,"owner":false,"permissions":"140737488355327","features":["NEWS","COMMUNITY","GUILD_ONBOARDING_HAS_PROMPTS","GUILD_ONBOARDING_EVER_ENABLED","GUILD_SERVER_GUIDE","GUILD_ONBOARDING"]}]"#
            _ = try JSONDecoder().decode([PartialGuild].self, from: Data(text.utf8))
        }
    }
}

private struct TestContainer<C: Codable>: Codable {
    var values: [C]
}
