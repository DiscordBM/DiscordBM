import Foundation

public struct Gateway: Codable {
    
    public enum Opcode: Int, Codable {
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
    }
    
    public struct Event: Codable {
        
        public enum Payload {
            case identify(Identify)
            case hello(Hello)
            case ready(Ready)
            /// Is sent when we want to send a resume request
            case resume(Resume)
            /// Is received when Discord has ended replying our lost events, after a resume
            case resumed
            case invalidSession(canResume: Bool)
            case channelCreate(Channel)
            case channelUpdate(Channel)
            case channelDelete(Channel)
            case channelPinsUpdate(ChannelPinsUpdate)
            case threadCreate(ThreadCreate)
            case threadUpdate(Channel)
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
            case interactionCreate(InteractionCreate)
            case inviteCreate(InviteCreate)
            case inviteDelete(InviteDelete)
            case messageCreate(Message)
            case messageUpdate(PartialMessage)
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
            case userUpdate(User)
            case voiceStateUpdate(VoiceStateUpdate)
            case voiceServerUpdate(VoiceServerUpdate)
            case webhooksUpdate(WebhooksUpdate)
            case applicationCommandPermissionsUpdate(ApplicationCommandPermissionsUpdate)
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
            case .heartbeat:
                guard try container.decodeNil(forKey: .data) else {
                    throw DecodingError.typeMismatch(Optional<Never>.self, .init(
                        codingPath: container.codingPath,
                        debugDescription: "`heartbeat` opcode is supposed to have no data."
                    ))
                }
                self.data = nil
            case .identify:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "`identify` opcode is supposed to never be received."
                ))
            case .presenceUpdate:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "`presenceUpdate` opcode is supposed to never be received."
                ))
            case .voiceStateUpdate:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "`voiceStateUpdate` opcode is supposed to never be received."
                ))
            case .resume:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "`resume` opcode is supposed to never be received."
                ))
            case .reconnect:
                guard try container.decodeNil(forKey: .data) else {
                    throw DecodingError.typeMismatch(Optional<Never>.self, .init(
                        codingPath: container.codingPath,
                        debugDescription: "`reconnect` opcode is supposed to have no data."
                    ))
                }
                self.data = nil
            case .requestGuildMembers:
                throw DecodingError.dataCorrupted(.init(
                    codingPath: container.codingPath,
                    debugDescription: "`requestGuildMembers` opcode is supposed to never be received."
                ))
            case .invalidSession:
                self.data = try .invalidSession(canResume: decodeData())
            case .hello:
                self.data = try .hello(decodeData())
            case .heartbeatAccepted:
                guard try container.decodeNil(forKey: .data) else {
                    throw DecodingError.typeMismatch(Optional<Never>.self, .init(
                        codingPath: container.codingPath,
                        debugDescription: "`heartbeatAccepted` opcode is supposed to have no data."
                    ))
                }
                self.data = nil
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
            case .dispatch, .reconnect, .invalidSession, .heartbeatAccepted:
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
            case let .identify(payload):
                try container.encode(payload, forKey: .data)
            case let .hello(payload):
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
    
    public enum CloseEventCode: Int, Codable {
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
    
    public struct Identify: Codable {
        
        public struct PresenceUpdate: Codable {
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
        
        public enum Intent: Int {
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
        }
        
        public var token: String
        public var properties: ConnectionProperties = ConnectionProperties()
        public var compress: Bool?
        public var large_threshold: Int?
        public var shard: IntPair?
        public var presence: PresenceUpdate?
        public var intents: IntBitField<Intent>
        
        public init(token: String, compress: Bool? = nil, large_threshold: Int? = nil, shard: IntPair? = nil, presence: PresenceUpdate? = nil, intents: IntBitField<Intent>) {
            self.token = token
            self.compress = compress
            self.large_threshold = large_threshold
            self.shard = shard
            self.presence = presence
            self.intents = intents
        }
    }
    
    public struct ConnectionProperties: Codable {
        public var os: String = "linux"
        public let browser: String = "MahdiBM.Swift.Discord"
        public let device: String = "MahdiBM.Swift.Discord"
        
        enum CodingKeys: String, CodingKey {
            case os = "$os"
            case browser = "$browser"
            case device = "$device"
        }
    }
    
    public struct Resume: Codable {
        public var token: String
        public var session_id: String
        public var seq: Int
        
        public init(token: String, session_id: String, seq: Int) {
            self.token = token
            self.session_id = session_id
            self.seq = seq
        }
    }
    
    public struct VoiceStateUpdate: Codable {
        public var guild_id: String
        public var channel_id: String?
        public var self_mute: Bool
        public var self_deaf: Bool
        public var self_video: Bool?
        public var self_stream: Bool?
        public var user_id: String?
        public var mute: Bool?
        public var deaf: Bool?
        public var request_to_speak_timestamp: DiscordTimestamp?
        public var session_id: String?
        public var member: Member?
        public var suppress: Bool?
    }
    
    public enum Status: String, Codable {
        case online = "online"
        case doNotDisturb = "dnd"
        case afk = "idle"
        case invisible = "invisible"
        case offline = "offline"
    }
    
    public struct Hello: Codable {
        public var heartbeat_interval: Int
    }
    
    public struct User: Codable {
        
        public enum PremiumKind: Int, Codable {
            case none = 0
            case nitroClassic = 1
            case nitro = 2
        }
        
        public enum Flag: Int {
            case staff = 0
            case partner = 1
            case hypeSquad = 2
            case BugHunterLevel1 = 3
            case hypeSquadOnlineHouse1 = 6
            case hypeSquadOnlineHouse2 = 7
            case hypeSquadOnlineHouse3 = 8
            case premiumEarlySupporter = 9
            case teamPseudoUser = 10
            case bugHunterLevel2 = 14
            case verifiedBot = 16
            case verifiedDeveloper = 17
            case certifiedModerator = 18
            case botHttpInteractions = 19
            case unknownValue20 = 20
        }
        
        public var id: String
        public var username: String
        public var discriminator: String
        public var avatar: String?
        public var bot: Bool?
        public var system: Bool?
        public var mfa_enabled: Bool?
        public var banner: String?
        public var accent_color: DiscordColor?
        public var locale: DiscordLocale?
        public var verified: Bool?
        public var email: String?
        public var flags: IntBitField<Flag>?
        public var premium_type: PremiumKind?
        public var public_flags: IntBitField<Flag>?
        public var avatar_decoration: String?
    }
    
    public struct PartialUser: Codable {
        public var id: String
        public var username: String?
        public var discriminator: String?
        public var avatar: String?
        public var bot: Bool?
        public var system: Bool?
        public var mfa_enabled: Bool?
        public var banner: String?
        public var accent_color: DiscordColor?
        public var locale: DiscordLocale?
        public var verified: Bool?
        public var email: String?
        public var flags: IntBitField<User.Flag>?
        public var premium_type: User.PremiumKind?
        public var public_flags: IntBitField<User.Flag>?
        public var avatar_decoration: String?
    }
    
    public struct PartialApplication: Codable {
        
        public struct Team: Codable {
            
            public struct Member: Codable {
                
                public enum State: Int, Codable {
                    case invited = 1
                    case accepted = 2
                }
                
                public var membership_state: State
                public var permissions: [String]
                public var team_id: String?
                public var user: PartialUser
            }
            
            public var icon: String?
            public var id: String
            public var members: [Member]
            public var name: String
            public var owner_user_id: String
        }
        
        public enum Flag: Int {
            case gatewayPresence = 12
            case gatewayPresenceLimited = 13
            case gatewayGuildMembers = 14
            case gatewayGuildMembersLimited = 15
            case verificationPendingGuildLimit = 16
            case embedded = 17
            case gatewayMessageContent = 18
            case gatewayMessageContentLimited = 19
            case unknownFlag20 = 20
            case unknownFlag21 = 21
            case unknownFlag23 = 23
        }
        
        public struct InstallParams: Codable {
            public var scopes: [String]
            public var permissions: StringBitField<Channel.Permission>
        }
        
        public var id: String
        public var name: String?
        public var icon: String?
        public var description: String?
        public var rpc_origins: [String]?
        public var bot_public: Bool?
        public var bot_require_code_grant: Bool?
        public var terms_of_service_url: String?
        public var privacy_policy_url: String?
        public var owner: PartialUser?
        public var verify_key: String?
        public var team: Team?
        public var guild_id: String?
        public var primary_sku_id: String?
        public var slug: String?
        public var cover_image: String?
        public var flags: IntBitField<Flag>?
        public var tags: [String]?
        public var install_params: InstallParams?
        public var custom_install_url: String?
        public var summary: String?
        public var type: Int?
        public var max_participants: Int?
        public var hook: Bool?
    }
    
    public struct UnavailableGuild: Codable {
        public var id: String
        public var unavailable: Bool?
    }
    
    public struct Ready: Codable {
        
        public struct AudioContextSettings: Codable {
            
        }
        
        public var v: Int
        public var user: User
        public var guilds: [UnavailableGuild]
        public var session_id: String
        public var shard: IntPair?
        public var application: PartialApplication
        public var presences: [PresenceUpdate]
        public var geo_ordered_rtc_regions: [String]
        public var guild_join_requests: [String] // FIXME
        public var private_channels: [Channel]
        public var user_settings: [String: String] // FIXME
        public var relationships: [String] // FIXME
        public var session_type: String?
        public var auth_session_id_hash: String?
        public var resume_gateway_url: String?
        public var audio_context_settings: AudioContextSettings?
    }
    
    public struct ThreadMetadata: Codable {
        public var archived: Bool
        public var auto_archive_duration: Int
        public var archive_timestamp: DiscordTimestamp
        public var locked: Bool
        public var invitable: Bool?
        public var create_timestamp: DiscordTimestamp?
    }
    
    public struct ThreadMember: Codable {
        public var id: String
        public var user_id: String?
        public var join_timestamp: DiscordTimestamp
        /// FIXME:
        /// Not documented what exactly the flags are.
        /// Discord says: "any user-thread settings, currently only used for notifications".
        public var flags: Int
        public var mute_config: String?
        public var muted: Bool?
    }
    
    public struct Channel: Codable {
        
        public enum Kind: Int, Codable {
            case guildText = 0
            case dm = 1
            case guildVoice = 2
            case groupDm = 3
            case guildCategory = 4
            case guildNews = 5
            case guildNewsThread = 10
            case guildPublicThread = 11
            case guildPrivateThread = 12
            case guildStageVoice = 13
            case guildDirectory = 14
            case guildForum = 15
        }
        
        public enum Permission: Int, Codable {
            case createInstantInvite = 0
            case kickMembers = 1
            case banMembers = 2
            case administrator = 3
            case manageChannels = 4
            case manageGuild = 5
            case addReactions = 6
            case viewAuditLog = 7
            case prioritySpeaker = 8
            case stream = 9
            case viewChannel = 10
            case sendMessages = 11
            case sendTtsMessages = 12
            case manageMessages = 13
            case embedLinks = 14
            case attachFiles = 15
            case readMessageHistory = 16
            case mentionEveryone = 17
            case useExternalEmojis = 18
            case viewGuildInsights = 19
            case connect = 20
            case speak = 21
            case muteMembers = 22
            case deafenMembers = 23
            case moveMembers = 24
            case useVAD = 25
            case changeNickname = 26
            case manageNicknames = 27
            case manageRoles = 28
            case manageWebHooks = 29
            case manageEmojisAndStickers = 30
            case useApplicationCommands = 31
            case requestToSpeak = 32
            case manageEvents = 33
            case manageThreads = 34
            case createPublicThreads = 35
            case createPrivateThreads = 36
            case useExternalStickers = 37
            case sendMessagesInThreads = 38
            case useEmbeddedActivities = 39
            case moderateMembers = 40
            case unknownValue41 = 41
        }
        
        public struct Overwrite: Codable {
            
            public enum Kind: Int, Codable {
                case role = 0
                case member = 1
            }
            
            public var id: String
            public var type: Kind
            public var allow: StringBitField<Permission>
            public var deny: StringBitField<Permission>
        }
        
        public enum Flag: Int {
            case pinned = 1
        }
        
        public var id: String
        public var type: Kind
        public var guild_id: String?
        public var position: Int?
        public var permission_overwrites: [Overwrite]?
        public var name: String?
        public var topic: String?
        public var nsfw: Bool?
        public var last_message_id: String?
        public var bitrate: Int?
        public var user_limit: Int?
        public var rate_limit_per_user: Int?
        public var recipients: [User]?
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
        public var thread_metadata: ThreadMetadata?
        public var member: ThreadMember?
        public var default_auto_archive_duration: Int?
        public var default_thread_rate_limit_per_user: Int?
        public var permissions: StringBitField<Permission>?
        public var flags: IntBitField<Flag>?
        public var available_tags: [String]?
        public var template: String?
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    public struct PartialChannel: Codable {
        public var id: String
        public var type: Channel.Kind
        public var name: String?
        public var permissions: StringBitField<Channel.Permission>?
        public var parent_id: String?
        public var thread_metadata: ThreadMetadata?
    }
    
    public struct ThreadCreate: Codable {
        public var id: String
        public var type: Channel.Kind
        public var guild_id: String?
        public var position: Int?
        public var permission_overwrites: [Channel.Overwrite]?
        public var name: String?
        public var topic: String?
        public var nsfw: Bool?
        public var last_message_id: String?
        public var bitrate: Int?
        public var user_limit: Int?
        public var rate_limit_per_user: Int?
        public var recipients: [User]?
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
        public var permissions: StringBitField<Channel.Permission>?
        public var flags: IntBitField<Channel.Flag>?
        public var newly_created: Bool?
        public var thread_member: ThreadMember?
        public var available_tags: [String]?
        public var template: String?
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
        public var member_ids_preview: [String]?
    }
    
    public struct ThreadDelete: Codable {
        public var id: String
        public var type: Channel.Kind
        public var guild_id: String?
        public var parent_id: String?
    }
    
    public struct ThreadListSync: Codable {
        public var guild_id: String
        public var channel_ids: [String]?
        public var threads: [Channel]
        public var members: [ThreadMember]
    }
    
    public struct ThreadMemberUpdate: Codable {
        public var id: String
        public var user_id: String?
        public var join_timestamp: DiscordTimestamp
        /// FIXME:
        /// Not documented what exactly the flags are.
        /// Discord says: "any user-thread settings, currently only used for notifications".
        public var flags: Int
        public var guild_id: String
    }
    
    public struct ThreadMembersUpdate: Codable {
        
        public struct ThreadMember: Codable {
            
            public struct ThreadMemberPresenceUpdate: Codable {
                public var user: PartialUser
                public var guild_id: String?
                public var status: Status
                public var activities: [Activity]
                public var client_status: PresenceUpdate.ClientStatus
                public var game: PresenceUpdate.Game?
            }
            
            public var id: String
            public var user_id: String?
            public var join_timestamp: DiscordTimestamp
            /// FIXME:
            /// Not documented what exactly the flags are.
            /// Discord says: "any user-thread settings, currently only used for notifications".
            public var flags: Int
            public var member: Member
            public var presence: ThreadMemberPresenceUpdate?
        }
        
        public var id: String
        public var guild_id: String
        public var member_count: Int
        public var added_members: [ThreadMember]?
        public var removed_member_ids: [String]?
    }
    
    public struct ChannelPinsUpdate: Codable {
        public var guild_id: String?
        public var channel_id: String
        public var last_pin_timestamp: DiscordTimestamp?
    }
    
    public struct PartialVoiceState: Codable {
        public var guild_id: String?
        public var channel_id: String?
        public var user_id: String?
        public var member: Member?
        public var session_id: String?
        public var deaf: Bool?
        public var mute: Bool?
        public var self_deaf: Bool?
        public var self_mute: Bool?
        public var self_stream: Bool?
        public var self_video: Bool?
        public var suppress: Bool?
        public var request_to_speak_timestamp: DiscordTimestamp?
    }
    
    public struct GuildBan: Codable {
        public var guild_id: String
        public var user: User
    }
    
    public struct Emoji: Codable {
        public var id: String?
        public var name: String?
        public var roles: [String]?
        public var user: User?
        public var require_colons: Bool?
        public var managed: Bool?
        public var animated: Bool?
        public var available: Bool?
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    public struct GuildEmojisUpdate: Codable {
        public var guild_id: String
        public var emojis: [Emoji]
        public var hashes: Hashes?
        public var guild_hashes: Hashes?
    }
    
    public struct Sticker: Codable {
        
        public enum Kind: Int, Codable {
            case standard = 1
            case guild = 2
        }
        
        public enum FormatKind: Int, Codable {
            case png = 1
            case apng = 2
            case lottie = 3
        }
        
        public var id: String
        public var pack_id: String?
        public var name: String
        public var description: String?
        public var tags: String
        public var asset: String?
        public var type: Kind
        public var format_type: FormatKind
        public var available: Bool?
        public var guild_id: String?
        public var user: User?
        public var sort_value: Int?
    }
    
    public struct GuildStickersUpdate: Codable {
        public var guild_id: String
        public var stickers: [Sticker]
        public var hashes: Hashes?
        public var guild_hashes: Hashes?
    }
    
    public struct GuildIntegrationsUpdate: Codable {
        public var guild_id: String
    }
    
    public struct GuildMemberAdd: Codable {
        public var guild_id: String
        public var roles: [String]
        public var hoisted_role: String?
        public var user: User
        public var nick: String?
        public var avatar: String?
        public var joined_at: DiscordTimestamp
        public var premium_since: DiscordTimestamp?
        public var deaf: Bool
        public var mute: Bool
        public var pending: Bool?
        public var is_pending: Bool?
        public var flags: IntBitField<User.Flag> // FIXME not sure about `User.Flag`
        public var permissions: StringBitField<Channel.Permission>?
        public var communication_disabled_until: DiscordTimestamp?
    }
    
    public struct GuildMemberRemove: Codable {
        public var guild_id: String
        public var user: User
    }
    
    public struct GuildMemberUpdate: Codable {
        public var guild_id: String
        public var roles: [String]
        public var hoisted_role: String?
        public var user: User
        public var nick: String?
        public var avatar: String?
        public var joined_at: DiscordTimestamp?
        public var premium_since: DiscordTimestamp?
        public var deaf: Bool?
        public var mute: Bool?
        public var flags: IntBitField<User.Flag>? // FIXME not sure about `User.Flag`
        public var pending: Bool?
        public var is_pending: Bool?
        public var communication_disabled_until: DiscordTimestamp?
    }
    
    public struct GuildMembersChunk: Codable {
        public var guild_id: String
        public var members: Set<Member>
        public var chunk_index: Int
        public var chunk_count: Int
        public var not_found: [String]?
        public var presences: [PartialPresenceUpdate]?
        public var nonce: String?
    }
    
    public struct RequestGuildMembers: Codable {
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
    
    public struct GuildJoinRequestUpdate: Codable {
        
        public struct Request: Codable {
            
            public struct FormResponse: Codable {
                
                public enum FieldKind: String, Codable {
                    case terms = "TERMS"
                }
                
                public struct Automation: Codable { }
                
                public var values: [String]
                public var response: Bool
                public var required: Bool
                public var label: String
                public var field_type: FieldKind
                public var description: String?
                public var automations: [Automation]?
            }
            
            public var user_id: String
            public var user: User
            public var rejection_reason: String?
            public var last_seen: DiscordTimestamp
            public var created_at: DiscordTimestamp
            public var id: String
            public var guild_id: String
            public var form_responses: [FormResponse]
            public var application_status: Status
            public var actioned_by_user: User
            public var actioned_at: String /// Seems to be a Snowflake ?!
        }
        
        public enum Status: String, Codable {
            case approved = "APPROVED"
        }
        
        public var request: Request
        public var status: Status
        public var guild_id: String
    }
    
    public struct GuildJoinRequestDelete: Codable {
        public var id: String
        public var guild_id: String
        public var user_id: String
    }
    
    public struct Role: Codable {
        
        public struct Tags: Codable {
            public var bot_id: String?
            public var integration_id: String?
            public var premium_subscriber: Bool?
        }
        
        public var id: String
        public var name: String
        public var color: DiscordColor
        public var hoist: Bool
        public var icon: String?
        public var unicode_emoji: String?
        public var position: Int
        public var permissions: StringBitField<Channel.Permission>
        public var managed: Bool
        public var mentionable: Bool
        public var flags: IntBitField<User.Flag>? // FIXME not sure about `User.Flag`
        public var tags: Tags?
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    public struct GuildRole: Codable {
        public var guild_id: String
        public var role: Role
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    public struct GuildRoleDelete: Codable {
        public var guild_id: String
        public var role_id: String
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
    }
    
    public struct GuildScheduledEvent: Codable {
        
        public enum PrivacyLevel: Int, Codable {
            case guildOnly = 2
        }
        
        public enum Status: Int, Codable {
            case scheduled = 1
            case active = 2
            case completed = 3
            case canceled = 4
        }
        
        public enum EntityKind: Int, Codable {
            case stageInstance = 1
            case voice = 2
            case external = 3
        }
        
        public struct EntityMetadata: Codable {
            public var location: String?
        }
        
        public var id: String
        public var guild_id: String
        public var channel_id: String?
        public var creator_id: String?
        public var name: String
        public var description: String?
        public var scheduled_start_time: DiscordTimestamp
        public var scheduled_end_time: DiscordTimestamp?
        public var privacy_level: PrivacyLevel
        public var status: Status
        public var entity_type: EntityKind
        public var entity_id: String?
        public var entity_metadata: EntityMetadata?
        public var creator: User?
        public var user_count: Int?
        public var image: String?
        public var sku_ids: [String]?
    }
    
    public struct GuildScheduledEventUser: Codable {
        public var guild_scheduled_event_id: String
        public var user_id: String
        public var guild_id: String
    }
    
    public struct GuildApplicationCommandIndexUpdate: Codable {
        public var hashes: Hashes
        public var guild_hashes: Hashes
        public var application_command_counts: [String: Int]
        public var guild_id: String
    }
    
    public struct Integration: Codable {
        
        public enum Kind: String, Codable {
            case twitch
            case youtube
            case discord
        }
        
        public enum ExpireBehavior: Int, Codable {
            case removeRole = 0
            case kick = 1
        }
        
        public struct Account: Codable {
            public var id: String
            public var name: String
        }
        
        public struct IntegrationApp: Codable {
            public var id: String
            public var name: String
            public var icon: String?
            public var description: String
            public var summary: String?
            public var type: Int?
            public var bot: User?
            public var primary_sku_id: String?
            public var cover_image: String?
            public var scopes: [String]?
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
        public var user: User?
        public var account: Account
        public var synced_at: DiscordTimestamp?
        public var subscriber_count: Int?
        public var revoked: Bool?
        public var application: IntegrationApp?
        public var guild_id: String
        public var guild_hashes: Hashes?
        public var hashes: Hashes?
        public var scopes: [String]?
    }
    
    public struct IntegrationDelete: Codable {
        public var id: String
        public var guild_id: String
        public var application_id: String?
        public var hashes: Hashes?
        public var guild_hashes: Hashes?
    }
    
    public struct InviteCreate: Codable {
        public var type: Int? // FIXME: TYPIFY
        public var channel_id: String
        public var code: String
        public var created_at: DiscordTimestamp
        public var guild_id: String?
        public var inviter: User?
        public var max_age: Int
        public var max_uses: Int
        public var target_type: Int?
        public var target_user: User?
        public var target_application: PartialApplication?
        public var temporary: Bool
        public var uses: Int
        public var expires_at: DiscordTimestamp?
    }
    
    public struct InviteDelete: Codable {
        public var channel_id: String
        public var guild_id: String?
        public var code: String
    }
    
    public struct PartialMember: Codable {
        public var user: User?
        public var nick: String?
        public var avatar: String?
        public var roles: [String]?
        public var hoisted_role: String?
        public var joined_at: DiscordTimestamp?
        public var premium_since: DiscordTimestamp?
        public var deaf: Bool?
        public var mute: Bool?
        public var pending: Bool?
        public var is_pending: Bool?
        public var flags: IntBitField<User.Flag>? // FIXME not sure about `User.Flag`
        public var permissions: StringBitField<Channel.Permission>?
        public var communication_disabled_until: DiscordTimestamp?
    }
    
    public final class DereferenceBox<C>: Codable, CustomStringConvertible where C: Codable {
        public var value: C
        
        public init(from decoder: Decoder) throws {
            value = try C.init(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            try value.encode(to: encoder)
        }
        
        public var description: String {
            "\(value)"
        }
    }
    
    // MessageCreate
    public struct Message: Codable {
        
        public struct MessageReference: Codable {
            public var message_id: String?
            public var channel_id: String?
            public var guild_id: String?
            public var fail_if_not_exists: Bool?
        }
        
        public struct Interaction: Codable {
            
            public enum Kind: Int, Codable {
                case ping = 1
                case applicationCommand = 2
                case messageComponent = 3
                case applicationCommandAutocomplete = 4
                case modalSubmit = 5
            }
            
            public var id: String
            public var type: Kind
            public var name: String
            public var user: User
            public var member: PartialMember?
        }
        
        public enum Kind: Int, Codable {
            case `default` = 0
            case recipientAdd = 1
            case recipientRemove = 2
            case call = 3
            case channelNameChange = 4
            case channelIconChange = 5
            case channelPinnedMessage = 6
            case guildMemberJoin = 7
            case userPremiumGuildSubscription = 8
            case userPremiumGuildSubscriptionTier1 = 9
            case userPremiumGuildSubscriptionTier2 = 10
            case userPremiumGuildSubscriptionTier3 = 11
            case channelFollowAdd = 12
            case guildDiscoveryDisqualified = 14
            case guildDiscoveryRequalified = 15
            case guildDiscoveryGracePeriodInitialWarning = 16
            case guildDiscoveryGracePeriodFinalWarning = 17
            case threadCreated = 18
            case reply = 19
            case chatInputCommand = 20
            case threadStarterMessage = 21
            case guildInviteReminder = 22
            case contextMenuCommand = 23
            case autoModerationAction = 24
        }
        
        public enum Flag: Int {
            case crossposted = 0
            case isCrosspost = 1
            case suppressEmbeds = 2
            case sourceMessageDeleted = 3
            case urgent = 4
            case hasThread = 5
            case ephemeral = 6
            case loading = 7
            case failedToMentionSomeRolesInThread = 8
            case unknownValue10 = 10
        }
        
        public struct Mention: Codable {
            public var id: String
            public var username: String
            public var discriminator: String
            public var avatar: String?
            public var bot: Bool?
            public var system: Bool?
            public var mfa_enabled: Bool?
            public var banner: String?
            public var accent_color: DiscordColor?
            public var locale: DiscordLocale?
            public var verified: Bool?
            public var email: String?
            public var flags: IntBitField<User.Flag>?
            public var premium_type: User.PremiumKind?
            public var public_flags: IntBitField<User.Flag>?
            public var member: Member?
            public var avatar_decoration: String?
        }
        
        public struct ChannelMention: Codable {
            public var id: String
            public var guild_id: String
            public var type: Channel.Kind
            public var name: String
        }
        
        public struct Attachment: Codable {
            public var id: String
            public var filename: String
            public var description: String?
            public var content_type: String?
            public var size: Int
            public var url: String
            public var proxy_url: String
            public var height: Int?
            public var width: Int?
            public var ephemeral: Bool?
        }
        
        public struct Reaction: Codable {
            public var count: Int
            public var me: Bool
            public var emoji: PartialEmoji
        }
        
        public struct Activity: Codable {
            
            public enum Kind: Int, Codable {
                case join = 1
                case spectate = 2
                case listen = 3
                case joinRequest = 5
            }
            
            public var type: Kind
            public var party_id: String?
        }
        
        public struct StickerItem: Codable {
            public var id: String
            public var name: String
            public var format_type: Sticker.FormatKind
        }
        
        public var id: String
        public var channel_id: String
        public var guild_id: String?
        public var author: PartialUser?
        public var member: PartialMember?
        public var content: String
        public var timestamp: DiscordTimestamp
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool
        public var mention_everyone: Bool
        public var mentions: [Mention]
        public var mention_roles: [String]
        public var mention_channels: [ChannelMention]?
        public var attachments: [Attachment]
        public var embeds: [Embed]
        public var reactions: [Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool
        public var webhook_id: String?
        public var type: Kind
        public var activity: Activity?
        public var application: PartialApplication?
        public var application_id: String?
        public var message_reference: MessageReference?
        public var flags: IntBitField<Flag>?
        public var referenced_message: DereferenceBox<Message>?
        public var interaction: Interaction?
        public var thread: Channel?
        public var components: [ActionRow]?
        public var sticker_items: [StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
    }
    
    public struct PartialMessage: Codable {
        public var id: String
        public var channel_id: String
        public var guild_id: String?
        public var author: PartialUser?
        public var member: PartialMember?
        public var content: String?
        public var timestamp: DiscordTimestamp?
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool?
        public var mention_everyone: Bool?
        public var mentions: [Message.Mention]?
        public var mention_roles: [String]?
        public var mention_channels: [Message.ChannelMention]?
        public var attachments: [Message.Attachment]?
        public var embeds: [Embed]?
        public var reactions: [Message.Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool?
        public var webhook_id: String?
        public var type: Message.Kind?
        public var activity: Message.Activity?
        public var application: PartialApplication?
        public var application_id: String?
        public var message_reference: Message.MessageReference?
        public var flags: IntBitField<Message.Flag>?
        public var referenced_message: DereferenceBox<PartialMessage>?
        public var interaction: Message.Interaction?
        public var thread: Channel?
        public var components: [ActionRow]?
        public var sticker_items: [Message.StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
    }
    
    public struct MessageDelete: Codable {
        public var id: String
        public var channel_id: String
        public var guild_id: String?
    }
    
    public struct MessageDeleteBulk : Codable {
        public var ids: [String]
        public var channel_id: String
        public var guild_id: String?
    }
    
    public struct Member: Codable, Hashable {
        public var user: User?
        public var nick: String?
        public var avatar: String?
        public var roles: [String]
        public var hoisted_role: String?
        public var joined_at: DiscordTimestamp
        public var premium_since: DiscordTimestamp?
        public var deaf: Bool
        public var mute: Bool
        public var pending: Bool?
        public var is_pending: Bool?
        public var flags: IntBitField<User.Flag>? // FIXME not sure about `User.Flag`
        public var permissions: StringBitField<Channel.Permission>?
        public var communication_disabled_until: DiscordTimestamp?
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(user!.id)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.user!.id == rhs.user!.id
        }
        
        public func hasRole(withId id: String, guildId: String) -> Bool {
            /// guildId == id <-> role == @everyone
            guildId == id || self.roles.contains(where: { $0 == id })
        }
        
        public init(guildMemberAdd: GuildMemberAdd) {
            self.roles = guildMemberAdd.roles
            self.hoisted_role = guildMemberAdd.hoisted_role
            self.user = guildMemberAdd.user
            self.nick = guildMemberAdd.nick
            self.avatar = guildMemberAdd.avatar
            self.joined_at = guildMemberAdd.joined_at
            self.premium_since = guildMemberAdd.premium_since
            self.deaf = guildMemberAdd.deaf
            self.mute = guildMemberAdd.mute
            self.pending = guildMemberAdd.pending
            self.is_pending = guildMemberAdd.is_pending
            self.flags = guildMemberAdd.flags
            self.permissions = guildMemberAdd.permissions
            self.communication_disabled_until = guildMemberAdd.communication_disabled_until
        }
    }
    
    public struct MessageReactionAdd: Codable {
        public var user_id: String
        public var channel_id: String
        public var message_id: String
        public var guild_id: String?
        public var member: Member?
        public var emoji: Emoji
    }
    
    public struct MessageReactionRemove: Codable {
        public var user_id: String
        public var channel_id: String
        public var message_id: String
        public var guild_id: String?
        public var emoji: Emoji
    }
    
    public struct MessageReactionRemoveAll : Codable {
        public var channel_id: String
        public var message_id: String
        public var guild_id: String?
    }
    
    public struct MessageReactionRemoveEmoji: Codable {
        public var channel_id: String
        public var guild_id: String?
        public var message_id: String
        public var emoji: Emoji
    }
    
    public struct PresenceUpdate: Codable {
        
        public struct ClientStatus: Codable {
            public var desktop: String?
            public var mobile: String?
            public var web: String?
        }
        
        public struct Game: Codable {
            public var type: Int //FIXME: Make enum
            public var state: String?
            public var name: String
            public var created_at: TolerantDecodeDate
            public var id: String
            public var session_id: String?
            public var emoji: Emoji?
            public var platform: String?
            public var timestamps: [DiscordTimestamp]?
            public var application_id: String?
        }
        
        public var user: PartialUser
        public var guild_id: String
        public var status: Status
        public var activities: [Activity]
        public var client_status: ClientStatus
        public var game: Game?
    }
    
    public struct PartialPresenceUpdate: Codable {
        public var user: PartialUser?
        public var guild_id: String?
        public var status: Status?
        public var activities: [Activity]?
        public var client_status: PresenceUpdate.ClientStatus
        public var game: PresenceUpdate.Game?
    }
    
    public struct PartialEmoji: Codable {
        public var name: String
        public var id: String?
        public var animated: Bool?
        
        public init(name: String, id: String? = nil, animated: Bool? = nil) {
            self.name = name
            self.id = id
            self.animated = animated
        }
    }
    
    public struct Activity: Codable {
        
        public enum Kind: Int, Codable {
            case game = 0
            case streaming = 1
            case listening = 2
            case watching = 3
            case custom = 4
            case competing = 5
        }
        
        public struct Timestamps: Codable {
            public var start: Int?
            public var end: Int?
            
            public init(start: Int? = nil, end: Int? = nil) {
                self.start = start
                self.end = end
            }
        }
        
        public struct Party: Codable {
            public var id: String?
            public var size: IntPair?
            
            public init(id: String? = nil, size: IntPair? = nil) {
                self.id = id
                self.size = size
            }
        }
        
        public struct Assets: Codable {
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
        
        public struct Secrets: Codable {
            public var join: String?
            public var spectate: String?
            public var match: String?
            
            public init(join: String? = nil, spectate: String? = nil, match: String? = nil) {
                self.join = join
                self.spectate = spectate
                self.match = match
            }
        }
        
        public enum Flag: Int {
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
        
        public struct Button: Codable {
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
        
        public var name: String
        public var type: Kind
        public var url: String?
        public var id: String?
        public var created_at: Int?
        public var timestamps: Timestamps?
        public var application_id: String?
        public var details: String?
        public var state: String?
        public var emoji: PartialEmoji?
        public var party: Party?
        public var assets: Assets?
        public var secrets: Secrets?
        public var instance: Bool?
        public var flags: IntBitField<Flag>?
        public var buttons: [Button]?
        public var sync_id: String?
        public var session_id: String?
        public var platform: String?
        public var supported_platforms: [String]?
        
        public init(name: String, type: Kind, url: String? = nil, created_at: Int? = nil, timestamps: Timestamps? = nil, application_id: String? = nil, details: String? = nil, state: String? = nil, emoji: PartialEmoji? = nil, party: Party? = nil, assets: Assets? = nil, secrets: Secrets? = nil, instance: Bool? = nil, flags: IntBitField<Flag>? = nil, buttons: [Button]? = nil, sync_id: String? = nil, session_id: String? = nil, platform: String? = nil, supported_platforms: [String]? = nil) {
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
            self.assets = assets
            self.secrets = secrets
            self.instance = instance
            self.flags = flags
            self.buttons = buttons
            self.sync_id = sync_id
            self.session_id = session_id
            self.platform = platform
            self.supported_platforms = supported_platforms
        }
    }
    
    public struct TypingStart: Codable {
        public var channel_id: String
        public var guild_id: String?
        public var user_id: String
        public var timestamp: Int
        public var member: Member?
    }
    
    public struct VoiceServerUpdate: Codable {
        public var token: String
        public var guild_id: String
        public var endpoint: String?
    }
    
    public struct WebhooksUpdate: Codable {
        public var guild_id: String
        public var channel_id: String
    }
    
    public struct InteractionCreate: Codable {
        
        public enum Kind: Int, Codable {
            case ping = 1
            case applicationCommand = 2
            case messageComponent = 3
            case applicationCommandAutocomplete = 4
            case modalSubmit = 5
        }
        
        public struct Data: Codable {
            
            public struct ResolvedData: Codable {
                public var users: [String: User]?
                public var members: [String: PartialMember]?
                public var roles: [String: Role]?
                public var channels: [String: PartialChannel]?
                public var messages: [String: PartialMessage]?
                public var attachments: [String: Message.Attachment]?
            }
            
            public struct Option: Codable {
                
                public enum Kind: Int, Codable {
                    case subCommand = 1
                    case subCommandGroup = 2
                    case string = 3
                    case integer = 4
                    case boolean = 5
                    case user = 6
                    case channel = 7
                    case role = 8
                    case mentionable = 9
                    case number = 10
                    case attachment = 11
                }
                
                public var name: String
                public var type: Kind
                public var value: StringIntDoubleBool?
                public var options: [Option]?
                public var focused: Bool?
            }
            
            public enum ComponentKind: Int, Codable {
                case actionRow = 1
                case button = 2
                case selectMenu = 3
                case textInput = 4
            }
            
            public struct SelectOption: Codable {
                public var label: String
                public var value: String
                public var description: String?
                public var emoji: PartialEmoji?
                public var `default`: Bool?
            }
            
            public var id: String
            public var name: String
            public var type: Kind
            public var resolved: ResolvedData?
            public var options: [Option]?
            public var guild_id: String?
            public var custom_id: String?
            public var component_type: ComponentKind?
            public var values: [SelectOption]?
            public var target_id: String?
            public var components: [ActionRow]?
        }
        
        public var id: String
        public var application_id: String
        public var type: Kind
        public var data: Data?
        public var guild_id: String?
        public var channel_id: String?
        public var member: Member?
        public var user: User?
        public var token: String
        public var version: Int
        public var message: Message?
        public var locale: DiscordLocale?
        public var guild_locale: DiscordLocale?
        public var app_permissions: StringBitField<Channel.Permission>?
    }
    
    public struct StageInstance: Codable {
        
        public enum PrivacyLevel: Int, Codable {
            case `public` = 1
            case guildOnly = 2
        }
        
        public var id: String
        public var guild_id: String
        public var channel_id: String
        public var topic: String
        public var privacy_level: PrivacyLevel
        public var discoverable_disabled: Bool
        public var guild_scheduled_event_id: String?
    }
    
    public struct GatewayUrl: Codable {
        public var url: String
    }
    
    public struct GatewayBot: Codable {
        
        public struct SessionStartLimit: Codable {
            public var total: Int
            public var remaining: Int
            public var reset_after: Int
            public var max_concurrency: Int
        }
        
        public var url: String
        public var shards: Int
        public var session_start_limit: SessionStartLimit
    }
    
    public struct ApplicationCommandPermissionsUpdate: Codable {
        
        public struct Permission: Codable {
            public var type: Channel.Permission // FIXME: NOT SURE
            public var permission: Bool
            public var id: String
        }
        
        public var permissions: [Permission]
        public var id: String
        public var guild_id: String
        public var application_id: String
    }
}
