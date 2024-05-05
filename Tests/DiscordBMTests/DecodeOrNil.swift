@_spi(UserInstallableApps) import DiscordModels
import XCTest

class DecodeOrNilTests: XCTestCase {

    typealias IntegrationKindConfiguration = DiscordApplication.IntegrationKindConfiguration
    typealias IntegrationKind = DiscordApplication.IntegrationKind

    func testDecodeSucceeds() throws {
        do {
            let text = """
            {
                "value": 1
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<Interaction.ContextKind>.self,
                from: Data(text.utf8)
            )

            let value = try XCTUnwrap(container.value)

            XCTAssertEqual(value, .botDm)
        }

        do {
            let text = """
            {
                "value": 999999999999
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<Interaction.ContextKind>.self,
                from: Data(text.utf8)
            )

            XCTAssertEqual(container.value, .__undocumented(999999999999))
        }

    }

    func testDictDecodeSucceeds() throws {
        let text = """
        {
           "value":{
              "0":{
                 "oauth2_install_params":{
                    "scopes":[
                       "applications.commands",
                       "bot"
                    ],
                    "permissions":"2048"
                 }
              },
              "1":{
                 "oauth2_install_params":{
                    "scopes":[
                       "applications.commands"
                    ],
                    "permissions":"1"
                 }
              }
           }
        }
        """

        let container = try DiscordGlobalConfiguration.decoder.decode(
            TestContainer<[IntegrationKind: IntegrationKindConfiguration]>.self,
            from: Data(text.utf8)
        )

        let value = try XCTUnwrap(container.value)

        XCTAssertEqual(value.count, 2)
        let first = try XCTUnwrap(value.values.first)
        XCTAssertGreaterThan(first.oauth2_install_params.permissions.rawValue, 0)
    }

    func testDecodeBadValue() throws {
        do {
            let text = """
            {
               "valueddd": 0
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<Interaction.ContextKind>.self,
                from: Data(text.utf8)
            )

            XCTAssertTrue(container.value == nil, String(reflecting: container.value))
        }

        do {
            let text = """
            {
               "value": false
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<Interaction.ContextKind>.self,
                from: Data(text.utf8)
            )

            XCTAssertTrue(container.value == nil, String(reflecting: container.value))
        }
    }

    func testDictDecodeBadValue() throws {
        do {
            let text = """
            {
               "valueddd":{
                  "0":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands",
                           "bot"
                        ],
                        "permissions":"2048"
                     }
                  },
                  "1":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands"
                        ],
                        "permissions":"0"
                     }
                  }
               }
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<[IntegrationKind: IntegrationKindConfiguration]>.self,
                from: Data(text.utf8)
            )

            XCTAssertTrue(container.value == nil, String(reflecting: container.value))
        }

        do {
            let text = """
            {
               "value":{
                  "0":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands",
                           "bot"
                        ],
                        "permissions":"2048"
                     }
                  },
                  "1rrr":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands"
                        ],
                        "permissions":"0"
                     }
                  }
               }
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<[IntegrationKind: IntegrationKindConfiguration]>.self,
                from: Data(text.utf8)
            )

            XCTAssertTrue(container.value == nil, String(reflecting: container.value))
        }

        do {
            let text = """
            {
               "value":{
                  "0":{
                     "oauth2_install_params":{
                        "scopes":[
                           "applications.commands",
                           "bot"
                        ],
                        "permissions":"2048"
                     }
                  },
                  "1":{
                     "oauth2_insttttttttttttttall_params":{
                        "scopes":[
                           "applications.commands"
                        ],
                        "permissions":"0"
                     }
                  }
               }
            }
            """

            let container = try DiscordGlobalConfiguration.decoder.decode(
                TestContainer<[IntegrationKind: IntegrationKindConfiguration]>.self,
                from: Data(text.utf8)
            )

            XCTAssertTrue(container.value == nil, String(reflecting: container.value))
        }
    }

    func testDecodeNothing() throws {
        let text = """
        {}
        """
        let container = try DiscordGlobalConfiguration.decoder.decode(
            TestContainer<Interaction.ContextKind>.self,
            from: Data(text.utf8)
        )

        XCTAssertTrue(container.value == nil, String(reflecting: container.value))
    }

    func testDictDecodeNothing() throws {
        let text = """
        {}
        """
        let container = try DiscordGlobalConfiguration.decoder.decode(
            TestContainer<[IntegrationKind: IntegrationKindConfiguration]>.self,
            from: Data(text.utf8)
        )

        XCTAssertTrue(container.value == nil, String(reflecting: container.value))
    }
}

private struct TestContainer<C: Sendable & Codable>: Codable {
    @DecodeOrNil var value: C?
}
