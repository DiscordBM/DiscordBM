import Foundation

enum Constants {
    static let token: String = {
        if let token = ProcessInfo.processInfo.environment["BOT_TOKEN"] {
            return token
        } else {
            fatalError("Due to the complexity of making integration tests work, they can only be run by the author of DiscordBM or the Github CI. Please reach out if you are facing any issues because of this")
        }
    }()
    static let botId = "1030118727418646629"
    static let botName = "DisBMLibTestBot"
    static let personalId = "290483761559240704"
    static let personalName = "Mahdi BM"
    static let guildId = "1036881950696288277"
    static let guildName = "DiscordBM Test Server"
    static let channelId = "1036881951463833612"
    static let channelName = "general"
    static let spamChannelId = "1038138527877181542"
    static let webhooksChannelId = "1066277056641503232"
    static let webhooks2ChannelId = "1067783166074564658"
    static let perm1ChannelId = "1069609693573554207"
    static let perm2ChannelId = "1069614568466305135"
    static let perm3ChannelId = "1069615830851145798"
    static let secondAccountId = "966330655069843457"
    static let reactionChannelId = "1073282726750330889"
    static let threadsChannelId = "1074227452987052052"
    static let forumChannelId = "1075089016979984435"
    static let announcementsChannelId = "1075135538715172954"
}
