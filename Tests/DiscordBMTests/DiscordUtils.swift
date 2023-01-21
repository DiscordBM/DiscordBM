@testable import DiscordBM
import XCTest

class DiscordUtilsTests: XCTestCase {
    
    func test() {
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.userMention(id: id)
            XCTAssertEqual(string, "<@\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.channelMention(id: id)
            XCTAssertEqual(string, "<#\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.roleMention(id: id)
            XCTAssertEqual(string, "<@&\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(name: "abcd", id: id)
            XCTAssertEqual(string, "</abcd:\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(name: "polikj", id: id, subcommand: "hey")
            XCTAssertEqual(string, "</polikj hey:\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(
                name: "bhjksa",
                id: id,
                subcommand: "poi",
                subcommandGroup: "homdas"
            )
            XCTAssertEqual(string, "</bhjksa homdas poi:\(id)>")
        }
        
        do {
            let string = DiscordUtils.standardUnicodeEmoji(emoji: "🥳")
            XCTAssertEqual(string, "🥳")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.customEmoji(name: "qwerrt", id: id)
            XCTAssertEqual(string, "<:qwerrt:\(id)>")
        }
        
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.customAnimatedEmoji(name: "pwqoe", id: id)
            XCTAssertEqual(string, "<a:pwqoe:\(id)>")
        }
        
        
        do {
            let date = Date()
            let string1 = DiscordUtils.timestamp(date: date)
            let string2 = DiscordUtils.timestamp(unixTimestamp: date.timeIntervalSince1970)
            let string3 = DiscordUtils.timestamp(unixTimestamp: Int(date.timeIntervalSince1970))
            XCTAssertEqual(string1, "<t:\(Int(date.timeIntervalSince1970))>")
            XCTAssertEqual(string1, string2)
            XCTAssertEqual(string2, string3)
            XCTAssertEqual(string3, string1)
        }
        
        do {
            let date = Date()
            let string1 = DiscordUtils.timestamp(date: date, style: .relativeTime)
            let string2 = DiscordUtils.timestamp(
                unixTimestamp: date.timeIntervalSince1970,
                style: .relativeTime
            )
            let string3 = DiscordUtils.timestamp(
                unixTimestamp: Int(date.timeIntervalSince1970),
                style: .relativeTime
            )
            XCTAssertEqual(string1, "<t:\(Int(date.timeIntervalSince1970)):R>")
            XCTAssertEqual(string1, string2)
            XCTAssertEqual(string2, string3)
            XCTAssertEqual(string3, string1)
        }
    }
    
    func testEscapingSpecialCharacters() throws {
        let text = #"""
        *Hello!*
        __***How are you?***__
        > _I'm fine thank you!_
        > ~Not really :\(~
        || Just Kidding! || LOL | HEHE
        """#
        let expected = #"""
        \*Hello!\*
        \_\_\*\*\*How are you?\*\*\*\_\_
        \> \_I'm fine thank you!\_
        \> \~Not really :\\(\~
        \|\| Just Kidding! \|\| LOL \| HEHE
        """#
        let escaped = DiscordUtils.escapingSpecialCharacters(text, forChannelType: .text)
        XCTAssertEqual(escaped, expected)
    }
    
    func testExtractWebhookIdAndToken() throws {
        let webhookUrl = "https://discord.com/api/webhooks/1066287437724266536/dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
        let expectedId = "1066287437724266536"
        let expectedToken = "dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
        
        let (id1, token1) = try XCTUnwrap(
            DiscordUtils.extractWebhookIdAndToken(webhookUrl: webhookUrl)
        )
        XCTAssertEqual(id1, expectedId)
        XCTAssertEqual(token1, expectedToken)
        
        let (id2, token2) = try XCTUnwrap(
            DiscordUtils.extractWebhookIdAndToken(webhookUrl: webhookUrl + "/")
        )
        XCTAssertEqual(id2, expectedId)
        XCTAssertEqual(token2, expectedToken)
        
        let (id3, token3) = try XCTUnwrap(
            WebhookAddress.url(webhookUrl).toIdAndToken()
        )
        XCTAssertEqual(id3, expectedId)
        XCTAssertEqual(token3, expectedToken)
    }
}
