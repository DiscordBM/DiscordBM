@testable import DiscordModels
import DiscordUtilities
import XCTest

class UtilsTests: XCTestCase {
    
    func testDiscordUtils() {
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.mention(id: UserSnowflake(id))
            XCTAssertEqual(string, "<@\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.mention(id: ChannelSnowflake(id))
            XCTAssertEqual(string, "<#\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.mention(id: RoleSnowflake(id))
            XCTAssertEqual(string, "<@&\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(name: "abcd", id: Snowflake(id))
            XCTAssertEqual(string, "</abcd:\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(name: "polikj", id: Snowflake(id), subcommand: "hey")
            XCTAssertEqual(string, "</polikj hey:\(id)>")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.slashCommand(
                name: "bhjksa",
                id: Snowflake(id),
                subcommand: "poi",
                subcommandGroup: "homdas"
            )
            XCTAssertEqual(string, "</bhjksa homdas poi:\(id)>")
        }
        
        do {
            let string = DiscordUtils.standardUnicodeEmoji(emoji: "🥳")
            XCTAssertEqual(string, "🥳")
        }
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.customEmoji(name: "qwerrt", id: Snowflake(id))
            XCTAssertEqual(string, "<:qwerrt:\(id)>")
        }
        
        
        do {
            let id = "\(Int.random(in: 1_000_000_000_000_000...10_000_000_000_000_000))"
            let string = DiscordUtils.customAnimatedEmoji(name: "pwqoe", id: Snowflake(id))
            XCTAssertEqual(string, "<a:pwqoe:\(id)>")
        }
        
        
        do {
            let date = Date()
            let string1 = DiscordUtils.timestamp(date: date)
            let string2 = DiscordUtils.timestamp(unixTimestamp: date.timeIntervalSince1970)
            let string3 = DiscordUtils.timestamp(unixTimestamp: Int(date.timeIntervalSince1970))
            XCTAssertEqual(string1, "<t:\(Int(date.timeIntervalSince1970))>")
            XCTAssertEqual(string1, string2)
            XCTAssertEqual(string2, string3)
            XCTAssertEqual(string3, string1)
        }
        
        do {
            let date = Date()
            let string1 = DiscordUtils.timestamp(date: date, style: .relativeTime)
            let string2 = DiscordUtils.timestamp(
                unixTimestamp: date.timeIntervalSince1970,
                style: .relativeTime
            )
            let string3 = DiscordUtils.timestamp(
                unixTimestamp: Int(date.timeIntervalSince1970),
                style: .relativeTime
            )
            XCTAssertEqual(string1, "<t:\(Int(date.timeIntervalSince1970)):R>")
            XCTAssertEqual(string1, string2)
            XCTAssertEqual(string2, string3)
            XCTAssertEqual(string3, string1)
        }
    }
    
    func testDiscordUtilsEscapingSpecialCharacters() throws {
        let text = #"""
        *Hello!*
        __***How are you?***__
        > _I'm fine thank you!_
        > ~Not really :\(~
        || Just Kidding! || LOL | HEHE
        """#
        let expected = #"""
        \*Hello!\*
        \_\_\*\*\*How are you?\*\*\*\_\_
        \> \_I'm fine thank you!\_
        \> \~Not really \:\\(\~
        \|\| Just Kidding! \|\| LOL \| HEHE
        """#
        let escaped = DiscordUtils.escapingSpecialCharacters(text)
        XCTAssertEqual(escaped, expected)

        let link = #"https://raw.githubusercontent.com/apple/swift-evolution/proposals/0401-remove-property-wrapper-isolation.md"#
        let escapedLink = DiscordUtils.escapingSpecialCharacters(link, options: .keepLinks)
        XCTAssertEqual(escapedLink, link)

        let noNewLines = #"\*Hello!\*\n\_\_\*\*\*How are you?\*\*\*\_\_\n\> \_I'm fine thank you!\_\n\> \~Not really \:\\(\~\n\|\| Just Kidding! \|\| LOL \| HEHE"#
        let escapedLines = DiscordUtils.escapingSpecialCharacters(text, options: .escapeNewLines)
        XCTAssertEqual(escapedLines, noNewLines)
    }

    func testInteractionDataUtilities() throws {
        let applicationCommand: Interaction.Data = .applicationCommand(
            .init(id: "", name: "", type: .applicationCommand)
        )

        let messageComponent: Interaction.Data = .messageComponent(
            .init(custom_id: "", component_type: .actionRow)
        )

        let modalSubmit: Interaction.Data = .modalSubmit(
            .init(custom_id: "", components: [[.button(.init(label: "", url: ""))]])
        )

        XCTAssertNoThrow(try applicationCommand.requireApplicationCommand())
        XCTAssertThrowsError(try messageComponent.requireApplicationCommand())

        XCTAssertNoThrow(try messageComponent.requireMessageComponent())
        XCTAssertThrowsError(try modalSubmit.requireMessageComponent())

        XCTAssertNoThrow(try modalSubmit.requireModalSubmit())
        XCTAssertThrowsError(try applicationCommand.requireModalSubmit())
    }

    func testApplicationCommandUtilities() throws {
        let command = Interaction.ApplicationCommand(
            id: try! .makeFake(),
            name: "",
            type: .applicationCommand,
            options: [.init(name: "ppppp", type: .attachment)]
        )

        XCTAssertNotNil(command.option(named: "ppppp"))
        XCTAssertNoThrow(try command.requireOption(named: "ppppp"))

        XCTAssertNil(command.option(named: "dasdad"))
        XCTAssertThrowsError(try command.requireOption(named: "iaoso"))

        let option = Interaction.ApplicationCommand.Option(
            name: "dsdagedddd",
            type: .channel,
            options: [.init(name: "lsol", type: .number)]
        )

        XCTAssertNotNil(option.option(named: "lsol"))
        XCTAssertNoThrow(try option.requireOption(named: "lsol"))

        XCTAssertNil(option.option(named: "dasdad"))
        XCTAssertThrowsError(try option.requireOption(named: "iaoso"))

        let options = command.options!

        XCTAssertNotNil(options.option(named: "ppppp"))
        XCTAssertNoThrow(try options.requireOption(named: "ppppp"))

        XCTAssertNil(options.option(named: "dasdad"))
        XCTAssertThrowsError(try options.requireOption(named: "iaoso"))

        let actionsRows: [Interaction.ActionRow] = [
            .init(components: [
                .button(.init(style: .primary, label: "lsofm", custom_id: "lcmjf"))
            ])
        ]

        XCTAssertNotNil(actionsRows.component(customId: "lcmjf"))
        XCTAssertNoThrow(try actionsRows.requireComponent(customId: "lcmjf"))

        XCTAssertNil(actionsRows.component(customId: "dafe"))
        XCTAssertThrowsError(try actionsRows.requireComponent(customId: "grwgwr"))

        let actionsRow = actionsRows[0]

        XCTAssertNotNil(actionsRow.component(customId: "lcmjf"))
        XCTAssertNoThrow(try actionsRow.requireComponent(customId: "lcmjf"))

        XCTAssertNil(actionsRow.component(customId: "dafe"))
        XCTAssertThrowsError(try actionsRow.requireComponent(customId: "grwgwr"))

        let components = actionsRows[0].components

        XCTAssertNotNil(components.component(customId: "lcmjf"))
        XCTAssertNoThrow(try components.requireComponent(customId: "lcmjf"))

        XCTAssertNil(components.component(customId: "dafe"))
        XCTAssertThrowsError(try components.requireComponent(customId: "grwgwr"))

        do {
            let component: Interaction.ActionRow.Component = .button(
                .init(label: "mmm", url: "https://fake.com")
            )

            XCTAssertNoThrow(try component.requireButton())
            XCTAssertThrowsError(try component.requireStringSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .stringSelect(
                .init(custom_id: "ooo", options: [])
            )

            XCTAssertNoThrow(try component.requireStringSelect())
            XCTAssertThrowsError(try component.requireTextInput())
        }

        do {
            let component: Interaction.ActionRow.Component = .textInput(
                .init(custom_id: "qqq")
            )

            XCTAssertNoThrow(try component.requireTextInput())
            XCTAssertThrowsError(try component.requireUserSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .userSelect(
                .init(custom_id: "iii")
            )

            XCTAssertNoThrow(try component.requireUserSelect())
            XCTAssertThrowsError(try component.requireRoleSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .roleSelect(
                .init(custom_id: "lll")
            )

            XCTAssertNoThrow(try component.requireRoleSelect())
            XCTAssertThrowsError(try component.requireMentionableSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .mentionableSelect(
                .init(custom_id: "uuewe")
            )

            XCTAssertNoThrow(try component.requireMentionableSelect())
            XCTAssertThrowsError(try component.requireChannelSelect())
        }

        do {
            let component: Interaction.ActionRow.Component = .channelSelect(
                .init(custom_id: "cnajc")
            )

            XCTAssertNoThrow(try component.requireChannelSelect())
            XCTAssertThrowsError(try component.requireButton())
        }
    }

    func testStringIntDoubleBoolUtilities() throws {
        func option(_ value: StringIntDoubleBool) -> Interaction.ApplicationCommand.Option {
            .init(name: "", type: .boolean, value: value)
        }

        do {
            let value = StringIntDoubleBool.string("l")

            XCTAssertNoThrow(try value.requireString())
            XCTAssertThrowsError(try value.requireInt())

            XCTAssertNoThrow(try option(value).requireString())
            XCTAssertThrowsError(try option(value).requireInt())
        }

        do {
            let value = StringIntDoubleBool.int(1)

            XCTAssertNoThrow(try value.requireInt())
            XCTAssertThrowsError(try value.requireDouble())

            XCTAssertNoThrow(try option(value).requireInt())
            XCTAssertThrowsError(try option(value).requireDouble())
        }

        do {
            let value = StringIntDoubleBool.double(9.8)

            XCTAssertNoThrow(try value.requireDouble())
            XCTAssertThrowsError(try value.requireBool())

            XCTAssertNoThrow(try option(value).requireDouble())
            XCTAssertThrowsError(try option(value).requireBool())
        }

        do {
            let value = StringIntDoubleBool.bool(false)

            XCTAssertNoThrow(try value.requireBool())
            XCTAssertThrowsError(try value.requireString())

            XCTAssertNoThrow(try option(value).requireBool())
            XCTAssertThrowsError(try option(value).requireString())
        }
    }
}
