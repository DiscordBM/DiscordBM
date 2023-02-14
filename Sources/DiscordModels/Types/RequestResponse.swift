
public enum RequestResponse {
    
    /// https://discord.com/developers/docs/resources/channel#list-public-archived-threads-response-body
    public struct ArchivedThread: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
        public var has_more: Bool
    }
}
