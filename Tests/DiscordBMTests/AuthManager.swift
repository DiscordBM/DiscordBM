@testable import DiscordBM
import XCTest

class AuthManagerTests: XCTestCase {
    
    let clientId = "121232141392410"
    let clientSecret = "HHBHABHSHJNKanhhhHKNjHHNhwda"
    lazy var manager = AuthManager(
        clientId: clientId,
        clientSecret: clientSecret
    )
    
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
