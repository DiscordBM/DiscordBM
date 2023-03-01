
/// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object
public struct AutoModerationRule: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-event-types
    public enum EventKind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case messageSend = 1
    }
    
    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-trigger-types
    public enum TriggerKind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case keyword = 1
        case spam = 3
        case keywordPreset = 4
        case mentionSpam = 5
    }
    
    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-trigger-metadata
    public struct TriggerMetadata: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-keyword-preset-types
        public enum KeywordPreset: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case profanity = 1
            case sexualContent = 2
            case slurs = 3
        }
        
        public var keyword_filter: [String]?
        public var presets: [KeywordPreset]?
        public var allow_list: [String]?
        public var mention_total_limit: Int?
        public var regex_patterns: [String]
    }
    
    /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-action-object
    public enum Action: Sendable, Codable, ValidatablePayload {
        case blockMessage(customMessage: String?)
        case sendAlertMessage(channelId: String)
        case timeout(durationSeconds: Int)
        
        private enum CodingKeys: String, CodingKey {
            case type
            case metadata
        }
        
        private enum BlockMessageCodingKeys: String, CodingKey {
            case custom_message
        }
        
        private enum SendAlertMessageCodingKeys: String, CodingKey {
            case channel_id
        }
        
        private enum TimeoutCodingKeys: String, CodingKey {
            case duration_seconds
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(Int.self, forKey: .type)
            switch type {
            case 1:
                let customMessage = try container.nestedContainer(
                    keyedBy: BlockMessageCodingKeys.self,
                    forKey: .metadata
                ).decodeIfPresent(String.self, forKey: .custom_message)
                self = .blockMessage(customMessage: customMessage)
            case 2:
                let channelId = try container.nestedContainer(
                    keyedBy: SendAlertMessageCodingKeys.self,
                    forKey: .metadata
                ).decode(String.self, forKey: .channel_id)
                self = .sendAlertMessage(channelId: channelId)
            case 3:
                let durationSeconds = try container.nestedContainer(
                    keyedBy: TimeoutCodingKeys.self,
                    forKey: .metadata
                ).decode(Int.self, forKey: .duration_seconds)
                self = .timeout(durationSeconds: durationSeconds)
            default:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "Unexpected AutoModerationRule.Action 'type': \(type)"
                ))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .blockMessage(customMessage):
                try container.encode(1, forKey: .type)
                var metadataContainer = container.nestedContainer(
                    keyedBy: BlockMessageCodingKeys.self,
                    forKey: .metadata
                )
                try metadataContainer.encode(customMessage, forKey: .custom_message)
            case let .sendAlertMessage(channelId):
                try container.encode(2, forKey: .type)
                var metadataContainer = container.nestedContainer(
                    keyedBy: SendAlertMessageCodingKeys.self,
                    forKey: .metadata
                )
                try metadataContainer.encode(channelId, forKey: .channel_id)
            case let .timeout(durationSeconds):
                try container.encode(3, forKey: .type)
                var metadataContainer = container.nestedContainer(
                    keyedBy: TimeoutCodingKeys.self,
                    forKey: .metadata
                )
                try metadataContainer.encode(durationSeconds, forKey: .duration_seconds)
            }
        }
        
        public func validate() throws {
            switch self {
            case .blockMessage(let customMessage):
                try validateCharacterCountDoesNotExceed(
                    customMessage,
                    max: 150,
                    name: "customMessage"
                )
            case .timeout(let durationSeconds):
                try validateNumberInRange(
                    durationSeconds,
                    min: 0,
                    max: 2419200,
                    name: "durationSeconds"
                )
            case .sendAlertMessage(_): break
            }
        }
    }
    
    public var id: String
    public var guild_id: String
    public var name: String
    public var creator_id: String
    public var event_type: EventKind
    public var trigger_type: TriggerKind
    public var trigger_metadata: TriggerMetadata
    public var actions: [Action]
    public var enabled: Bool
    public var exempt_roles: [String]
    public var exempt_channels: [String]
}

/// https://discord.com/developers/docs/topics/gateway-events#auto-moderation-action-execution-auto-moderation-action-execution-event-fields
public struct AutoModerationActionExecution: Sendable, Codable {
    public var guild_id: String
    public var action: AutoModerationRule.Action
    public var rule_id: String
    public var rule_trigger_type: AutoModerationRule.TriggerKind
    public var user_id: String
    public var channel_id: String?
    public var message_id: String?
    public var alert_system_message_id: String?
    public var content: String?
    public var matched_keyword: String?
    public var matched_content: String?
}
