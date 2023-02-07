import NIOHTTP1

public enum CacheableEndpointIdentity: Int, Sendable, Hashable, CustomStringConvertible {
    case getGateway
    case getGatewayBot
    case getInteractionResponse
    case getFollowupInteractionResponse
    case getApplicationGlobalCommands
    case getGuild
    case searchGuildMembers
    case getGuildMember
    case getChannel
    case getChannelMessages
    case getChannelMessage
    case getGuildAuditLogs
    case getChannelWebhooks
    case getGuildWebhooks
    case getWebhook1
    case getWebhook2
    case getWebhookMessage
    
    public var description: String {
        switch self {
        case .getGateway: return "getGateway"
        case .getGatewayBot: return "getGatewayBot"
        case .getInteractionResponse: return "getInteractionResponse"
        case .getFollowupInteractionResponse: return "getFollowupInteractionResponse"
        case .getApplicationGlobalCommands: return "getApplicationGlobalCommands"
        case .getGuild: return "getGuild"
        case .searchGuildMembers: return "searchGuildMembers"
        case .getGuildMember: return "getGuildMember"
        case .getChannel: return "getChannel"
        case .getChannelMessages: return "getChannelMessages"
        case .getChannelMessage: return "getChannelMessage"
        case .getGuildAuditLogs: return "getGuildAuditLogs"
        case .getChannelWebhooks: return "getChannelWebhooks"
        case .getGuildWebhooks: return "getGuildWebhooks"
        case .getWebhook1: return "getWebhook1"
        case .getWebhook2: return "getWebhook2"
        case .getWebhookMessage: return "getWebhookMessage"
        }
    }
    
    init? (endpoint: Endpoint) {
        switch endpoint {
        case .getGateway: self = .getGateway
        case .getGatewayBot: self = .getGatewayBot
        case .createInteractionResponse: return nil
        case .getInteractionResponse: self = .getInteractionResponse
        case .editInteractionResponse: return nil
        case .deleteInteractionResponse: return nil
        case .postFollowupInteractionResponse: return nil
        case .getFollowupInteractionResponse: self = .getFollowupInteractionResponse
        case .editFollowupInteractionResponse: return nil
        case .deleteFollowupInteractionResponse: return nil
        case .createMessage: return nil
        case .editMessage: return nil
        case .deleteMessage: return nil
        case .createApplicationGlobalCommand: return nil
        case .getApplicationGlobalCommands: self = .getApplicationGlobalCommands
        case .deleteApplicationGlobalCommand: return nil
        case .getGuild: self = .getGuild
        case .searchGuildMembers: self = .searchGuildMembers
        case .getGuildMember: self = .getGuildMember
        case .getChannel: self = .getChannel
        case .getChannelMessages: self = .getChannelMessages
        case .getChannelMessage: self = .getChannelMessage
        case .leaveGuild: return nil
        case .createGuildRole: return nil
        case .deleteGuildRole: return nil
        case .addGuildMemberRole: return nil
        case .removeGuildMemberRole: return nil
        case .getGuildAuditLogs: self = .getGuildAuditLogs
        case .addReaction: return nil
        case .createDM: return nil
        case .createWebhook: return nil
        case .getChannelWebhooks: self = .getChannelWebhooks
        case .getGuildWebhooks: self = .getGuildWebhooks
        case .getWebhook1: self = .getWebhook1
        case .getWebhook2: self = .getWebhook2
        case .modifyWebhook1: return nil
        case .modifyWebhook2: return nil
        case .deleteWebhook1: return nil
        case .deleteWebhook2: return nil
        case .executeWebhook: return nil
        case .getWebhookMessage: self = .getWebhookMessage
        case .editWebhookMessage: return nil
        case .deleteWebhookMessage: return nil
        }
    }
}

/// API Endpoint.
public enum Endpoint: Sendable {
    case getGateway
    case getGatewayBot
    
    case createInteractionResponse(id: String, token: String)
    case getInteractionResponse(appId: String, token: String)
    case editInteractionResponse(appId: String, token: String)
    case deleteInteractionResponse(appId: String, token: String)
    case postFollowupInteractionResponse(appId: String, token: String)
    case getFollowupInteractionResponse(appId: String, token: String, messageId: String)
    case editFollowupInteractionResponse(appId: String, token: String, messageId: String)
    case deleteFollowupInteractionResponse(appId: String, token: String, messageId: String)
    
    case createMessage(channelId: String)
    case editMessage(channelId: String, messageId: String)
    case deleteMessage(channelId: String, messageId: String)
    
    case createApplicationGlobalCommand(appId: String)
    case getApplicationGlobalCommands(appId: String)
    case deleteApplicationGlobalCommand(appId: String, id: String)
    
    case getGuild(id: String)
    case searchGuildMembers(id: String)
    case getGuildMember(id: String, userId: String)
    
    case getChannel(id: String)
    case getChannelMessages(channelId: String)
    case getChannelMessage(channelId: String, messageId: String)
    
    case leaveGuild(id: String)
    
    case createGuildRole(guildId: String)
    case deleteGuildRole(guildId: String, roleId: String)
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case removeGuildMemberRole(guildId: String, userId: String, roleId: String)
    case getGuildAuditLogs(guildId: String)
    
    case addReaction(channelId: String, messageId: String, emoji: String)
    
    case createDM
    
    case createWebhook(channelId: String)
    case getChannelWebhooks(channelId: String)
    case getGuildWebhooks(guildId: String)
    case getWebhook1(id: String)
    case getWebhook2(id: String, token: String)
    case modifyWebhook1(id: String)
    case modifyWebhook2(id: String, token: String)
    case deleteWebhook1(id: String)
    case deleteWebhook2(id: String, token: String)
    case executeWebhook(id: String, token: String)
    case getWebhookMessage(id: String, token: String, messageId: String)
    case editWebhookMessage(id: String, token: String, messageId: String)
    case deleteWebhookMessage(id: String, token: String, messageId: String)
    
    var urlSuffix: String {
        let suffix: String
        switch self {
        case .getGateway:
            suffix = "gateway"
        case .getGatewayBot:
            suffix = "gateway/bot"
        case let .createInteractionResponse(id, token):
            suffix = "interactions/\(id)/\(token)/callback"
        case let .getInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)/messages/@original"
        case let .editInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)/messages/@original"
        case let .deleteInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)/messages/@original"
        case let .postFollowupInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)"
        case let .getFollowupInteractionResponse(appId, token, messageId):
            suffix = "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .editFollowupInteractionResponse(appId, token, messageId):
            suffix = "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .deleteFollowupInteractionResponse(appId, token, messageId):
            suffix = "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .createMessage(channelId):
            suffix = "channels/\(channelId)/messages"
        case let .editMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .createApplicationGlobalCommand(appId):
            suffix = "applications/\(appId)/commands"
        case let .getApplicationGlobalCommands(appId):
            suffix = "applications/\(appId)/commands"
        case let .deleteApplicationGlobalCommand(appId, id):
            suffix = "applications/\(appId)/commands/\(id)"
        case let .getGuild(id):
            suffix = "guilds/\(id)"
        case let .searchGuildMembers(id):
            suffix = "guilds/\(id)/members/search"
        case let .getGuildMember(id, userId):
            suffix = "guilds/\(id)/members/\(userId)"
        case let .getChannel(id):
            suffix = "channels/\(id)"
        case let .getChannelMessages(id):
            suffix = "channels/\(id)/messages"
        case let .getChannelMessage(id, messageId):
            suffix = "channels/\(id)/messages/\(messageId)"
        case let .leaveGuild(id):
            suffix = "users/@me/guilds/\(id)"
        case let .createGuildRole(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .deleteGuildRole(guildId, roleId):
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .addGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .removeGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .getGuildAuditLogs(guildId):
            suffix = "guilds/\(guildId)/audit-logs"
        case let .addReaction(channelId, messageId, emoji):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        case .createDM:
            suffix = "users/@me/channels"
        case let .createWebhook(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .getChannelWebhooks(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .getGuildWebhooks(guildId):
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook1(id),
            let .modifyWebhook1(id),
            let .deleteWebhook1(id):
            suffix = "webhooks/\(id)"
        case let .getWebhook2(id, token),
            let .modifyWebhook2(id, token),
            let .deleteWebhook2(id, token),
            let .executeWebhook(id, token):
            suffix = "webhooks/\(id)/\(token)"
        case let .getWebhookMessage(id, token, messageId):
            suffix = "webhooks/\(id)/\(token)/messages/\(messageId)"
        case let .editWebhookMessage(id, token, messageId):
            suffix = "webhooks/\(id)/\(token)/messages/\(messageId)"
        case let .deleteWebhookMessage(id, token, messageId):
            suffix = "webhooks/\(id)/\(token)/messages/\(messageId)"
        }
        return suffix.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? suffix
    }
    
    /// Doesn't expose secret url path parameters.
    var urlSuffixDescription: String {
        switch self {
        case .getGateway, .getGatewayBot, .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse, .createMessage, .editMessage, .deleteMessage, .createApplicationGlobalCommand, .getApplicationGlobalCommands, .deleteApplicationGlobalCommand, .getGuild, .searchGuildMembers, .getGuildMember, .getChannel, .getChannelMessages, .getChannelMessage, .leaveGuild, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .addReaction, .createDM, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .modifyWebhook1, .deleteWebhook1:
            return self.urlSuffix
        case let .getWebhook2(id, token),
            let .modifyWebhook2(id, token),
            let .deleteWebhook2(id, token),
            let .executeWebhook(id, token):
            return "webhooks/\(id)/\(token.hash)"
        case let .getWebhookMessage(id, token, messageId):
            return "webhooks/\(id)/\(token.hash)/messages/\(messageId)"
        case let .editWebhookMessage(id, token, messageId):
            return "webhooks/\(id)/\(token.hash)/messages/\(messageId)"
        case let .deleteWebhookMessage(id, token, messageId):
            return "webhooks/\(id)/\(token.hash)/messages/\(messageId)"
        }
    }
    
    var url: String {
        "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/" + urlSuffix
    }
    
    /// Doesn't expose secret url path parameters.
    var urlDescription: String {
        "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/" + urlSuffixDescription
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getGateway: return .GET
        case .getGatewayBot: return .GET
        case .createInteractionResponse: return .POST
        case .getInteractionResponse: return .GET
        case .editInteractionResponse: return .PATCH
        case .deleteInteractionResponse: return .DELETE
        case .postFollowupInteractionResponse: return .POST
        case .getFollowupInteractionResponse: return .GET
        case .editFollowupInteractionResponse: return .PATCH
        case .deleteFollowupInteractionResponse: return .DELETE
        case .createMessage: return .POST
        case .editMessage: return .PATCH
        case .deleteMessage: return .DELETE
        case .createApplicationGlobalCommand: return .POST
        case .getApplicationGlobalCommands: return .GET
        case .deleteApplicationGlobalCommand: return .DELETE
        case .getGuild: return .GET
        case .searchGuildMembers: return .GET
        case .getGuildMember: return .GET
        case .getChannel: return .GET
        case .getChannelMessages: return .GET
        case .getChannelMessage: return .GET
        case .leaveGuild: return .DELETE
        case .createGuildRole: return .POST
        case .deleteGuildRole: return .DELETE
        case .addGuildMemberRole: return .PUT
        case .removeGuildMemberRole: return .DELETE
        case .getGuildAuditLogs: return .GET
        case .addReaction: return .PUT
        case .createDM: return .POST
        case .createWebhook: return .POST
        case .getChannelWebhooks: return .GET
        case .getGuildWebhooks: return .GET
        case .getWebhook1: return .GET
        case .getWebhook2: return .GET
        case .modifyWebhook1: return .PATCH
        case .modifyWebhook2: return .PATCH
        case .deleteWebhook1: return .DELETE
        case .deleteWebhook2: return .DELETE
        case .executeWebhook: return .POST
        case .getWebhookMessage: return .GET
        case .editWebhookMessage: return .PATCH
        case .deleteWebhookMessage: return .DELETE
        }
    }
    
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse:
            return false
        case .getGateway, .getGatewayBot, .createMessage, .editMessage, .deleteMessage, .createApplicationGlobalCommand, .getApplicationGlobalCommands, .deleteApplicationGlobalCommand, .getGuild, .searchGuildMembers, .getGuildMember, .getChannel, .getChannelMessages, .getChannelMessage, .leaveGuild, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .addReaction, .createDM, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .getWebhook2, .modifyWebhook1, .modifyWebhook2, .deleteWebhook1, .deleteWebhook2, .executeWebhook, .getWebhookMessage, .editWebhookMessage, .deleteWebhookMessage:
            return true
        }
    }
    
    /// Some endpoints like don't require an authorization header because the endpoint itself
    /// contains some kind of authorization token. Like half of the webhook endpoints.
    var requiresAuthorizationHeader: Bool {
        switch self {
        case .getGateway, .getGatewayBot, .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse, .createMessage, .editMessage, .deleteMessage, .createApplicationGlobalCommand, .getApplicationGlobalCommands, .deleteApplicationGlobalCommand, .getGuild, .searchGuildMembers, .getGuildMember, .getChannel, .getChannelMessages, .getChannelMessage, .leaveGuild, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .addReaction, .createDM, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .modifyWebhook1, .deleteWebhook1:
            return true
        case .getWebhook2, .modifyWebhook2, .deleteWebhook2, .executeWebhook, .getWebhookMessage, .editWebhookMessage, .deleteWebhookMessage:
            return false
        }
    }
    
    var id: Int {
        switch self {
        case .getGateway: return 1
        case .getGatewayBot: return 2
        case .createInteractionResponse: return 3
        case .getInteractionResponse: return 4
        case .editInteractionResponse: return 5
        case .deleteInteractionResponse: return 6
        case .postFollowupInteractionResponse: return 7
        case .getFollowupInteractionResponse: return 8
        case .editFollowupInteractionResponse: return 9
        case .deleteFollowupInteractionResponse: return 10
        case .createMessage: return 11
        case .editMessage: return 12
        case .deleteMessage: return 13
        case .createApplicationGlobalCommand: return 14
        case .getApplicationGlobalCommands: return 15
        case .deleteApplicationGlobalCommand: return 16
        case .getGuild: return 17
        case .searchGuildMembers: return 18
        case .getGuildMember: return 19
        case .getChannel: return 20
        case .getChannelMessages: return 21
        case .getChannelMessage: return 22
        case .leaveGuild: return 23
        case .createGuildRole: return 24
        case .deleteGuildRole: return 25
        case .addGuildMemberRole: return 26
        case .removeGuildMemberRole: return 27
        case .getGuildAuditLogs: return 28
        case .addReaction: return 29
        case .createDM: return 30
        case .createWebhook: return 31
        case .getChannelWebhooks: return 32
        case .getGuildWebhooks: return 33
        case .getWebhook1: return 34
        case .getWebhook2: return 35
        case .modifyWebhook1: return 36
        case .modifyWebhook2: return 37
        case .deleteWebhook1: return 38
        case .deleteWebhook2: return 39
        case .executeWebhook: return 40
        case .getWebhookMessage: return 41
        case .editWebhookMessage: return 42
        case .deleteWebhookMessage: return 43
        }
    }
}
