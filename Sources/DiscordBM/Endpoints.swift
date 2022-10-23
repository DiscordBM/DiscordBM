import NIOHTTP1

public enum CacheableEndpointIdentity: Int, Sendable, Hashable, CaseIterable, CustomStringConvertible {
    case getGateway
    case getGatewayBot
    case getApplicationGlobalCommands
    case getGuild
    case searchGuildMembers
    case getGuildMember
    case getChannel
    case getChannelMessages
    case getChannelMessage
    
    public var description: String {
        switch self {
        case .getGateway: return "getGateway"
        case .getGatewayBot: return "getGatewayBot"
        case .getApplicationGlobalCommands: return "getApplicationGlobalCommands"
        case .getGuild: return "getGuild"
        case .searchGuildMembers: return "searchGuildMembers"
        case .getGuildMember: return "getGuildMember"
        case .getChannel: return "getChannel"
        case .getChannelMessages: return "getChannelMessages"
        case .getChannelMessage: return "getChannelMessage"
        }
    }
    
    init? (endpoint: Endpoint) {
        switch endpoint {
        case .getGateway: self = .getGateway
        case .getGatewayBot: self = .getGatewayBot
        case .createInteractionResponse: return nil
        case .editOriginalInteractionResponse: return nil
        case .deleteOriginalInteractionResponse: return nil
        case .postFollowupGatewayInteractionResponse: return nil
        case .editGatewayInteractionResponseFollowup: return nil
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
        case .addGuildMemberRole: return nil
        case .removeGuildMemberRole: return nil
        case .addReaction: return nil
        }
    }
}

/// API Endpoint.
public enum Endpoint {
    case getGateway
    case getGatewayBot
    
    case createInteractionResponse(id: String, token: String)
    case editOriginalInteractionResponse(appId: String, token: String)
    case deleteOriginalInteractionResponse(appId: String, token: String)
    case postFollowupGatewayInteractionResponse(appId: String, token: String)
    case editGatewayInteractionResponseFollowup(appId: String, id: String, token: String)
    
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
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case removeGuildMemberRole(guildId: String, userId: String, roleId: String)
    
    case addReaction(channelId: String, messageId: String, emoji: String)
    
    var urlSuffix: String {
        switch self {
        case .getGateway:
            return "gateway"
        case .getGatewayBot:
            return "gateway/bot"
        case let .createInteractionResponse(id, token):
            return "interactions/\(id)/\(token)/callback"
        case let .editOriginalInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .deleteOriginalInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .postFollowupGatewayInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)"
        case let .editGatewayInteractionResponseFollowup(appId, id, token):
            return "webhooks/\(appId)/\(token)/messages/\(id)"
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
            return "/channels/\(id)/messages"
        case let .getChannelMessage(id, messageId):
            return "/channels/\(id)/messages/\(messageId)"
        case let .leaveGuild(id):
            return "users/@me/guilds/\(id)"
        case let .createGuildRole(guildId):
            return "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            return "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .removeGuildMemberRole(guildId, userId, roleId):
            return "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
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
        case .editOriginalInteractionResponse: return .PATCH
        case .deleteOriginalInteractionResponse: return .DELETE
        case .postFollowupGatewayInteractionResponse: return .POST
        case .editGatewayInteractionResponseFollowup: return .PATCH
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
        case .addGuildMemberRole: return .PUT
        case .removeGuildMemberRole: return .DELETE
        case .addReaction: return .PUT
        }
    }
    
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case .createInteractionResponse, .editOriginalInteractionResponse, .deleteOriginalInteractionResponse, .postFollowupGatewayInteractionResponse, .editGatewayInteractionResponseFollowup:
            return false
        case .getGateway, .getGatewayBot, .postCreateMessage, .patchEditMessage, .deleteMessage, .createApplicationGlobalCommand, .getApplicationGlobalCommands, .deleteApplicationGlobalCommand, .getGuild, .searchGuildMembers, .getGuildMember, .getChannel, .getChannelMessages, .getChannelMessage, .leaveGuild, .createGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .addReaction:
            return true
        }
    }
    
    var id: Int {
        switch self {
        case .getGateway: return 1
        case .getGatewayBot: return 2
        case .createInteractionResponse: return 3
        case .editOriginalInteractionResponse: return 4
        case .deleteOriginalInteractionResponse: return 5
        case .postFollowupGatewayInteractionResponse: return 6
        case .editGatewayInteractionResponseFollowup: return 7
        case .postCreateMessage: return 8
        case .patchEditMessage: return 9
        case .deleteMessage: return 10
        case .createApplicationGlobalCommand: return 11
        case .getApplicationGlobalCommands: return 12
        case .deleteApplicationGlobalCommand: return 13
        case .getGuild: return 14
        case .searchGuildMembers: return 15
        case .getGuildMember: return 16
        case .getChannel: return 17
        case .getChannelMessages: return 18
        case .getChannelMessage: return 19
        case .leaveGuild: return 20
        case .createGuildRole: return 21
        case .addGuildMemberRole: return 22
        case .removeGuildMemberRole: return 23
        case .addReaction: return 24
        }
    }
}
