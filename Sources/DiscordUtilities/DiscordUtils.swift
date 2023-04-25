import Foundation

/// Utilities for writing Discord messages.
/// https://discord.com/developers/docs/reference#message-formatting-formats
public enum DiscordUtils {
    
    /// https://discord.com/developers/docs/reference#message-formatting-timestamp-styles
    public enum TimestampStyle: String {
        /// `16:20`
        case shortTime = "t"
        /// `16:20:30`
        case longTime = "T"
        /// `20/04/2021`
        case shortDate = "d"
        /// `20 April 2021`
        case longDate = "D"
        /// Discord's default.
        /// `20 April 2021 16:20`
        case shortDateTime = "f"
        /// `Tuesday, 20 April 2021 16:20`
        case longDateTime = "F"
        /// `2 months ago` / `in 2 months`
        case relativeTime = "R"
    }
    
    /// When used in a Discord message, shows up as mentioning a user.
    @inlinable
    public static func userMention(id: String) -> String {
        "<@\(id)>"
    }
    
    /// When used in a Discord message, shows up as mentioning a channel.
    @inlinable
    public static func channelMention(id: String) -> String {
        "<#\(id)>"
    }
    
    /// When used in a Discord message, shows up as mentioning a role, if mentionable.
    @inlinable
    public static func roleMention(id: String) -> String {
        "<@&\(id)>"
    }
    
    /// When used in a Discord message, shows up as mentioning a slash command.
    @inlinable
    public static func slashCommand(
        name: String,
        id: String,
        subcommand: String? = nil,
        subcommandGroup: String? = nil
    ) -> String {
        let subcommandGroup = subcommandGroup.map { " \($0)" } ?? ""
        let subcommand = subcommand.map { " \($0)" } ?? ""
        return "</\(name)\(subcommandGroup)\(subcommand):\(id)>"
    }
    
    /// When used in a Discord message, shows up as an emoji.
    @inlinable
    public static func standardUnicodeEmoji(emoji: String) -> String {
        emoji
    }
    
    /// When used in a Discord message, shows up as a custom guild emoji.
    @inlinable
    public static func customEmoji(name: String, id: String) -> String {
        "<:\(name):\(id)>"
    }
    
    /// When used in a Discord message, shows up as a custom animated guild emoji.
    @inlinable
    public static func customAnimatedEmoji(name: String, id: String) -> String {
        "<a:\(name):\(id)>"
    }
    
    /// When used in a Discord message, shows up as a **localized** time.
    /// See ``TimestampStyle`` for examples.
    @inlinable
    public static func timestamp(date: Date, style: TimestampStyle? = nil) -> String {
        timestamp(unixTimestamp: Int(date.timeIntervalSince1970), style: style)
    }
    
    /// When used in a Discord message, shows up as a **localized** time.
    /// See ``TimestampStyle`` for examples.
    @inlinable
    public static func timestamp(unixTimestamp: Double, style: TimestampStyle? = nil) -> String {
        timestamp(unixTimestamp: Int(unixTimestamp), style: style)
    }
    
    /// When used in a Discord message, shows up as a **localized** time.
    /// See ``TimestampStyle`` for examples.
    @inlinable
    public static func timestamp(unixTimestamp: Int, style: TimestampStyle? = nil) -> String {
        let style = style.map { ":\($0.rawValue)" } ?? ""
        return "<t:\(unixTimestamp)\(style)>"
    }
    
    /// Escapes the special characters in the text, for the specified channel type.
    @inlinable
    public static func escapingSpecialCharacters(_ text: String) -> String {
        text
            .replacingOccurrences(of: #"\"#, with: #"\\"#)
            .replacingOccurrences(of: #"|"#, with: #"\|"#) /// Makes invisible
            .replacingOccurrences(of: #">"#, with: #"\>"#) /// Quotes
            .replacingOccurrences(of: #"<"#, with: #"\<"#) /// `<::>` ids like custom emojis
            .replacingOccurrences(of: #"["#, with: #"\["#) /// Markdown link syntax (`[]()`)
            .replacingOccurrences(of: ###"#"###, with: ###"\#"###) /// For titles, e.g. `### Title`
            .replacingOccurrences(of: #"`"#, with: #"\`"#) /// Code blocks
            .replacingOccurrences(of: #"~"#, with: #"\~"#) /// Crosses words
            .replacingOccurrences(of: #"_"#, with: #"\_"#) /// Italic
            .replacingOccurrences(of: #"*"#, with: #"\*"#) /// Bold
            .replacingOccurrences(of: #":"#, with: #"\:"#) /// Emojis, e.g. `:thumbsup:`
    }
}
