
/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct DiscordApplication: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/application#application-object-application-flags
    @UnstableEnum<UInt>
    public enum Flag: Sendable {
        // Undocumented, app has published embedded app
        case embeddedReleased // 1
        // Undocumented, app can make Twitch-style emojis
        case managedEmoji // 2
        // Undocumented, embedded app can make in-app purchases
        case embeddedIAP // 3
        // Undocumented, app can make group DMs
        case groupDMCreate // 4
        // Undocumented, app can access local RPC server
        case rpcPrivateBeta // 5
        case applicationAutoModerationRuleCreateBadge // 6
        // Undocumented, app can make activity assets
        case allowAssets // 8
        // Undocumented, app can enable activity spectating
        case allowActivityActionSpectate // 9
        // Undocumented, app can enable activity join requests
        case allowActivityActionJoinRequest // 10
        // Undocumented, app has accessed local RPC before
        case rpcHasConnected // 11
        case gatewayPresence // 12
        case gatewayPresenceLimited // 13
        case gatewayGuildMembers // 14
        case gatewayGuildMembersLimited // 15
        case verificationPendingGuildLimit // 16
        case embedded // 17
        case gatewayMessageContent // 18
        case gatewayMessageContentLimited // 19
        // Undocumented, indicates first-party embedded app
        case embeddedFirstParty // 20
        case applicationCommandBadge // 23
        case active // 24
        // Undocumented, app can make iframe modals
        case iframeModals // 26
        case __undocumented(UInt)
    }

    /// https://discord.com/developers/docs/resources/application#install-params-object
    public struct InstallParams: Sendable, Codable {
        public var scopes: [OAuth2Scope]
        public var permissions: StringBitField<Permission>

        public init(scopes: [OAuth2Scope], permissions: StringBitField<Permission>) {
            self.scopes = scopes
            self.permissions = permissions
        }
    }

    /// https://discord.com/developers/docs/resources/application#application-object-application-integration-types
    @_spi(UserInstallableApps)
    @UnstableEnum<Int>
    public enum IntegrationKind: Sendable, Codable, CodingKeyRepresentable {
        case guildInstall // 0
        case userInstall // 1
        case __undocumented(Int)
    }

    /// https://discord.com/developers/docs/resources/application#application-object-application-integration-type-configuration-object
    @_spi(UserInstallableApps)
    public struct IntegrationKindConfiguration: Sendable, Codable {
        public var oauth2_install_params: InstallParams?

        public init(oauth2_install_params: InstallParams? = nil) {
            self.oauth2_install_params = oauth2_install_params
        }
    }

    public var id: ApplicationSnowflake
    public var name: String
    public var icon: String?
    public var description: String
    public var rpc_origins: [String]?
    public var bot_public: Bool
    public var bot_require_code_grant: Bool
    public var bot: PartialUser?
    public var terms_of_service_url: String?
    public var privacy_policy_url: String?
    public var owner: PartialUser?
    public var verify_key: String
    public var team: Team?
    public var guild_id: GuildSnowflake?
    public var guild: PartialGuild?
    /// FIXME: Change type to ``SKUSnowflake`` in a new major version
    public var primary_sku_id: AnySnowflake?
    public var slug: String?
    public var cover_image: String?
    public var flags: IntBitField<Flag>?
    public var approximate_guild_count: Int?
    public var redirect_uris: [String]?
    public var interactions_endpoint_url: String?
    public var role_connections_verification_url: String?
    public var tags: [String]?
    public var install_params: InstallParams?
    @_spi(UserInstallableApps) @DecodeOrNil
    public var integration_types: [IntegrationKind]?
    @_spi(UserInstallableApps) @DecodeOrNil
    public var integration_types_config: [IntegrationKind: IntegrationKindConfiguration]?
    public var custom_install_url: String?
}

/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct PartialApplication: Sendable, Codable {
    public var id: ApplicationSnowflake
    public var name: String?
    public var icon: String?
    public var description: String?
    public var rpc_origins: [String]?
    public var bot_public: Bool?
    public var bot_require_code_grant: Bool?
    public var bot: PartialUser?
    public var terms_of_service_url: String?
    public var privacy_policy_url: String?
    public var owner: PartialUser?
    public var verify_key: String?
    public var team: Team?
    public var guild_id: GuildSnowflake?
    public var guild: PartialGuild?
    /// FIXME: Change type to ``SKUSnowflake`` in a new version
    public var primary_sku_id: AnySnowflake?
    public var slug: String?
    public var cover_image: String?
    public var flags: IntBitField<DiscordApplication.Flag>?
    public var approximate_guild_count: Int?
    public var redirect_uris: [String]?
    public var interactions_endpoint_url: String?
    public var role_connections_verification_url: String?
    public var tags: [String]?
    public var install_params: DiscordApplication.InstallParams?
    @_spi(UserInstallableApps) @DecodeOrNil
    public var integration_types: [DiscordApplication.IntegrationKind]?
    @_spi(UserInstallableApps) @DecodeOrNil
    public var integration_types_config: [DiscordApplication.IntegrationKind: DiscordApplication.IntegrationKindConfiguration]?
    public var custom_install_url: String?
}
