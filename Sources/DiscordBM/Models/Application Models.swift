
public struct SlashCommand: Codable {
    
    public enum Kind: Int, Codable {
        case chatInput = 1
        case user = 2
        case message = 3
    }
    
    public var name: String
    public var name_localizations: [String: String]?
    public var description: String
    public var description_localizations: [String: String]?
    public var options: [CommandOption]?
    public var dm_permission: Bool?
    public var default_member_permissions: StringBitField<Gateway.Channel.Permission>?
    public var type: Kind?
    
    //MARK: Below fields are returned by Discord, and you don't need to send.
    /// deprecated
    var default_permission: Bool?
    public var id: String?
    public var application_id: String?
    public var guild_id: String?
    public var version: String?
    
    public init(name: String, name_localizations: [String : String]? = nil, description: String, description_localizations: [String : String]? = nil, options: [CommandOption]? = nil, dm_permission: Bool? = nil, default_member_permissions: [Gateway.Channel.Permission]? = nil, type: Kind? = nil) {
        self.name = name
        self.name_localizations = name_localizations
        self.description = description
        self.description_localizations = description_localizations
        self.options = options
        self.dm_permission = dm_permission
        self.default_member_permissions = default_member_permissions.map { .init(values: $0) }
        self.type = type
    }
}
