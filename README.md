<p align="center">
    <img src="https://user-images.githubusercontent.com/54685446/201329617-9fd91ab0-35c2-42c2-8963-47b68c6a490a.png" alt="DiscordBM">
    <br>
    <a href="https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml">
        <img src="https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml/badge.svg" alt="Tests Badge">
    </a>
    <a href="https://codecov.io/gh/MahdiBM/DiscordBM">
        <img src="https://codecov.io/gh/MahdiBM/DiscordBM/branch/main/graph/badge.svg?token=P4DYX2FWYT" alt="Codecov">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.8%20/%205.7-brightgreen.svg" alt="Latest/Minimum Swift Version">
    </a>
</p>

<p align="center">
     🌟 Just a reminder that there is a 🌟 button up there if you liked this project 😅 🌟
</p>

## Notable Features
* Everything with async/await. Full integration with the latest Server-Side Swift packages.
* Access the full Discord API for bots, except Voice (for now).
* Connect to the Discord Gateway and receive all events easily.
* Send requests to the Discord API using library's Discord client.
* Hard-typed APIs. All Gateway events and API responses have their own type and can be decoded easily.
* Abstractions for easier testability.

## Showcase
You can see Vapor community's Penny bot as a showcase of using this library in production. Penny's primary purpose is to give coins to the helpful members of the Vapor community. She also pings members for their specified keywords (similar to Slackbot), and notifies everyone of Swift's evolution and proposals.     
Penny is available [here](https://github.com/vapor/penny-bot) and you can find `DiscordBM` used in the [PennyBOT](https://github.com/vapor/penny-bot/tree/main/CODE/Sources/PennyBOT) target.

## How To Use
  
> Make sure you have **Xcode 14.1 or above**. Lower Xcode 14 versions have known issues that cause problems for libraries.    

### Initializing a Gateway Manager

First you need to initialize a `BotGatewayManager` instance, then tell it to connect and start using it.   

Make sure you've added [AsyncHTTPClient](https://github.com/swift-server/async-http-client) to your dependancies.
```swift
import DiscordBM
import AsyncHTTPClient

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

let bot = await BotGatewayManager(
    eventLoopGroup: httpClient.eventLoopGroup,
    httpClient: httpClient,
    token: <#Your Bot Token#>,
    presence: .init( /// Set up bot's initial presence
        /// Will show up as "Playing Fortnite"
        activities: [.init(name: "Fortnite", type: .game)], 
        status: .online,
        afk: false
    ),
    /// Add all the intents you want
    intents: [.guildMessages, .messageContent]
)
```
See the [GatewayConnection tests](https://github.com/MahdiBM/DiscordBM/blob/main/Tests/IntegrationTests/GatwayConnection.swift) or [Vapor community's Penny bot](https://github.com/vapor/penny-bot/blob/main/CODE/Sources/PennyBOT/Bot.swift) for real-world examples.

> **Warning**   
> In a production app you should use **environment variables** to load your Bot Token.   
> Avoid hard-coding your Bot Token to reduce the chances of leaking it.   

### Initializing a Gateway Manager With Vapor
<details>
  <summary> Click to expand </summary>
  
```swift
import DiscordBM
import Vapor

let app: Application = <#Your Vapor Application#>
let bot = await BotGatewayManager(
    eventLoopGroup: app.eventLoopGroup,
    httpClient: app.http.client.shared,
    token: <#Your Bot Token#>,
    presence: .init( /// Set up bot's initial presence
        /// Will show up as "Playing Fortnite"
        activities: [.init(name: "Fortnite", type: .game)],
        status: .online,
        afk: false
    ),
    /// Add all the intents you want
    intents: [.guildMessages, .messageContent]
)
```

</details>

### Using The Gateway Manager
> **Note**  
> For your app's entry point, you should use a type with the [`@main` attribute](https://www.hackingwithswift.com/swift/5.3/atmain) like below.    
```swift
@main
struct EntryPoint {
    static func main() async throws {
        /// Make an instance like above
        let bot: BotGatewayManager = <#GatewayManager You Made In Previous Steps#>

        /// Tell the manager to connect to Discord. Use a `Task { }` because it
        /// might take a few seconds, or even minutes under bad network connections
        /// Don't use `Task { }` if you care and want to wait
        Task { await bot.connect() }

        /// Get an `AsyncStream` of `Gateway.Event`s
        let stream = await bot.makeEventsStream()

        /// Handle each event in the stream
        /// This stream will never end, therefore preventing your executable from exiting
        for await event in stream {
            EventHandler(event: event, client: bot.client).handle()
        }
    }
}

/// To keep things cleaner, use a type conforming to 
/// `GatewayEventHandler` to handle your Gateway events.
struct EventHandler: GatewayEventHandler {
    let event: Gateway.Event
    let client: any DiscordClient

    /// Each Gateway payload has its own function. 
    /// See `GatewayEventHandler` for the full list.
    /// This function will only be called upon receiving `MESSAGE_CREATE` events.
    func onMessageCreate(_ payload: Gateway.MessageCreate) async {
        print("NEW MESSAGE!", payload)

        do {
            /// Use `client` to send requests to Discord
            let response = try await client.createMessage(
                channelId: payload.channel_id,
                payload: .init(content: "Got a message: '\(payload.content)'")
            )
            
            /// Easily decode the response to the correct type
            /// `message` will be of type `DiscordChannel.Message`.
            let message = try response.decode()
        } catch {
            print("We got an error! \(error)")
        }
    }
}
```
> **Note**   
> On a successful connection, you will **always** see a `NOTICE` log indicating `connection is established`.   

> **Note**   
> By default, `DiscordBM` automatically handles HTTP rate-limits and you don't need to worry about them.

### Mindset
The way you can make sense of the library is to think of it as a direct implementation of the Discord API.   
In most cases, the library doesn't try to abstract away Discord's stuff.   

* If something is related to the Gateway, you should find it near `GatewayManager`. 
* If there is a HTTP request you want to make, you'll need to use `DiscordClient`.
* You should read Discord documentation's related notes when you want to use something of this library.   
  Everything in the library has its related Discord documentation section linked near it.
  
> **Warning**   
> `DiscordBM` is still in beta so new releases can come with breaking changes.   
> [**Read the release notes**](https://github.com/MahdiBM/DiscordBM/releases) to fix the breaking changes that you encounter and become aware of new features.

### Bot Token And App ID
<details>
  <summary> Click to expand </summary>
  
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](https://user-images.githubusercontent.com/54685446/200565393-ea31c2ad-fd3a-44a1-9789-89460ab5d1a9.png)

</details>

### Sending Attachments
<details>
  <summary> Click to expand </summary>
  
`DiscordBM` has support for sending files as attachments.   
> **Note**   
> It's usually better to send a link of your media to Discord, instead of sending the actual file.   
```swift
Task {
    /// Raw data of anything like an image
    let image: ByteBuffer = <#Your Image Buffer#>
    
    /// Example 1
    try await bot.client.createMessage(
        channelId: <#Channel ID#>,
        payload: .init(
            content: "A message with an attachment!",
            files: [.init(data: image, filename: "pic.png")],
            attachments: [.init(index: 0, description: "Picture of something secret :)")]
            ///                 ~~~~~~~^ `0` is the index of the attachment in the `files` array.
        )
    )
    
    /// Example 2
    try await bot.client.createMessage(
        channelId: <#Channel ID#>,
        payload: .init(
            embeds: [.init(
                title: "An embed with an attachment!",
                image: .init(url: .attachment(name: "penguin.png"))
                ///                          ~~~~~~~^ `penguin.png` is the name of the attachment in the `files` array.   
            )],
            files: [.init(data: image, filename: "penguin.png")]
        )
     )
}
```
Take a look at `testMultipartPayload()` in [/Tests/DiscordClientTests](https://github.com/MahdiBM/DiscordBM/blob/main/Tests/IntegrationTests/DiscordClient.swift) to see how you can send media in a real-world situation.

</details>

### Discord Utils
<details>
  <summary> Click to expand </summary>

`DiscordBM` contains some utility functions for working with Discord's text-message format.   

The mention helpers:
```swift
let userMention = DiscordUtils.mention(id: <#User ID of type UserSnowflake#>)
let channelMention = DiscordUtils.mention(id: <#Channel ID of type ChannelSnowflake#>)
let roleMention = DiscordUtils.mention(id: <#Role ID of type RoleSnowflake#>)
let slashCommandMention = DiscordUtils.slashCommand(name: "help", id: <#Command ID#>)

/// Then:

/// Will look like `Hi @UserName!` in Discord
let userMessage = "Hi \(userMention)!"

/// Will look like `Welcome to #ChannelName!` in Discord
let channelMessage = "Welcome to \(channelMention)!"

/// Will look like `Hello @RoleName!` in Discord
let roleMessage = "Hello \(roleMention)!"

/// Will look like `Use this command: /help` in Discord
let slashCommandMeessage = "Use this command: \(slashCommandMention)"
```

And the emoji helpers:
```swift
let emoji = DiscordUtils.customEmoji(name: "Peepo_Happy", id: <#Emoji ID#>)
let animatedEmoji = DiscordUtils.customAnimatedEmoji(name: "Peepo_Money", id: <#Emoji ID#>)

/// Then:

/// Will look like `Are you happy now? EMOJI` where emoji is like https://cdn.discordapp.com/emojis/832181382595870730.webp
let emojiMessage = "Are you happy now? \(emoji)"

/// Will look like `Here comes the moneeeey EMOJI` where emoji is like https://cdn.discordapp.com/emojis/836533376285671424.gif
let animatedEmojiMessage = "Here comes the moneeeey \(emojiMessage)"
```

Plus the **end-user-localized** timestamp helpers:
```swift
let timestamp = DiscordUtils.timestamp(date: Date())
let anotherTimestamp = DiscordUtils.timestamp(unixTimestamp: 1 << 31, style: .relativeTime)

/// Then:

/// Will look like `Time when message was sent: 20 April 2021 16:20` in Discord
let timestampMessage = "Time when message was sent: \(timestamp)"

/// Will look like `I'm a time traveler. I will be born: in 15 years` in Discord
let anotherTimestampMessage = "I'm a time traveler. I will be born: \(anotherTimestamp)"
```

And a function to escape special characters from user input.    
For example if you type `**BOLD TEXT**` in Discord, it'll look like **BOLD TEXT**, but using this function, it'll instead look like the original `**BOLD TEXT**` input.
```swift
let escaped = DiscordUtils.escapingSpecialCharacters("**BOLD TEXT**")

/// Will look like `Does this look bold to you?! **BOLD TEXT**` in Discord. Won't actually look bold.
let escapedMessage = "Does this look bold to you?! \(escaped)"
```
</details>

### Discord Logger
<details>
  <summary> Click to expand </summary>

`DiscordBM` comes with a `LogHandler` which can send all your logs to Discord:
```swift
import DiscordLogger
import Logging

/// Configure the Discord Logging Manager.
DiscordGlobalConfiguration.logManager = await DiscordLogManager(
    httpClient: <#HTTPClient You Made In Previous Steps#>
)

/// Bootstrap the `LoggingSystem`. After this, all your `Logger`s will automagically start using `DiscordLogHandler`.
/// Do not use a `Task { }`. Wait before the `LoggingSystem` is bootstrapped.  
await LoggingSystem.bootstrapWithDiscordLogger(
    /// The address to send the logs to. 
    /// You can easily create a webhook using Discord client apps.
    address: try .url(<#Your Webhook URL#>),
    makeMainLogHandler: StreamLogHandler.standardOutput(label:metadataProvider:)
)

/// Make sure you haven't called `LoggingSystem.bootstrap` anywhere else, because you can only call it once.
/// For example Vapor's templates use `LoggingSystem.bootstrap` on boot, and you need to remove that.
```
`DiscordLogManager` comes with a ton of useful configuration options.   
Here is an example of a decently-configured `DiscordLogManager`:   
Read `DiscordLogManager.Configuration.init` documentation for full info.

```swift
DiscordGlobalConfiguration.logManager = await DiscordLogManager(
    httpClient: <#HTTPClient You Made In Previous Steps#>,
    configuration: .init(
        aliveNotice: .init(
            address: try .url(<#Your Webhook URL#>),
            /// If nil, DiscordLogger will only send 1 "I'm alive" notice, on boot.
            /// If not nil, it will send a "I'm alive" notice every this-amount too. 
            interval: nil,
            message: "I'm Alive! :)",
            color: .blue,
            initialNoticeMention: .user("970723029262942248")
        ),
        mentions: [
            .warning: .role("970723134149918800"),
            .error: .role("970723101044244510"),
            .critical: .role("970723029262942248"),
        ],
        extraMetadata: [.warning, .error, .critical],
        disabledLogLevels: [.debug, .trace], 
        disabledInDebug: true
    )
)
```
If you want to only use Discord logger and don't use the rest of `DiscordBM`, you can specify `DiscordLogger` as your dependency:
```swift
/// In `Package.swift`:
.product(name: "DiscordLogger", package: "DiscordBM"),
```

#### Example

```swift
/// After bootstrapping the `LoggingSystem`, and with the configuration above, but `extraMetadata` set to `[.critical]`
let logger = Logger(label: "LoggerLabel")
logger.warning("Warning you about something!")
logger.error("We're having an error!", metadata: [
    "number": .stringConvertible(1),
    "statusCode": "401 Unauthorized"
])
logger.critical("CRITICAL PROBLEM. ABOUT TO EXPLODE 💥")
```

<img width="370" alt="DiscordLogger Showcase Output" src="https://user-images.githubusercontent.com/54685446/217464224-1cb6ed75-8683-4977-8bd3-03752d7d7597.png">

</details>

### Discord Cache
<details>
  <summary> Click to expand </summary>

`DiscordBM` has the ability to cache Gateway events in-memory, and keep the data in sync with Discord:
```swift
let cache = await DiscordCache(
    /// The `GatewayManager`/`bot` to cache the events from. 
    gatewayManager: <#GatewayManager You Made In Previous Steps#>,
    /// What intents to cache their related Gateway events. 
    /// This does not affect what events you receive from Discord.
    /// The intents you enter here must have been enabled in your `GatewayManager`.
    /// With `.all`, `DiscordCache` will cache all events.
    intents: [.guilds, .guildMembers],
    /// In big guilds/servers, Discord only sends your own member/presence info.
    /// You need to request the rest of the members, and `DiscordCache` can do that for you.
    /// Must have `guildMembers` and `guildPresences` intents enabled depending on what you want.
    requestAllMembers: .enabled,
    /// What messages to cache.
    messageCachingPolicy: .saveEditHistoryAndDeleted
)

/// Access the cached stuff:
if let aGuild = await cache.guilds[<#Guild ID#>] {
    print("Guild name is:", aGuild.name)
} else {
    print("Guild not found")
}
```
  
</details>

### Checking Permissions & Roles
<details>
  <summary> Click to expand </summary>

`DiscordBM` has some best-effort functions for checking permissions and roles.   
FYI, in interactions, the [member field](https://discord.com/developers/docs/resources/guild#guild-member-object-guild-member-structure) already contains the resolved permissions (`Interaction.member.permissions`).

> **Warning**   
> You need a `DiscordCache` with intents containing `.guilds` & `.guildMembers` and also `requestAllMembers: .enabled`.   

```swift
let cache: DiscordCache = <#DiscordCache You Made In Previous Steps#>

/// Get the guild.
guard let guild = await cache.guilds[<#Guild ID#>] else { return }

/// Check if the user has `.viewChannel` & `.readMessageHistory` permissions in a channel.
let hasPermission = guild.userHasPermissions(
    userId: <#User ID#>,
    channelId: <#Channel ID#>, 
    permissions: [.viewChannel, .readMessageHistory]
)

/// Check if a user has the `.banMembers` guild-wide permission.
let hasGuildPermission = guild.userHasGuildPermission(
    userId: <#User ID#>,
    permission: .banMembers
)

/// Check if a user has a role.
let hasRole = guild.userHasRole(
    userId: <#User ID#>,
    roleId: <#Role ID#>
)
```

</details>

### React-To-Role
<details>
  <summary> Click to expand </summary>
  
`DiscordBM` can automatically assign a role to members when they react to a message with specific emojis:

```swift
let handler = try await ReactToRoleHandler(
    gatewayManager: <#GatewayManager You Made In Previous Steps#>,
    /// Your DiscordCache. This is not necessary (you can pass `nil`)
    /// Only helpful if the cache has `guilds` and/or `guildMembers` intents enabled
    cache: cache,
    /// The role-creation payload
    role: .init(
        name: "cool-gang",
        color: .green
    ),
    guildId: <#Guild ID of The Message You Created#>,
    channelId: <#Channel ID of The Message You Created#>,
    messageId: <#Message ID of The Message You Created#>,
    /// The list of reactions to get the role for
    reactions: [.unicodeEmoji("🐔")]
)
```

After this, anyone reacting with `🐔` to the message will be assigned the role.   
There are a bunch more options, take a look at `ReactToRoleHandler` initializers for more info.

> **Warning**   
> The handler will need quite a few permissions. Namely `view messages`, `send messages` & `add reactions` in the channel where the message is, plus `manage roles` in the guild. These are only the minimums. If the bot is receiving 403 responses from Discord, it probably needs some more permissions as well.

#### Behavior
The handler will:
* Verify the message exists at all, and throws an error in the initializer if not.
* React to the message as the bot-user with all the reactions you specified.
* Re-create the role if it's removed or doesn't exist.
* Stop working if you use `await handler.stop()`.
* Re-start working again if you use `try await handler.restart()`.

#### Persistence 
If you need to persist the handler somewhere:
* You only need to persist handler's `configuration`, which is `Codable`.
* You need to update the configuration you saved, whenever it's changed.   
  To become notified of configuration changes, you should use the `onConfigurationChanged` parameter in initializers:

```swift
let handler = try await ReactToRoleHandler(
    .
    .
    .
    onConfigurationChanged: { configuration in 
        await saveToDatabase(configuration: configuration)
    }
)
```
  
</details>

## Testability
<details>
  <summary> Click to expand </summary>

`DiscordBM` comes with tools to make testing your app easier.   
* You can type-erase your `BotGatewayManager`s using the `GatewayManager` protocol so you can override your gateway manager with a mocked implementation in tests.   
* You can also do the same for `DefaultDiscordClient` and type-erase it using the `DiscordClient` protocol so you can provide a mocked implementation when testing.

</details>

## How To Add DiscordBM To Your Project

To use the `DiscordBM` library in a SwiftPM project, 
add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/MahdiBM/DiscordBM", from: "1.0.0-beta.1"),
```

Include `DiscordBM` as a dependency for your targets:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "DiscordBM", package: "DiscordBM"),
]),
```

Finally, add `import DiscordBM` to your source code.

## Versioning
`DiscordBM` will try to follow Semantic Versioning 2.0.0, with exceptions.     
To keep `DiscordBM` up to date with Discord API's frequent changes, `DiscordBM` will **add** any new properties to any types in **minor** versions, even if it's technically a breaking change.   
This includes adding new cases to enums. If you want to try to avoid breaking changes, make sure you have a `default` case in your `switch` statements or use `if case let`/`if case`.

## Contribution & Support
Any contribution is more than welcome. You can find me in [Vapor's Discord server](https://discord.com/invite/vapor) to discuss your ideas.    
If there is missing/upcoming feature, you can make an issue/PR for it with a link to the related Discord docs page or the related issue/PR in [Discord docs repository](https://github.com/discord/discord-api-docs).   
Passing the `linux-integration` tests is not required for PRs because of token/access problems.
