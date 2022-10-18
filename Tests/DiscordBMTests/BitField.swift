import DiscordBM
import XCTest

class BitFieldTests: XCTestCase {
    
    typealias Raw = Permission
    let allCases: [Raw] = [.createInstantInvite, .kickMembers, .banMembers, .administrator, .manageChannels, .manageGuild, .addReactions, .viewAuditLog, .prioritySpeaker, .stream, .viewChannel, .sendMessages, .sendTtsMessages, .manageMessages, .embedLinks, .attachFiles, .readMessageHistory, .mentionEveryone, .useExternalEmojis, .viewGuildInsights, .connect, .speak, .muteMembers, .deafenMembers, .moveMembers, .useVAD, .changeNickname, .manageNicknames, .manageRoles, .manageWebHooks, .manageEmojisAndStickers, .useApplicationCommands, .requestToSpeak, .manageEvents, .manageThreads, .createPublicThreads, .createPrivateThreads, .useExternalStickers, .sendMessagesInThreads, .useEmbeddedActivities, .moderateMembers, .unknownValue41]
    
    /// To make sure `IntBitField` and `StringBitField` have similar behavior,
    /// so we can continue the tests with only one of them.
    func testBitFieldsEqual() {
        for idx in (0..<100) {
            let unknownValues = (0...(.random(in: 0...10))).map { $0 + 60 }
            let values = (0...idx).map { _ in
                allCases.randomElement()!
            }
            let intField = IntBitField<Raw>(Set(values), unknownValues: Set(unknownValues))
            let stringField = StringBitField<Raw>(Set(values), unknownValues: Set(unknownValues))
            XCTAssertEqual(intField.toBitValue(), stringField.toBitValue())
        }
    }
    
    func testValueCalculation() {
        do {
            let field = IntBitField<Raw>([])
            XCTAssertEqual(field.toBitValue(), 0)
        }
        
        do {
            let field = IntBitField<Raw>([Raw(rawValue: 0)!])
            XCTAssertEqual(field.toBitValue(), 1)
        }
        
        do {
            let field = IntBitField<Raw>([Raw(rawValue: 1)!])
            XCTAssertEqual(field.toBitValue(), 2)
        }
        
        do {
            let field = IntBitField<Raw>([Raw(rawValue: 2)!])
            XCTAssertEqual(field.toBitValue(), 4)
        }
        
        do {
            let values = [0, 1, 2].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(values)
            XCTAssertEqual(field.toBitValue(), 7)
        }
        
        do {
            let values = [7, 8, 9, 15, 17, 18, 19, 20, 24].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(values)
            XCTAssertEqual(field.toBitValue(), 18_776_960)
        }
        
        do {
            let values = [0, 13, 14, 15, 18, 31].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(values)
            XCTAssertEqual(field.toBitValue(), 2_147_803_137)
        }
    }
    
    func testInitFromBitValue() {
        do {
            let field = IntBitField<Raw>(bitValue: -20_139_123)
            XCTAssertEqual(field, [])
        }
        
        do {
            let field = IntBitField<Raw>(bitValue: -1)
            XCTAssertEqual(field, [])
        }
        
        do {
            let field = IntBitField<Raw>(bitValue: 0)
            XCTAssertEqual(field, [])
        }
        
        do {
            let field = IntBitField<Raw>(bitValue: 1)
            XCTAssertEqual(field, [Raw(rawValue: 0)!])
        }
        
        do {
            let field = IntBitField<Raw>(bitValue: 2)
            XCTAssertEqual(field, [Raw(rawValue: 1)!])
        }
        
        do {
            let field = IntBitField<Raw>(bitValue: 3)
            XCTAssertEqual(field, [Raw(rawValue: 0)!, Raw(rawValue: 1)!])
        }
        
        do {
            let field = IntBitField<Raw>(bitValue: 4)
            XCTAssertEqual(field, [Raw(rawValue: 2)!])
        }
        
        do {
            let values = [7, 8, 9, 15, 17, 18, 19, 20, 24].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(bitValue: 18_776_960)
            XCTAssertEqual(field, IntBitField(values))
        }
        
        do {
            let values = [0, 13, 14, 15, 18, 31].map { Raw(rawValue: $0)! }
            let field = IntBitField<Raw>(bitValue: 2_147_803_137)
            XCTAssertEqual(field, IntBitField(values))
        }
        
        do {
            let field1 = IntBitField<Raw>(bitValue: 999_999_999_999_999)
            let field2 = IntBitField<Raw>([
                .administrator, .viewAuditLog, .kickMembers, .sendMessagesInThreads, .banMembers, .manageGuild, .manageChannels, .muteMembers, .manageMessages, .manageThreads, .sendMessages, .sendTtsMessages, .useExternalStickers, .manageWebHooks, .deafenMembers, .moderateMembers, .useExternalEmojis, .viewChannel, .prioritySpeaker, .createPrivateThreads, .useApplicationCommands, .createInstantInvite, .createPublicThreads, .embedLinks, .addReactions, .manageEvents, .changeNickname, .stream, .mentionEveryone
            ], unknownValues: [49, 48, 47, 43, 42])
            XCTAssertEqual(field1, field2)
        }
    }
}


extension IntBitField: Equatable {
    public static func == (lhs: IntBitField, rhs: IntBitField) -> Bool {
        lhs.values.count == rhs.values.count &&
        lhs.values.allSatisfy { rhs.values.contains($0) } &&
        lhs.unknownValues.count == rhs.unknownValues.count &&
        lhs.unknownValues.allSatisfy { rhs.unknownValues.contains($0) }
    }
}
