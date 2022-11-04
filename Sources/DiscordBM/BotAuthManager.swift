
/// For now, only to be able to make bot auth urls dynamically, on demand.
/// It's an actor because we'll likely need it to be, if we add actual OAuth-2 support.
private let baseURLs = (
    authorization: "https://discord.com/api/oauth2/authorize",
    token: "https://discord.com/api/oauth2/token",
    tokenRevocation: "https://discord.com/api/oauth2/token/revoke"
)

public struct BotAuthManager: Sendable {
    
    let clientId: String
    
    public init(clientId: String) {
        self.clientId = clientId
    }
    
    /// The bot will immediately join servers which authorize your bot through this URL.
    public func makeBotAuthorizationURL(
        withSlashCommands: Bool = true,
        permissions: [Permission] = []
    ) -> String {
        var scopes: [OAuth2Scope] = [.bot]
        if withSlashCommands {
            scopes.append(.applicationsCommands)
        }
        let permissions = StringBitField<Permission>(permissions)
        let queries = [
            ("client_id", self.clientId),
            ("permissions", "\(permissions.toBitValue())"),
            ("scope", scopes.map(\.rawValue).joined(separator: " "))
        ]
        return baseURLs.authorization + queries.makeForURLQuery()
    }
}
