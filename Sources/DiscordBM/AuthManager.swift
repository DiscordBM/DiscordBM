
private let baseURLs = (
    authorization: "https://discord.com/api/oauth2/authorize",
    token: "https://discord.com/api/oauth2/token",
    tokenRevocation: "https://discord.com/api/oauth2/token/revoke"
)

/// For now, only to be able to make bot auth urls dynamically, on demand.
/// It's an actor because we'll likely need it to be, if we add actual OAuth-2 support.
public actor AuthManager: Sendable {
    
    let clientId: String
    let clientSecret: Secret /// Not used yet, but will be needed for OAuth-2
    
    public init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = Secret(clientSecret)
    }
    
    /// The bot will immediately join servers which authorize your bot through this URL.
    public nonisolated func makeBotAuthorizationURL(
        withSlashCommands: Bool = true,
        permissions: [Gateway.Channel.Permission] = []
    ) -> String {
        var scopes: [OAuthScope] = [.bot]
        if withSlashCommands {
            scopes.append(.applicationsCommands)
        }
        let permissions = StringBitField<Gateway.Channel.Permission>(permissions)
        let queries = [
            ("client_id", self.clientId),
            ("permissions", "\(permissions.toBitValue())"),
            ("scope", scopes.map(\.rawValue).joined(separator: " "))
        ]
        return baseURLs.authorization + queries.makeForURLQuery()
    }
}
