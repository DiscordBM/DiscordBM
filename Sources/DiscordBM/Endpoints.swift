import Foundation
import NIOHTTP1

/// API Endpoint.
enum Endpoint {
    case getGateway
    
    case createInteractionResponse(id: String, token: String)
    case editOriginalInteractionResponse(appId: String, token: String)
    case deleteGatewayInteractionResponse(appId: String, token: String)
    case postFollowupGatewayInteractionResponse(appId: String, token: String)
    case editGatewayInteractionResponseFollowup(appId: String, token: String, id: String)
    
    case postChannelCreateMessage(channel: String)
    case patchChannelEditMessage(channel: String, messageId: String)
    case deleteChannelMessage(channel: String, messageId: String)
    
    case createApplicationGlobalCommand(appId: String)
    case getApplicationGlobalCommands(appId: String)
    case deleteApplicationGlobalCommand(appId: String, id: String)
    
    case getGuild(id: String)
    case searchGuildMembers(id: String)
    case getGuildMember(id: String, userId: String)
    
    case getChannel(id: String)
    
    case leaveGuild(id: String)
    
    case createGuildRole(guildId: String)
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case removeGuildMemberRole(guildId: String, userId: String, roleId: String)
    
    case addReaction(channelId: String, messageId: String, emoji: String)
    
    var urlSuffix: String {
        switch self {
        case .getGateway:
            return "gateway"
        case let .createInteractionResponse(id, token):
            return "interactions/\(id)/\(token)/callback"
        case let .editOriginalInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .deleteGatewayInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .postFollowupGatewayInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)"
        case let .editGatewayInteractionResponseFollowup(appId, token, id):
            return "webhooks/\(appId)/\(token)/messages/\(id)"
        case let .postChannelCreateMessage(channel):
            return "channels/\(channel)/messages"
        case let .patchChannelEditMessage(channel, messageId):
            return "channels/\(channel)/messages/\(messageId)"
        case let .deleteChannelMessage(channel, messageId):
            return "channels/\(channel)/messages/\(messageId)"
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
        case .createInteractionResponse: return .POST
        case .editOriginalInteractionResponse: return .PATCH
        case .deleteGatewayInteractionResponse: return .DELETE
        case .postFollowupGatewayInteractionResponse: return .POST
        case .editGatewayInteractionResponseFollowup: return .PATCH
        case .postChannelCreateMessage: return .POST
        case .patchChannelEditMessage: return .PATCH
        case .deleteChannelMessage: return .DELETE
        case .createApplicationGlobalCommand: return .POST
        case .getApplicationGlobalCommands: return .GET
        case .deleteApplicationGlobalCommand: return .DELETE
        case .getGuild: return .GET
        case .searchGuildMembers: return .GET
        case .getGuildMember: return .GET
        case .getChannel: return .GET
        case .leaveGuild: return .DELETE
        case .createGuildRole: return .POST
        case .addGuildMemberRole: return .PUT
        case .removeGuildMemberRole: return .DELETE
        case .addReaction: return .PUT
        }
    }
    
    var id: Int {
        switch self {
        case .getGateway: return 1
        case .createInteractionResponse: return 2
        case .editOriginalInteractionResponse: return 3
        case .deleteGatewayInteractionResponse: return 4
        case .postFollowupGatewayInteractionResponse: return 5
        case .editGatewayInteractionResponseFollowup: return 6
        case .postChannelCreateMessage: return 7
        case .patchChannelEditMessage: return 8
        case .deleteChannelMessage: return 9
        case .createApplicationGlobalCommand: return 10
        case .getApplicationGlobalCommands: return 11
        case .deleteApplicationGlobalCommand: return 12
        case .getGuild: return 13
        case .searchGuildMembers: return 14
        case .getGuildMember: return 15
        case .getChannel: return 16
        case .leaveGuild: return 17
        case .createGuildRole: return 18
        case .addGuildMemberRole: return 19
        case .removeGuildMemberRole: return 20
        case .addReaction: return 21
        }
    }
}
