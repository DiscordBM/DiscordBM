import DiscordBM
import XCTest

class BotAuthManagerTests: XCTestCase {
    
    let clientId = "121232141392410"
    lazy var manager = BotAuthManager(clientId: clientId)
    
    func testBotAuthURLPlain() throws {
        let url = manager.makeBotAuthorizationURL()

        XCTAssertEqual(
            url,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=0&scope=bot%20applications.commands"
        )
    }

    func testBotAuthURLWithCommands() throws {
        let url = manager.makeBotAuthorizationURL(
            withApplicationCommands: false,
            permissions: [.addReactions, .changeNickname]
        )

        XCTAssertEqual(
            url,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=67108928&scope=bot"
        )
    }

    func testBotAuthURLFull() throws {
        let url = manager.makeBotAuthorizationURL(
            withApplicationCommands: false,
            permissions: [.manageRoles, .manageGuild, .createInstantInvite],
            guildId: "123456789123456789",
            disableGuildSelect: true
        )

        XCTAssertEqual(
            url,
            "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=268435489&scope=bot&guild_id=123456789123456789&disable_guild_select=true"
        )
    }
}
