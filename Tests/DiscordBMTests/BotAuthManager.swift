import DiscordBM
import XCTest

class BotAuthManagerTests: XCTestCase {
    
    let clientId = "121232141392410"
    lazy var manager = BotAuthManager(clientId: clientId)
    
    func testBotAuthURL() throws {
        do {
            let url = manager.makeBotAuthorizationURL()
            XCTAssertEqual(url, "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=0&scope=bot%20applications.commands")
        }
        
        do {
            let url = manager.makeBotAuthorizationURL(withSlashCommands: false, permissions: [
                .addReactions, .changeNickname
            ])
            XCTAssertEqual(url, "https://discord.com/api/oauth2/authorize?client_id=121232141392410&permissions=67108928&scope=bot")
        }
    }
}
