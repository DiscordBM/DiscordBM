import DiscordBM
import DiscordModels
import XCTest

@testable import DiscordHTTP

class CDNEndpointTests: XCTestCase {

    let userId: UserSnowflake = "816681064855502868"
    let guildId: GuildSnowflake = "922186320275722322"
    let stickerId: StickerSnowflake = "749054660769218631"
    let avatar = "b94e12ce3debd281000d5291eec2b502"

    func testWithoutFileExtensionMatchesCDNEndpoint() throws {
        let endpoint = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)

        XCTAssertEqual(
            endpoint.url,
            "https://cdn.discordapp.com/avatars/816681064855502868/b94e12ce3debd281000d5291eec2b502"
        )
        XCTAssertEqual(FormattedCDNEndpoint(endpoint).url, endpoint.url)
        XCTAssertEqual(FormattedCDNEndpoint(endpoint).parameters, endpoint.parameters)
    }

    func testAppendsFileExtension() throws {
        let endpoint = FormattedCDNEndpoint(
            .userAvatar(userId: userId, avatar: avatar),
            fileExtension: CDNEndpoint.ImageFormat.webp.rawValue
        )

        XCTAssertEqual(
            endpoint.url,
            "https://cdn.discordapp.com/avatars/816681064855502868/b94e12ce3debd281000d5291eec2b502.webp"
        )
    }

    func testReplacesFixedPNGExtension() throws {
        let defaultUserAvatar = CDNEndpoint.defaultUserAvatar(discriminator: "3")
        XCTAssertEqual(defaultUserAvatar.url, "https://cdn.discordapp.com/embed/avatars/3.png")
        XCTAssertEqual(FormattedCDNEndpoint(defaultUserAvatar).url, defaultUserAvatar.url)
        XCTAssertEqual(
            FormattedCDNEndpoint(defaultUserAvatar, fileExtension: "jpeg").url,
            "https://cdn.discordapp.com/embed/avatars/3.jpeg"
        )

        let sticker = CDNEndpoint.sticker(stickerId: stickerId)
        XCTAssertEqual(sticker.url, "https://cdn.discordapp.com/stickers/749054660769218631.png")
        XCTAssertEqual(
            FormattedCDNEndpoint(sticker, fileExtension: CDNEndpoint.StickerFormat.lottie.rawValue).url,
            "https://cdn.discordapp.com/stickers/749054660769218631.json"
        )
    }

    func testStickerGIFUsesMediaBaseURL() throws {
        let sticker = CDNEndpoint.sticker(stickerId: stickerId)
        XCTAssertEqual(
            FormattedCDNEndpoint(sticker, fileExtension: CDNEndpoint.StickerFormat.gif.rawValue).url,
            "https://media.discordapp.net/stickers/749054660769218631.gif"
        )

        let userAvatar = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)
        XCTAssertEqual(
            FormattedCDNEndpoint(userAvatar, fileExtension: CDNEndpoint.ImageFormat.gif.rawValue).url,
            "https://cdn.discordapp.com/avatars/816681064855502868/b94e12ce3debd281000d5291eec2b502.gif"
        )
    }

    func testIdentityMatchesWrappedEndpoint() throws {
        let wrapped = CDNEndpoint.guildMemberAvatar(guildId: guildId, userId: userId, avatar: avatar)
        let formatted = FormattedCDNEndpoint(wrapped, fileExtension: "webp")

        XCTAssertEqual(formatted.id, wrapped.id)
        XCTAssertEqual(AnyEndpoint.formattedCDN(formatted).id, AnyEndpoint.cdn(wrapped).id)
        XCTAssertEqual(
            CacheableEndpointIdentity(endpoint: .formattedCDN(formatted)),
            .cdn(.guildMemberAvatar)
        )
        XCTAssertEqual(formatted.parameters, wrapped.parameters + ["webp"])
    }

    func testCacheItemsMatchOnlyForTheSameURL() throws {
        func cacheItem(
            _ endpoint: AnyEndpoint,
            queries: [(String, String?)] = []
        ) throws -> ClientCache.CacheableItem {
            ClientCache.CacheableItem(
                identity: try XCTUnwrap(CacheableEndpointIdentity(endpoint: endpoint)),
                parameters: endpoint.cacheParameters,
                queries: queries
            )
        }

        let sticker = CDNEndpoint.sticker(stickerId: stickerId)
        XCTAssertEqual(
            try cacheItem(.cdn(sticker)),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(sticker, fileExtension: "png")))
        )
        XCTAssertNotEqual(
            try cacheItem(.cdn(sticker)),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(sticker, fileExtension: "gif")))
        )

        let userAvatar = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)
        XCTAssertEqual(
            try cacheItem(.cdn(userAvatar)),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar)))
        )
        XCTAssertNotEqual(
            try cacheItem(.cdn(userAvatar)),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar, fileExtension: "png")))
        )
        XCTAssertNotEqual(
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar, fileExtension: "png"))),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar, fileExtension: "webp")))
        )

        XCTAssertEqual(
            try cacheItem(.cdn(userAvatar)),
            try cacheItem(
                .formattedCDN(FormattedCDNEndpoint(userAvatar)),
                queries: [("size", nil), ("animated", nil)]
            )
        )
        XCTAssertNotEqual(
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar)), queries: [("size", "64")]),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar)), queries: [("size", "128")])
        )
        XCTAssertNotEqual(
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar)), queries: [("animated", "true")]),
            try cacheItem(.formattedCDN(FormattedCDNEndpoint(userAvatar)))
        )
    }
}
