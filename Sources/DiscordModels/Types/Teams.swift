
/// https://discord.com/developers/docs/topics/teams#data-models-team-object
public struct Team: Sendable, Codable {
    
    /// https://discord.com/developers/docs/topics/teams#data-models-team-member-object
    public struct Member: Sendable, Codable {
        
        /// https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum
        public enum State: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case invited = 1
            case accepted = 2
        }
        
        public var membership_state: State
        public var permissions: [String]
        public var team_id: Snowflake<Team>?
        public var user: PartialUser
    }
    
    public var icon: String?
    public var id: Snowflake<Team>
    public var members: [Member]
    public var name: String
    public var owner_user_id: Snowflake<DiscordUser>
}
