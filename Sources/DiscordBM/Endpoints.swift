import NIOHTTP1

public enum CacheableEndpointIdentity: Int, Sendable, Hashable, CaseIterable, CustomStringConvertible {
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
        case .postCreateMessage: return nil
        case .patchEditMessage: return nil
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
    
    case postCreateMessage(channelId: String)
    case patchEditMessage(channelId: String, messageId: String)
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
    
    var urlSuffix: String {
        switch self {
        case .getGateway:
            return "gateway"
        case .getGatewayBot:
            return "gateway/bot"
        case let .createInteractionResponse(id, token):
            return "interactions/\(id)/\(token)/callback"
        case let .getInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .editInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .deleteInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .postFollowupInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)"
        case let .getFollowupInteractionResponse(appId, token, messageId):
            return "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .editFollowupInteractionResponse(appId, token, messageId):
            return "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .deleteFollowupInteractionResponse(appId, token, messageId):
            return "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .postCreateMessage(channelId):
            return "channels/\(channelId)/messages"
        case let .patchEditMessage(channelId, messageId):
            return "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMessage(channelId, messageId):
            return "channels/\(channelId)/messages/\(messageId)"
        case let .createApplicationGlobalCommand(appId):
            return "applications/\(appId)/commands"
        case let .getApplicationGlobalCommands(appId):
            return "applications/\(appId)/commands"
        case let .deleteApplicationGlobalCommand(appId, id):
            return "applications/\(appId)/commands/\(id)"
        case let .getGuild(id):
            return "guilds/\(id)"
        case let .searchGuildMembers(id):
            return "guilds/\(id)/members/search"
        case let .getGuildMember(id, userId):
            return "guilds/\(id)/members/\(userId)"
        case let .getChannel(id):
            return "channels/\(id)"
        case let .getChannelMessages(id):
            return "channels/\(id)/messages"
        case let .getChannelMessage(id, messageId):
            return "channels/\(id)/messages/\(messageId)"
        case let .leaveGuild(id):
            return "users/@me/guilds/\(id)"
        case let .createGuildRole(guildId):
            return "guilds/\(guildId)/roles"
        case let .deleteGuildRole(guildId, roleId):
            return "guilds/\(guildId)/roles/\(roleId)"
        case let .addGuildMemberRole(guildId, userId, roleId):
            return "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .removeGuildMemberRole(guildId, userId, roleId):
            return "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .getGuildAuditLogs(guildId):
            return "guilds/\(guildId)/audit-logs"
        case let .addReaction(channelId, messageId, emoji):
            return "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        }
    }
    
    var url: String {
        let suffix = urlSuffix.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) ?? urlSuffix
        return "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/" + suffix
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
        case .postCreateMessage: return .POST
        case .patchEditMessage: return .PATCH
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
        }
    }
    
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse:
            return false
        case .getGateway, .getGatewayBot, .postCreateMessage, .patchEditMessage, .deleteMessage, .createApplicationGlobalCommand, .getApplicationGlobalCommands, .deleteApplicationGlobalCommand, .getGuild, .searchGuildMembers, .getGuildMember, .getChannel, .getChannelMessages, .getChannelMessage, .leaveGuild, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .addReaction:
            return true
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
        case .postCreateMessage: return 11
        case .patchEditMessage: return 12
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
        case .removeGuildMemberRole: return 26
        case .getGuildAuditLogs: return 28
        case .addReaction: return 29
        }
    }
}
