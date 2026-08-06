import Foundation

@propertyWrapper
public struct IncomingModalComponents: Sendable, Codable {
    public var wrappedValue: [Interaction.ActionRow] {
        didSet {
            componentsV2 = nil
        }
    }
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }
    public private(set) var componentsV2: [Interaction.ModalComponent]?

    public init(wrappedValue: [Interaction.ActionRow]) {
        self.wrappedValue = wrappedValue
        self.componentsV2 = nil
    }

    public init(componentsV2: [Interaction.ModalComponent]) {
        self.wrappedValue = []
        self.componentsV2 = componentsV2
    }

    public init(from decoder: any Decoder) throws {
        if let components = try? [Interaction.ActionRow](from: decoder) {
            self.wrappedValue = components
            self.componentsV2 = nil
        } else {
            self.wrappedValue = []
            self.componentsV2 = try [Interaction.ModalComponent](from: decoder)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        if let componentsV2 {
            try componentsV2.encode(to: encoder)
        } else {
            try wrappedValue.encode(to: encoder)
        }
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: IncomingModalComponents.Type, forKey key: Key) throws -> IncomingModalComponents {
        try decodeIfPresent(type, forKey: key) ?? IncomingModalComponents(wrappedValue: [])
    }
}
