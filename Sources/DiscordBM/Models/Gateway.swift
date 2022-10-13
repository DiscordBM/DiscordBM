import Foundation

public struct Gateway: Sendable, Codable {
    
    /// https://discord.com/developers/docs/topics/opcodes-and-status-codes#opcodes-and-status-codes
    public enum Opcode: UInt8, Sendable, Codable, CustomStringConvertible {
        case dispatch = 0
        case heartbeat = 1
        case identify = 2
        case presenceUpdate = 3
        case voiceStateUpdate = 4
        case resume = 6
        case reconnect = 7
        case requestGuildMembers = 8
        case invalidSession = 9
        case hello = 10
        case heartbeatAccepted = 11
        
        public var description: String {
            switch self {
            case .dispatch: return "dispatch"
            case .heartbeat: return "heartbeat"
            case .identify: return "identify"
            case .presenceUpdate: return "presenceUpdate"
            case .voiceStateUpdate: return "voiceStateUpdate"
            case .resume: return "resume"
            case .reconnect: return "reconnect"
            case .requestGuildMembers: return "requestGuildMembers"
            case .invalidSession: return "invalidSession"
            case .hello: return "hello"
            case .heartbeatAccepted: return "heartbeatAccepted"
            }
        }
    }
    
    /// The top-level gateway event.
    /// https://discord.com/developers/docs/topics/gateway#gateway-events
    public struct Event: Sendable, Codable {
        
        /// This enum is just for swiftly organizing Discord gateway event's `data`.
        /// You need to read each case's inner payload's documentation for more info.
        public enum Payload: Sendable {
            /// https://discord.com/developers/docs/topics/gateway-events#heartbeat
            case heartbeat(lastSequenceNumber: Int?)
            case identify(Identify)
            case hello(Hello)
            case ready(Ready)
            /// Is sent when we want to send a resume request
            case resume(Resume)
            /// Is received when Discord has ended replying our lost events, after a resume
            /// https://discord.com/developers/docs/topics/gateway-events#resumed
            case resumed
            /// https://discord.com/developers/docs/topics/gateway-events#invalid-session
            case invalidSession(canResume: Bool)
            case channelCreate(DiscordChannel)
            case channelUpdate(DiscordChannel)
            case channelDelete(DiscordChannel)
            case channelPinsUpdate(ChannelPinsUpdate)
            case threadCreate(ThreadCreate)
            case threadUpdate(DiscordChannel)
            case threadDelete(ThreadDelete)
            case threadSyncList(ThreadListSync)
            case threadMemberUpdate(ThreadMemberUpdate)
            case threadMembersUpdate(ThreadMembersUpdate)
            case guildCreate(Guild)
            case guildUpdate(Guild)
            case guildDelete(UnavailableGuild)
            case guildBanAdd(GuildBan)
            case guildBanRemove(GuildBan)
            case guildEmojisUpdate(GuildEmojisUpdate)
            case guildStickersUpdate(GuildStickersUpdate)
            case guildIntegrationsUpdate(GuildIntegrationsUpdate)
            case guildMemberAdd(GuildMemberAdd)
            case guildMemberRemove(GuildMemberRemove)
            case guildMemberUpdate(GuildMemberUpdate)
            case guildMembersChunk(GuildMembersChunk)
            case requestGuildMembers(RequestGuildMembers)
            case guildRoleCreate(GuildRole)
            case guildRoleUpdate(GuildRole)
            case guildRoleDelete(GuildRoleDelete)
            case guildScheduledEventCreate(GuildScheduledEvent)
            case guildScheduledEventUpdate(GuildScheduledEvent)
            case guildScheduledEventDelete(GuildScheduledEvent)
            case guildScheduledEventUserAdd(GuildScheduledEventUser)
            case guildScheduledEventUserRemove(GuildScheduledEventUser)
            case guildApplicationCommandIndexUpdate(GuildApplicationCommandIndexUpdate)
            case guildJoinRequestUpdate(GuildJoinRequestUpdate)
            case guildJoinRequestDelete(GuildJoinRequestDelete)
            case integrationCreate(Integration)
            case integrationUpdate(Integration)
            case integrationDelete(IntegrationDelete)
            case interactionCreate(Interaction)
            case inviteCreate(InviteCreate)
            case inviteDelete(InviteDelete)
            case messageCreate(MessageCreate)
            case messageUpdate(DiscordChannel.PartialMessage)
            case messageDelete(MessageDelete)
            case messageDeleteBulk(MessageDeleteBulk)
            case messageReactionAdd(MessageReactionAdd)
            case messageReactionRemove(MessageReactionRemove)
            case messageReactionRemoveAll(MessageReactionRemoveAll)
            case messageReactionRemoveEmoji(MessageReactionRemoveEmoji)
            case presenceUpdate(PresenceUpdate)
            case stageInstanceCreate(StageInstance)
            case stageInstanceDelete(StageInstance)
            case stageInstanceUpdate(StageInstance)
            case typingStart(TypingStart)
            case userUpdate(DiscordUser)
            case voiceStateUpdate(VoiceState)
            case voiceServerUpdate(VoiceServerUpdate)
            case webhooksUpdate(WebhooksUpdate)
            case applicationCommandPermissionsUpdate(ApplicationCommandPermissionsUpdate)
            case autoModerationActionExecution(AutoModerationActionExecution)
        }
        
        enum GatewayDecodingError: Error {
            case unhandledDataStructure
        }
        
        enum CodingKeys: String, CodingKey {
            case opcode = "op"
            case data = "d"
            case sequenceNumber = "s"
            case type = "t"
        }
        
        public var opcode: Opcode
        public var data: Payload?
        public var sequenceNumber: Int?
        public var type: String?
        
        public init(
            opcode: Opcode,
            data: Payload? = nil,
            sequenceNumber: Int? = nil,
            type: String? = nil
        ) {
            self.opcode = opcode
            self.data = data
            self.sequenceNumber = sequenceNumber
            self.type = type
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.opcode = try container.decode(Opcode.self, forKey: .opcode)
            self.sequenceNumber = try container.decodeIfPresent(Int.self, forKey: .sequenceNumber)
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
            
            func decodeData<D: Decodable>(as type: D.Type = D.self) throws -> D {
                try container.decode(D.self, forKey: .data)
            }
            
            switch opcode {
            case .heartbeat, .heartbeatAccepted, .reconnect:
                guard try container.decodeNil(forKey: .data) else {
                    throw DecodingError.typeMismatch(Optional<Never>.self, .init(
                        codingPath: container.codingPath,
                        debugDescription: "`\(opcode)` opcode is supposed to have no data."
                    ))
                }
                self.data = nil
            case .identify, .presenceUpdate, .voiceStateUpdate, .resume, .requestGuildMembers:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "'\(opcode)' opcode is supposed to never be received."
                ))
            case .invalidSession:
                self.data = try .invalidSession(canResume: decodeData())
            case .hello:
                self.data = try .hello(decodeData())
            case .dispatch:
                switch self.type {
                case "READY":
                    self.data = try .ready(decodeData())
                case "RESUMED":
                    self.data = .resumed
                case "CHANNEL_CREATE":
                    self.data = try .channelCreate(decodeData())
                case "CHANNEL_UPDATE":
                    self.data = try .channelUpdate(decodeData())
                case "CHANNEL_DELETE":
                    self.data = try .channelDelete(decodeData())
                case "CHANNEL_PINS_UPDATE":
                    self.data = try .channelPinsUpdate(decodeData())
                case "THREAD_CREATE":
                    self.data = try .threadCreate(decodeData())
                case "THREAD_UPDATE":
                    self.data = try .threadUpdate(decodeData())
                case "THREAD_DELETE":
                    self.data = try .threadDelete(decodeData())
                case "THREAD_LIST_SYNC":
                    self.data = try .threadSyncList(decodeData())
                case "THREAD_MEMBER_UPDATE":
                    self.data = try .threadMemberUpdate(decodeData())
                case "THREAD_MEMBERS_UPDATE":
                    self.data = try .threadMembersUpdate(decodeData())
                case "GUILD_CREATE":
                    self.data = try .guildCreate(decodeData())
                case "GUILD_UPDATE":
                    self.data = try .guildUpdate(decodeData())
                case "GUILD_DELETE":
                    self.data = try .guildDelete(decodeData())
                case "GUILD_BAN_ADD":
                    self.data = try .guildBanAdd(decodeData())
                case "GUILD_BAN_REMOVE":
                    self.data = try .guildBanRemove(decodeData())
                case "GUILD_EMOJIS_UPDATE":
                    self.data = try .guildEmojisUpdate(decodeData())
                case "GUILD_STICKERS_UPDATE":
                    self.data = try .guildStickersUpdate(decodeData())
                case "GUILD_INTEGRATIONS_UPDATE":
                    self.data = try .guildIntegrationsUpdate(decodeData())
                case "GUILD_MEMBER_ADD":
                    self.data = try .guildMemberAdd(decodeData())
                case "GUILD_MEMBER_REMOVE":
                    self.data = try .guildMemberRemove(decodeData())
                case "GUILD_MEMBER_UPDATE":
                    self.data = try .guildMemberUpdate(decodeData())
                case "GUILD_MEMBERS_CHUNK":
                    self.data = try .guildMembersChunk(decodeData())
                case "GUILD_ROLE_CREATE":
                    self.data = try .guildRoleCreate(decodeData())
                case "GUILD_ROLE_UPDATE":
                    self.data = try .guildRoleUpdate(decodeData())
                case "GUILD_ROLE_DELETE":
                    self.data = try .guildRoleDelete(decodeData())
                case "GUILD_SCHEDULED_EVENT_CREATE":
                    self.data = try .guildScheduledEventCreate(decodeData())
                case "GUILD_SCHEDULED_EVENT_UPDATE":
                    self.data = try .guildScheduledEventUpdate(decodeData())
                case "GUILD_SCHEDULED_EVENT_DELETE":
                    self.data = try .guildScheduledEventDelete(decodeData())
                case "GUILD_SCHEDULED_EVENT_USER_ADD":
                    self.data = try .guildScheduledEventUserAdd(decodeData())
                case "GUILD_SCHEDULED_EVENT_USER_REMOVE":
                    self.data = try .guildScheduledEventUserRemove(decodeData())
                case "GUILD_APPLICATION_COMMAND_INDEX_UPDATE":
                    self.data = try .guildApplicationCommandIndexUpdate(decodeData())
                case "GUILD_JOIN_REQUEST_UPDATE":
                    self.data = try .guildJoinRequestUpdate(decodeData())
                case "GUILD_JOIN_REQUEST_DELETE":
                    self.data = try .guildJoinRequestDelete(decodeData())
                case "INTEGRATION_CREATE":
                    self.data = try .integrationCreate(decodeData())
                case "INTEGRATION_UPDATE":
                    self.data = try .integrationUpdate(decodeData())
                case "INTEGRATION_DELETE":
                    self.data = try .integrationDelete(decodeData())
                case "INTERACTION_CREATE":
                    self.data = try .interactionCreate(decodeData())
                case "INVITE_CREATE":
                    self.data = try .inviteCreate(decodeData())
                case "INVITE_DELETE":
                    self.data = try .inviteDelete(decodeData())
                case "MESSAGE_CREATE":
                    self.data = try .messageCreate(decodeData())
                case "MESSAGE_UPDATE":
                    self.data = try .messageUpdate(decodeData())
                case "MESSAGE_DELETE":
                    self.data = try .messageDelete(decodeData())
                case "MESSAGE_DELETE_BULK":
                    self.data = try .messageDeleteBulk(decodeData())
                case "MESSAGE_REACTION_ADD":
                    self.data = try .messageReactionAdd(decodeData())
                case "MESSAGE_REACTION_REMOVE":
                    self.data = try .messageReactionRemove(decodeData())
                case "MESSAGE_REACTION_REMOVE_ALL":
                    self.data = try .messageReactionRemoveAll(decodeData())
                case "MESSAGE_REACTION_REMOVE_EMOJI":
                    self.data = try .messageReactionRemoveEmoji(decodeData())
                case "PRESENCE_UPDATE":
                    self.data = try .presenceUpdate(decodeData())
                case "STAGE_INSTANCE_CREATE":
                    self.data = try .stageInstanceCreate(decodeData())
                case "STAGE_INSTANCE_DELETE":
                    self.data = try .stageInstanceDelete(decodeData())
                case "STAGE_INSTANCE_UPDATE":
                    self.data = try .stageInstanceUpdate(decodeData())
                case "TYPING_START":
                    self.data = try .typingStart(decodeData())
                case "USER_UPDATE":
                    self.data = try .userUpdate(decodeData())
                case "VOICE_STATE_UPDATE":
                    self.data = try .voiceStateUpdate(decodeData())
                case "VOICE_SERVER_UPDATE":
                    self.data = try .voiceServerUpdate(decodeData())
                case "WEBHOOKS_UPDATE":
                    self.data = try .webhooksUpdate(decodeData())
                case "APPLICATION_COMMAND_PERMISSIONS_UPDATE":
                    self.data = try .applicationCommandPermissionsUpdate(decodeData())
                case "AUTO_MODERATION_ACTION_EXECUTION":
                    self.data = try .autoModerationActionExecution(decodeData())
                default:
                    throw GatewayDecodingError.unhandledDataStructure
                }
            }
        }
        
        enum EncodingError: Error {
            case notSupposedToBeSent(message: String)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self.opcode {
            case .dispatch, .reconnect, .invalidSession, .heartbeatAccepted, .hello:
                throw EncodingError.notSupposedToBeSent(
                    message: "`\(self.opcode.rawValue)` opcode is supposed to never be sent."
                )
            default: break
            }
            try container.encode(self.opcode, forKey: .opcode)
            
            if self.sequenceNumber != nil {
                throw EncodingError.notSupposedToBeSent(
                    message: "'sequenceNumber' is supposed to never be sent but wasn't nil (\(String(describing: sequenceNumber))."
                )
            }
            if self.type != nil {
                throw EncodingError.notSupposedToBeSent(
                    message: "'type' is supposed to never be sent but wasn't nil (\(String(describing: type))."
                )
            }
            
            switch self.data {
            case .none:
                try container.encodeNil(forKey: .data)
            case let .heartbeat(lastSequenceNumber):
                try container.encode(lastSequenceNumber, forKey: .data)
            case let .identify(payload):
                try container.encode(payload, forKey: .data)
            case let .resume(payload):
                try container.encode(payload, forKey: .data)
            case let .requestGuildMembers(payload):
              try container.encode(payload, forKey: .data)
            default:
                throw EncodingError.notSupposedToBeSent(
                    message: "'\(self)' data is supposed to never be sent."
                )
            }
        }
    }
    
    /// https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
    public enum CloseCode: UInt16, Sendable, Codable {
        case unknownError = 4000
        case unknownOpcode = 4001
        case decodeError = 4002
        case notAuthenticated = 4003
        case authenticationFailed = 4004
        case alreadyAuthenticated = 4005
        case invalidSequence = 4007
        case rateLimited = 4008
        case sessionTimedOut = 4009
        case invalidShard = 4010
        case shardingRequired = 4011
        case invalidAPIVersion = 4012
        case invalidIntents = 4013
        case disallowedIntents = 4014
        
        public var canTryReconnect: Bool {
            switch self {
            case .unknownError: return true
            case .unknownOpcode: return true
            case .decodeError: return true
            case .notAuthenticated: return true
            case .authenticationFailed: return false
            case .alreadyAuthenticated: return true
            case .invalidSequence: return true
            case .rateLimited: return true
            case .sessionTimedOut: return true
            case .invalidShard: return false
            case .shardingRequired: return false
            case .invalidAPIVersion: return false
            case .invalidIntents: return false
            case .disallowedIntents: return false
            }
        }
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#identify
    public struct Identify: Sendable, Codable {
        
        /// https://discord.com/developers/docs/topics/gateway-events#identify-identify-connection-properties
        public struct ConnectionProperties: Sendable, Codable {
            public let os: String = {
#if os(macOS)
                return "macOS"
#elseif os(Linux)
                return "Linux"
#elseif os(iOS)
                return "iOS"
#elseif os(watchOS)
                return "watchOS"
#elseif os(tvOS)
                return "tvOS"
#elseif os(Windows)
                return "Windows"
#elseif os(Android)
                return "Android"
#else
                return "Unknown-OS"
#endif
            }()
            public let browser = "DiscordBM"
            public let device = "DiscordBM"
            
            enum CodingKeys: String, CodingKey {
                case os = "$os"
                case browser = "$browser"
                case device = "$device"
            }
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
        public struct Presence: Sendable, Codable {
            public var since: Int?
            public var activities: [Activity]
            public var status: Status
            public var afk: Bool
            
            public init(since: Int? = nil, activities: [Activity], status: Status, afk: Bool) {
                self.since = since
                self.activities = activities
                self.status = status
                self.afk = afk
            }
        }
        
        public var token: Secret
        public var properties = ConnectionProperties()
        public var compress: Bool?
        public var large_threshold: Int?
        public var shard: IntPair?
        public var presence: Presence?
        public var intents: IntBitField<Intent>
        
        public init(token: Secret, compress: Bool? = nil, large_threshold: Int? = nil, shard: IntPair? = nil, presence: Presence? = nil, intents: [Intent]) {
            self.token = token
            self.compress = compress
            self.large_threshold = large_threshold
            self.shard = shard
            self.presence = presence
            self.intents = .init(intents)
        }
        
        public init(token: String, compress: Bool? = nil, large_threshold: Int? = nil, shard: IntPair? = nil, presence: Presence? = nil, intents: [Intent]) {
            self.token = Secret(token)
            self.compress = compress
            self.large_threshold = large_threshold
            self.shard = shard
            self.presence = presence
            self.intents = .init(intents)
        }
    }
    
    /// https://discord.com/developers/docs/topics/gateway#gateway-intents
    public enum Intent: Int, Sendable {
        case guilds = 0
        case guildMembers = 1
        case guildBans = 2
        case guildEmojisAndStickers = 3
        case guildIntegrations = 4
        case guildWebhooks = 5
        case guildInvites = 6
        case guildVoiceStates = 7
        case guildPresences = 8
        case guildMessages = 9
        case guildMessageReactions = 10
        case guildMessageTyping = 11
        case directMessages = 12
        case directMessageReactions = 13
        case directMessageTyping = 14
        case messageContent = 15
        case guildScheduledEvents = 16
        case autoModerationConfiguration = 20
        case autoModerationExecution = 21
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#resume-resume-structure
    public struct Resume: Sendable, Codable {
        public var token: Secret
        public var session_id: String
        public var seq: Int
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#update-presence-status-types
    public enum Status: String, Sendable, Codable {
        case online = "online"
        case doNotDisturb = "dnd"
        case afk = "idle"
        case invisible = "invisible"
        case offline = "offline"
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#hello-hello-structure
    public struct Hello: Sendable, Codable {
        public var heartbeat_interval: Int
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#ready-ready-event-fields
    public struct Ready: Sendable, Codable {
        
        /// Undocumented
        public struct AudioContextSettings: Sendable, Codable { }
        
        public var v: Int
        public var user: DiscordUser
        public var guilds: [UnavailableGuild]
        public var session_id: String
        public var shard: IntPair?
        public var application: PartialApplication
        public var presences: [PresenceUpdate]
        public var geo_ordered_rtc_regions: [String]
        public var guild_join_requests: [String] // Undocumented
        public var private_channels: [DiscordChannel]
        public var user_settings: [String: String] // Undocumented
        public var relationships: [String] // Undocumented
        public var session_type: String?
        public var auth_session_id_hash: String?
        public var resume_gateway_url: String?
        public var audio_context_settings: AudioContextSettings?
    }
    
    /// A ``Channel`` object with a few differences.
    /// https://discord.com/developers/docs/topics/gateway-events#thread-create
    public struct ThreadCreate: Sendable, Codable {
        public var id: String
        public var type: DiscordChannel.Kind
        public var guild_id: String?
        public var position: Int?
        public var permission_overwrites: [DiscordChannel.Overwrite]?
        public var name: String?
        public var topic: String?
        public var nsfw: Bool?
        public var last_message_id: String?
        public var bitrate: Int?
        public var user_limit: Int?
        public var rate_limit_per_user: Int?
        public var recipients: [DiscordUser]?
        public var icon: String?
        public var owner_id: String?
        public var application_id: String?
        public var parent_id: String?
        public var last_pin_timestamp: DiscordTimestamp?
        public var rtc_region: String?
        public var video_quality_mode: Int?
        public var message_count: Int?
        public var total_message_sent: Int?
        public var member_count: Int?
        public var thread_metadata: ThreadMetadata
        public var member: ThreadMember?
        public var default_auto_archive_duration: Int?
        public var default_reaction_emoji: String?
        public var permissions: StringBitField<Permission>?
        public var flags: IntBitField<DiscordChannel.Flag>?
        public var newly_created: Bool?
        public var thread_member: ThreadMember?
        public var available_tags: [String]?
        public var template: String?
        public var member_ids_preview: [String]?
        public var version: Int?
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#thread-delete
    public struct ThreadDelete: Sendable, Codable {
        public var id: String
        public var type: DiscordChannel.Kind
        public var guild_id: String?
        public var parent_id: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#thread-list-sync-thread-list-sync-event-fields
    public struct ThreadListSync: Sendable, Codable {
        public var guild_id: String
        public var channel_ids: [String]?
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
    }
    
    /// A ``ThreadMember`` with a `guild_id` field.
    /// https://discord.com/developers/docs/topics/gateway-events#thread-member-update
    public struct ThreadMemberUpdate: Sendable, Codable {
        public var id: String
        public var user_id: String?
        public var join_timestamp: DiscordTimestamp
        /// FIXME:
        /// The field is documented but doesn't say what exactly it is.
        /// Discord says: "any user-thread settings, currently only used for notifications".
        public var flags: Int
        public var guild_id: String
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#thread-members-update-thread-members-update-event-fields
    public struct ThreadMembersUpdate: Sendable, Codable {
        
        /// A ``ThreadMember`` with some extra fields.
        /// https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
        /// https://discord.com/developers/docs/topics/gateway-events#thread-members-update-thread-members-update-event-fields
        public struct ThreadMember: Sendable, Codable {
            
            /// A ``PresenceUpdate`` with nullable `guild_id`.
            /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
            public struct ThreadMemberPresenceUpdate: Sendable, Codable {
                public var user: PartialUser
                public var guild_id: String?
                public var status: Status
                public var activities: [Activity]
                public var client_status: ClientStatus
                public var game: Game?
            }

            public var id: String
            public var user_id: String?
            public var join_timestamp: DiscordTimestamp
            /// FIXME:
            /// The field is documented but doesn't say what exactly it is.
            /// Discord says: "any user-thread settings, currently only used for notifications".
            public var flags: Int
            public var member: Guild.Member
            public var presence: ThreadMemberPresenceUpdate?
        }
        
        public var id: String
        public var guild_id: String
        public var member_count: Int
        public var added_members: [ThreadMember]?
        public var removed_member_ids: [String]?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#channel-pins-update-channel-pins-update-event-fields
    public struct ChannelPinsUpdate: Sendable, Codable {
        public var guild_id: String?
        public var channel_id: String
        public var last_pin_timestamp: DiscordTimestamp?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-ban-add-guild-ban-add-event-fields
    public struct GuildBan: Sendable, Codable {
        public var guild_id: String
        public var user: DiscordUser
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-emojis-update-guild-emojis-update-event-fields
    public struct GuildEmojisUpdate: Sendable, Codable {
        public var guild_id: String
        public var emojis: [PartialEmoji]
        public var hashes: Hashes?
        public var guild_hashes: Hashes?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-stickers-update-guild-stickers-update-event-fields
    public struct GuildStickersUpdate: Sendable, Codable {
        public var guild_id: String
        public var stickers: [Sticker]
        public var hashes: Hashes?
        public var guild_hashes: Hashes?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-integrations-update-guild-integrations-update-event-fields
    public struct GuildIntegrationsUpdate: Sendable, Codable {
        public var guild_id: String
    }
    
    /// A ``GuildMember`` with an extra `guild_id` field.
    /// https://discord.com/developers/docs/resources/guild#guild-member-object
    public struct GuildMemberAdd: Sendable, Codable {
        public var guild_id: String
        public var roles: [String]
        public var hoisted_role: String?
        public var user: DiscordUser
        public var nick: String?
        public var avatar: String?
        public var joined_at: DiscordTimestamp
        public var premium_since: DiscordTimestamp?
        public var deaf: Bool
        public var mute: Bool
        public var pending: Bool?
        public var is_pending: Bool?
        public var flags: IntBitField<DiscordUser.Flag> // FIXME not sure about `User.Flag`
        public var permissions: StringBitField<Permission>?
        public var communication_disabled_until: DiscordTimestamp?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-member-remove-guild-member-remove-event-fields
    public struct GuildMemberRemove: Sendable, Codable {
        public var guild_id: String
        public var user: DiscordUser
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-member-update-guild-member-update-event-fields
    public struct GuildMemberUpdate: Sendable, Codable {
        public var guild_id: String
        public var roles: [String]
        public var hoisted_role: String?
        public var user: DiscordUser
        public var nick: String?
        public var avatar: String?
        public var joined_at: DiscordTimestamp?
        public var premium_since: DiscordTimestamp?
        public var deaf: Bool?
        public var mute: Bool?
        public var flags: IntBitField<DiscordUser.Flag>? // FIXME not sure about `User.Flag`
        public var pending: Bool?
        public var is_pending: Bool?
        public var communication_disabled_until: DiscordTimestamp?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-members-chunk
    public struct GuildMembersChunk: Sendable, Codable {
        public var guild_id: String
        public var members: [Guild.Member]
        public var chunk_index: Int
        public var chunk_count: Int
        public var not_found: [String]?
        public var presences: [PartialPresenceUpdate]?
        public var nonce: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
    public struct RequestGuildMembers: Sendable, Codable {
        public var guild_id: String
        public var query: String = ""
        public var limit: Int = 0
        public var presences: Bool?
        public var user_ids: [String]?
        public var nonce: String?
        
        public init(guild_id: String, query: String = "", limit: Int = 0, presences: Bool? = nil, user_ids: [String]? = nil, nonce: String? = nil) {
            self.guild_id = guild_id
            self.query = query
            self.limit = limit
            self.presences = presences
            self.user_ids = user_ids
            self.nonce = nonce
        }
    }
    
    /// Undocumented
    public struct GuildJoinRequestUpdate: Sendable, Codable {
        
        public struct Request: Sendable, Codable {
            
            public struct FormResponse: Sendable, Codable {
                
                public enum FieldKind: String, Sendable, Codable {
                    case terms = "TERMS"
                }
                
                public struct Automation: Sendable, Codable { }
                
                public var values: [String]
                public var response: Bool
                public var required: Bool
                public var label: String
                public var field_type: FieldKind
                public var description: String?
                public var automations: [Automation]?
            }
            
            public var user_id: String
            public var user: DiscordUser
            public var rejection_reason: String?
            public var last_seen: DiscordTimestamp
            public var created_at: DiscordTimestamp
            public var id: String
            public var guild_id: String
            public var form_responses: [FormResponse]
            public var application_status: Status
            public var actioned_by_user: DiscordUser
            public var actioned_at: String /// Seems to be a Snowflake ?!
        }
        
        public enum Status: String, Sendable, Codable {
            case approved = "APPROVED"
        }
        
        public var request: Request
        public var status: Status
        public var guild_id: String
    }
    
    /// Undocumented
    public struct GuildJoinRequestDelete: Sendable, Codable {
        public var id: String
        public var guild_id: String
        public var user_id: String
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-role-create-guild-role-create-event-fields
    public struct GuildRole: Sendable, Codable {
        public var guild_id: String
        public var role: Role
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#guild-role-delete
    public struct GuildRoleDelete: Sendable, Codable {
        public var guild_id: String
        public var role_id: String
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    /// Not the same as what Discord calls `Guild Scheduled Event User`.
    /// This is used for guild-scheduled-event-user add and remove events.
    /// https://discord.com/developers/docs/topics/gateway-events#guild-scheduled-event-user-add-guild-scheduled-event-user-add-event-fields
    public struct GuildScheduledEventUser: Sendable, Codable {
        public var guild_scheduled_event_id: String
        public var user_id: String
        public var guild_id: String
    }
    
    /// Undocumented
    public struct GuildApplicationCommandIndexUpdate: Sendable, Codable {
        public var hashes: Hashes
        public var guild_hashes: Hashes
        public var application_command_counts: [String: Int]
        public var guild_id: String
    }
    
    /// An ``Integration`` with an extra `guild_id` field.
    /// https://discord.com/developers/docs/topics/gateway-events#integration-create
    /// https://discord.com/developers/docs/resources/guild#integration-object
    public struct Integration: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/guild#integration-object-integration-structure
        public enum Kind: String, Sendable, Codable {
            case twitch
            case youtube
            case discord
        }
        
        /// https://discord.com/developers/docs/resources/guild#integration-object-integration-expire-behaviors
        public enum ExpireBehavior: Int, Sendable, Codable {
            case removeRole = 0
            case kick = 1
        }
        
        public var id: String
        public var name: String
        public var type: Kind
        public var enabled: Bool
        public var syncing: Bool?
        public var role_id: String?
        public var enable_emoticons: Bool?
        public var expire_behavior: ExpireBehavior?
        public var expire_grace_period: Int?
        public var user: DiscordUser?
        public var account: IntegrationAccount
        public var synced_at: DiscordTimestamp?
        public var subscriber_count: Int?
        public var revoked: Bool?
        public var application: IntegrationApplication?
        public var guild_id: String
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
        public var scopes: TolerantDecodeArray<OAuth2Scope>?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#integration-delete-integration-delete-event-fields
    public struct IntegrationDelete: Sendable, Codable {
        public var id: String
        public var guild_id: String
        public var application_id: String?
        public var hashes: Hashes?
        public var guild_hashes: Hashes?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#invite-create-invite-create-event-fields
    public struct InviteCreate: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/invite#invite-object-invite-target-types
        public enum TargetKind: Int, Sendable, Codable {
            case stream = 1
            case embeddedApplication = 2
        }
        
        public var type: Int? // FIXME: TYPIFY
        public var channel_id: String
        public var code: String
        public var created_at: DiscordTimestamp
        public var guild_id: String?
        public var inviter: DiscordUser?
        public var max_age: Int
        public var max_uses: Int
        public var target_type: TargetKind?
        public var target_user: DiscordUser?
        public var target_application: PartialApplication?
        public var temporary: Bool
        public var uses: Int
        public var expires_at: DiscordTimestamp?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#invite-delete
    public struct InviteDelete: Sendable, Codable {
        public var channel_id: String
        public var guild_id: String?
        public var code: String
    }
    
    /// A ``Message`` object with a few extra fields.
    /// https://discord.com/developers/docs/topics/gateway-events#message-create
    /// https://discord.com/developers/docs/resources/channel#message-object
    public struct MessageCreate: Sendable, Codable {
        public var id: String
        public var channel_id: String
        public var guild_id: String?
        public var author: PartialUser?
        public var member: Guild.PartialMember?
        public var content: String
        public var timestamp: DiscordTimestamp
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool
        public var mention_everyone: Bool
        public var mentions: [DiscordChannel.Message.MentionUser]
        public var mention_roles: [String]
        public var mention_channels: [DiscordChannel.Message.ChannelMention]?
        public var attachments: [DiscordChannel.Message.Attachment]
        public var embeds: [Embed]
        public var reactions: [DiscordChannel.Message.Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool
        public var webhook_id: String?
        public var type: DiscordChannel.Message.Kind
        public var activity: Activity?
        public var application: PartialApplication?
        public var application_id: String?
        public var message_reference: DiscordChannel.Message.MessageReference?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var referenced_message: DereferenceBox<MessageCreate>?
        public var interaction: MessageInteraction?
        public var thread: DiscordChannel?
        public var components: [Interaction.ActionRow]?
        public var sticker_items: [StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#message-delete
    public struct MessageDelete: Sendable, Codable {
        public var id: String
        public var channel_id: String
        public var guild_id: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#message-delete-bulk-message-delete-bulk-event-fields
    public struct MessageDeleteBulk : Sendable, Codable {
        public var ids: [String]
        public var channel_id: String
        public var guild_id: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-add-message-reaction-add-event-fields
    public struct MessageReactionAdd: Sendable, Codable {
        public var user_id: String
        public var channel_id: String
        public var message_id: String
        public var guild_id: String?
        public var member: Guild.Member?
        public var emoji: PartialEmoji
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-remove
    public struct MessageReactionRemove: Sendable, Codable {
        public var user_id: String
        public var channel_id: String
        public var message_id: String
        public var guild_id: String?
        public var emoji: PartialEmoji
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-remove-all
    public struct MessageReactionRemoveAll : Sendable, Codable {
        public var channel_id: String
        public var message_id: String
        public var guild_id: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#message-reaction-remove-emoji
    public struct MessageReactionRemoveEmoji: Sendable, Codable {
        public var channel_id: String
        public var guild_id: String?
        public var message_id: String
        public var emoji: PartialEmoji
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#client-status-object
    public struct ClientStatus: Sendable, Codable {
        public var desktop: String?
        public var mobile: String?
        public var web: String?
    }
    
    /// Undocumented
    public struct Game: Sendable, Codable {
        public var type: Int // Undocumented
        public var state: String?
        public var name: String
        public var created_at: TolerantDecodeDate
        public var id: String
        public var session_id: String?
        public var emoji: PartialEmoji?
        public var platform: String?
        public var timestamps: [DiscordTimestamp]?
        public var application_id: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
    public struct PresenceUpdate: Sendable, Codable {
        public var user: PartialUser
        public var guild_id: String
        public var status: Status
        public var activities: [Activity]
        public var client_status: ClientStatus
        public var game: Game?
    }
    
    /// Partial ``PresenceUpdate`` object.
    /// https://discord.com/developers/docs/topics/gateway-events#presence-update-presence-update-event-fields
    public struct PartialPresenceUpdate: Sendable, Codable {
        public var user: PartialUser?
        public var guild_id: String?
        public var status: Status?
        public var activities: [Activity]?
        public var client_status: ClientStatus
        public var game: Game?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#activity-object
    public struct Activity: Sendable, Codable {
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-types
        public enum Kind: Int, Sendable, Codable {
            case game = 0
            case streaming = 1
            case listening = 2
            case watching = 3
            case custom = 4
            case competing = 5
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-timestamps
        public struct Timestamps: Sendable, Codable {
            public var start: Int?
            public var end: Int?
            
            public init(start: Int? = nil, end: Int? = nil) {
                self.start = start
                self.end = end
            }
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-emoji
        public struct ActivityEmoji: Sendable, Codable {
            public var name: String
            public var id: String?
            public var animated: Bool?
            
            public init(name: String, id: String? = nil, animated: Bool? = nil) {
                self.name = name
                self.id = id
                self.animated = animated
            }
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-party
        public struct Party: Sendable, Codable {
            public var id: String?
            public var size: IntPair?
            
            public init(id: String? = nil, size: IntPair? = nil) {
                self.id = id
                self.size = size
            }
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-assets
        public struct Assets: Sendable, Codable {
            public var large_image: String?
            public var large_text: String?
            public var small_image: String?
            public var small_text: String?
            
            public init(large_image: String? = nil, large_text: String? = nil, small_image: String? = nil, small_text: String? = nil) {
                self.large_image = large_image
                self.large_text = large_text
                self.small_image = small_image
                self.small_text = small_text
            }
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-secrets
        public struct Secrets: Sendable, Codable {
            public var join: String?
            public var spectate: String?
            public var match: String?
            
            public init(join: String? = nil, spectate: String? = nil, match: String? = nil) {
                self.join = join
                self.spectate = spectate
                self.match = match
            }
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-flags
        public enum Flag: Int, Sendable {
            case instance = 0
            case join = 1
            case spectate = 2
            case joinRequest = 3
            case sync = 4
            case play = 5
            case partyPrivacyFriends = 6
            case partyPrivacyVoiceChannel = 7
            case embedded = 8
        }
        
        /// https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-buttons
        public struct Button: Sendable, Codable {
            public var label: String
            public var url: String
            
            public init(label: String, url: String) {
                self.label = label
                self.url = url
            }
            
            public init(from decoder: Decoder) throws {
                if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                    self.label = try container.decode(String.self, forKey: .label)
                    self.url = try container.decode(String.self, forKey: .url)
                } else {
                    self.label = try decoder.singleValueContainer().decode(String.self)
                    self.url = ""
                }
            }
        }
        
        public var name: String?
        public var type: Kind
        public var url: String?
        public var id: String?
        public var created_at: Int?
        public var timestamps: Timestamps?
        public var application_id: String?
        public var details: String?
        public var state: String?
        public var emoji: ActivityEmoji?
        public var party: Party?
        public var party_id: String?
        public var assets: Assets?
        public var secrets: Secrets?
        public var instance: Bool?
        public var flags: IntBitField<Flag>?
        public var buttons: [Button]?
        public var sync_id: String?
        public var session_id: String?
        public var platform: String?
        public var supported_platforms: [String]?
        
        public init(name: String?, type: Kind, url: String? = nil, created_at: Int? = nil, timestamps: Timestamps? = nil, application_id: String? = nil, details: String? = nil, state: String? = nil, emoji: ActivityEmoji? = nil, party: Party? = nil, party_id: String? = nil, assets: Assets? = nil, secrets: Secrets? = nil, instance: Bool? = nil, flags: [Flag]? = nil, buttons: [Button]? = nil, sync_id: String? = nil, session_id: String? = nil, platform: String? = nil, supported_platforms: [String]? = nil) {
            self.name = name
            self.type = type
            self.url = url
            self.created_at = created_at
            self.timestamps = timestamps
            self.application_id = application_id
            self.details = details
            self.state = state
            self.emoji = emoji
            self.party = party
            self.party_id = party_id
            self.assets = assets
            self.secrets = secrets
            self.instance = instance
            self.flags = flags.map { .init($0) }
            self.buttons = buttons
            self.sync_id = sync_id
            self.session_id = session_id
            self.platform = platform
            self.supported_platforms = supported_platforms
        }
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#typing-start-typing-start-event-fields
    public struct TypingStart: Sendable, Codable {
        public var channel_id: String
        public var guild_id: String?
        public var user_id: String
        public var timestamp: Int
        public var member: Guild.Member?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#voice-server-update-voice-server-update-event-fields
    public struct VoiceServerUpdate: Sendable, Codable {
        public var token: String
        public var guild_id: String
        public var endpoint: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#webhooks-update-webhooks-update-event-fields
    public struct WebhooksUpdate: Sendable, Codable {
        public var guild_id: String
        public var channel_id: String
    }
    
    /// Undocumented
    public struct ApplicationCommandPermissionsUpdate: Sendable, Codable {
        
        /// Undocumented
        public struct UpdatePermission: Sendable, Codable {
            public var type: Permission // Undocumented
            public var permission: Bool
            public var id: String
        }
        
        public var permissions: [UpdatePermission]
        public var id: String
        public var guild_id: String
        public var application_id: String
    }
    
    /// Undocumented
    public struct AutoModerationActionExecution: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-action-object
        public enum AutoModerationAction: Sendable, Codable {
            case blockMessage
            case sendAlertMessage(channelId: String)
            case timeout(durationSeconds: Int)
            
            private enum CodingKeys: String, CodingKey {
                case type
                case metadata
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
                    self = .blockMessage
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
                        debugDescription: "Unexpected AutoModerationAction 'type': \(type)"
                    ))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case .blockMessage:
                    try container.encode(1, forKey: .type)
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
        }
        
        /// https://discord.com/developers/docs/resources/auto-moderation#auto-moderation-rule-object-trigger-types
        public enum TriggerKind: Int, Sendable, Codable {
            case keyword = 1
            case spam = 3
            case keywordPreset = 4
            case mentionSpam = 5
        }
        
        public var guild_id: String
        public var action: AutoModerationAction
        public var rule_id: String
        public var rule_trigger_type: TriggerKind
        public var user_id: String
        public var channel_id: String?
        public var message_id: String?
        public var alert_system_message_id: String?
        public var content: String?
        public var matched_keyword: String?
        public var matched_content: String?
    }
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway
    public struct Url: Sendable, Codable {
        public var url: String
    }
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway-bot-json-response
    public struct BotConnectionInfo: Sendable, Codable {
        
        /// https://discord.com/developers/docs/topics/gateway#session-start-limit-object-session-start-limit-structure
        public struct SessionStartLimit: Sendable, Codable {
            public var total: Int
            public var remaining: Int
            public var reset_after: Int
            public var max_concurrency: Int
        }
        
        public var url: String
        public var shards: Int
        public var session_start_limit: SessionStartLimit
    }
}
