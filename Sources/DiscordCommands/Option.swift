import DiscordModels

@propertyWrapper
public struct Option<Wrapped> {

    #warning("add 'CustomStringConvertible' to all new Error types")
    public enum Errors: Error {
        case optionNotAvailable(Option)
        case cannotParse(from: [ApplicationCommand.Option])
    }

    let creationPayload: ApplicationCommand.Option

    var parsedValue: Wrapped?

    public var wrappedValue: Wrapped {
        self.parsedValue !! fatalError("Option not initialized yet")
    }

    fileprivate init(creationPayload: ApplicationCommand.Option) {
        self.creationPayload = creationPayload
    }

    @available(*, unavailable, renamed: "init(name:description:)")
    public init() {
        fatalError("Unimplemented")
    }

    mutating func parse(from options: [ApplicationCommand.Option]) throws {
        fatalError("Unimplemented for '\(Self.self)' with wrapped type '\(Wrapped.self)'")
    }
}

extension Option where Wrapped == Bool {
    public init(
        name: String,
        nameLocalizations: [DiscordLocale : String]? = nil,
        description: String,
        descriptionLocalizations: [DiscordLocale : String]? = nil,
        required: Bool? = nil,
        channelTypes: [DiscordChannel.Kind]? = nil
    ) {
        self.creationPayload = .init(
            type: .boolean,
            name: name,
            name_localizations: nameLocalizations,
            description: description,
            description_localizations: descriptionLocalizations,
            required: required,
            channel_types: channelTypes
        )
    }
}

infix operator !!

func !! <T> (lhs: Optional<T>, rhs: @autoclosure () -> Never) -> T {
    if let lhs = lhs {
        return lhs
    } else {
        rhs()
    }
}
