
/// https://discord.com/developers/docs/topics/teams#data-models-team-object
public struct Team: Sendable, Codable {
    
    /// https://discord.com/developers/docs/topics/teams#data-models-team-member-object
    public struct Member: Sendable, Codable {
        
        /// https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum
        public enum State: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case invited = 1
            case accepted = 2
        }

        /// https://discord.com/developers/docs/topics/teams#data-models-team-member-role-types
        public enum Role: String, Sendable, Codable, ToleratesIntDecodeMarker {
            case admin = "admin"
            case developer = "developer"
            case readOnly = "read_only"
        }

        public var membership_state: State
        @available(*, deprecated, message: "Will always be `[\"*\"]` when sent by Discord")
        public var permissions: [String]
        public var team_id: TeamSnowflake?
        public var user: PartialUser
        public var role: Role
    }
    
    public var icon: String?
    public var id: TeamSnowflake
    public var members: [Member]
    public var name: String
    public var owner_user_id: UserSnowflake
}
