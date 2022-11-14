
@usableFromInline
enum RequestBody {
    @usableFromInline
    struct CreateDM: Sendable, Codable {
        var recipient_id: String
        
        @usableFromInline
        init(recipient_id: String) {
            self.recipient_id = recipient_id
        }
    }
}
