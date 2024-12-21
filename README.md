<p align="center">
    <img src="https://user-images.githubusercontent.com/54685446/201329617-9fd91ab0-35c2-42c2-8963-47b68c6a490a.png" alt="DiscordBM">
    <br>
    <a href="https://www.swift.org/sswg/">
        <img src="https://img.shields.io/badge/sswg-sandbox-lightgrey.svg" alt="SSWG Incubation Status: Sandbox">
    </a>
    <a href="https://discord.gg/kxfs5n7HVE">
        <img src="https://dcbadge.vercel.app/api/server/kxfs5n7HVE?style=flat" alt="DiscordBM Server">
    </a>
    <a href="https://github.com/DiscordBM/DiscordBM/actions/workflows/tests.yml">
        <img src="https://github.com/DiscordBM/DiscordBM/actions/workflows/tests.yml/badge.svg" alt="Tests Badge">
    </a>
    <a href="https://github.com/DiscordBM/DiscordBM/actions/workflows/integration-tests.yml">
        <img src="https://github.com/DiscordBM/DiscordBM/actions/workflows/integration-tests.yml/badge.svg" alt="Integration Tests Badge">
    <a href="https://github.com/DiscordBM/DiscordBM">
        <img src="https://img.shields.io/badge/dynamic/json?url=https://rapi.mahdibm.com/v1/loc/DiscordBM/count&query=$.count&label=Swift%20lines" alt="Swift lines of code">
    </a>
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-6.0%20%2F%205.10-brightgreen.svg" alt="Latest/Minimum Swift Version">
    </a>
</p>

## Notable Features
* Everything with async/await. Full integration with the latest Server-Side Swift packages.
* Access the full Discord API for bots, except Voice (for now).
* Connect to the Discord Gateway and receive all events easily.
* Send requests to the Discord API using library's Discord client.
* Hard-typed APIs. All Gateway events and API responses have their own type and can be decoded easily.
* Abstractions for easier testability.

## Showcase
Vapor community's [Penny bot](https://github.com/vapor/penny-bot) serves as a good example of [utilizing this library](https://github.com/vapor/penny-bot/blob/main/Sources/Penny/Services/DiscordService/DiscordService.swift#L1).  
Unfortunately Penny isn't a good project to study how to use `DiscordBM`, due to its complexity. For now, this README is your best friend.

## How To Use

### Initializing a Gateway Manager

First you need to initialize a `BotGatewayManager` instance, then tell it to connect and start using it.   

```swift
import DiscordBM

let bot = await BotGatewayManager(
    token: <#Your Bot Token#>,
    presence: .init( /// Set up bot's initial presence
        /// Will show up as "Playing Fortnite"
        activities: [.init(name: "Fortnite", type: .game)], 
        status: .online,
        afk: false
    ),
    /// Add all the intents you want
    /// You can also use `Gateway.Intent.unprivileged` or `Gateway.Intent.allCases`
    intents: [.guildMessages, .messageContent]
)
```
See the [GatewayConnection tests](https://github.com/DiscordBM/DiscordBM/blob/main/Tests/IntegrationTests/GatwayConnection.swift) or [Vapor community's Penny bot](https://github.com/vapor/penny-bot/blob/main/Sources/Penny/MainService/PennyService.swift) for real-world examples.

> [!Warning]   
> In a production app you should use [**environment variables**](https://swiftonserver.com/using-environment-variables-in-swift/) to load your Bot Token.   
> Avoid hard-coding your Bot Token to reduce the chances of leaking it.   

### Initializing a Gateway Manager With Vapor
<details>
  <summary> Click to expand </summary>

With Vapor, use Vapor `Application`'s `EventLoopGroup` and `HTTPClient`:
```swift
import DiscordBM
import Vapor

let app: Application = <#Your Vapor Application#>
let bot = await BotGatewayManager(
    eventLoopGroup: app.eventLoopGroup, /// Use Vapor's `EventLoopGroup`
    httpClient: app.http.client.shared, /// Use Vapor's `HTTPClient`
    token: <#Your Bot Token#>,
    presence: .init( /// Set up bot's initial presence
        /// Will show up as "Playing Fortnite"
        activities: [.init(name: "Fortnite", type: .game)],
        status: .online,
        afk: false
    ),
    /// Add all the intents you want
    /// You can also use `Gateway.Intent.unprivileged` or `Gateway.Intent.allCases`
    intents: [.guildMessages, .messageContent]
)
```

</details>

### Using The Gateway Manager
> [!Note] 
> For your app's entry point, you should use a type with the [`@main` attribute](https://www.hackingwithswift.com/swift/5.3/atmain) like below.    
```swift
@main
struct EntryPoint {
    static func main() async throws {
        /// Make an instance like above
        let bot: BotGatewayManager = <#GatewayManager You Made In Previous Steps#>

        /// You can also wrap this task-group in the `run()` function of a `Service`, if you're using `ServiceLifecycle`:
        /// https://swiftpackageindex.com/swift-server/swift-service-lifecycle/main/documentation/servicelifecycle
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                await bot.connect()
            }

            taskGroup.addTask {
                /// Handle each event in the `bot.events` async stream
                /// This stream will never end, therefore preventing your executable from exiting
                for await event in await bot.events {
                    /// You can move the above `taskGroup.addTask {` to down here, for more concurrency.
                    await EventHandler(event: event, client: bot.client).handleAsync()
                }
            }
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
    func onMessageCreate(_ payload: Gateway.MessageCreate) async throws {
        print("NEW MESSAGE!", payload)

        /// Use `client` to send requests to Discord
        let response = try await client.createMessage(
            channelId: payload.channel_id,
            payload: .init(content: "Got a message: '\(payload.content)'")
        )
            
        /// Easily decode the response to the correct type
        /// `message` will be of type `DiscordChannel.Message`.
        let message = try response.decode()
    }
}
```
> [!Note]  
> On a successful connection, you will **always** see a `NOTICE` log indicating `connection is established`.   

> [!Note]  
> By default, `DiscordBM` automatically handles HTTP rate-limits and you don't need to worry about them.

### Mindset
The way you can make sense of the library is to think of it as a direct implementation of the Discord API.   
In most cases, the library doesn't try to abstract away Discord's stuff.   

* If something is related to the Gateway, you should find it near `GatewayManager`. 
* If there is a HTTP request you want to make, you'll need to use `DiscordClient`.
* You should read Discord documentation's related notes when you want to use something of this library.   
  Everything in the library has its related Discord documentation section linked near it.

### Finding Your Bot Token
<details>
  <summary> Click to expand </summary>
  
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](https://user-images.githubusercontent.com/54685446/200565393-ea31c2ad-fd3a-44a1-9789-89460ab5d1a9.png)

</details>

### Application (including Slash) Commands

<details>
  <summary> Click to expand </summary>

`DiscordBM` comes with full support for all kinds of "interactions" such as slash commands, modals, autocomplete etc... and gives you full control over how you want to use them using type-safe APIs.    
> You can see Penny as an example of using all kinds of commands in production.    
Penny registers the commands [here](https://github.com/vapor/penny-bot/blob/main/Sources/Penny/CommandsManager.swift) and responds to them [here](https://github.com/vapor/penny-bot/blob/main/Sources/Penny/Handlers/InteractionHandler.swift).   

In this example you'll only make 2 simple slash commands, so you can get started:   

In your `EntryPoint.main()`:
```swift
/// Make a list of `Payloads.ApplicationCommandCreate`s that you want to register
/// `DiscordCommand` is an enum that has the full info of your commands. See below
let commands = DiscordCommand.allCases.map { command in
    return Payloads.ApplicationCommandCreate(
        name: command.rawValue,
        description: command.description,
        options: command.options
    )
}

/// You only need to do this once on startup. This updates all your commands to the new ones.
try await bot.client
    .bulkSetApplicationCommands(payload: commands)
    .guardSuccess() /// Throw an error if not successful

/// Use the events-stream later since the for-loop blocks the function
for await event in await bot.events {
    await EventHandler(event: event, client: bot.client).handleAsync()
}
```
In your `EventHandler`:
```swift
/// Use `onInteractionCreate(_:)` for handling interactions.
struct EventHandler: GatewayEventHandler {
    let event: Gateway.Event
    let client: any DiscordClient
    let logger = Logger(label: "EventHandler")

    /// Handle Interactions.
    func onInteractionCreate(_ interaction: Interaction) async throws {
        /// You only have 3 second to respond, so it's better to send
        /// the response right away, and edit the response later.
        /// This will show a loading indicator to users.
        try await client.createInteractionResponse(
            id: interaction.id,
            token: interaction.token,
            payload: .deferredChannelMessageWithSource()
        ).guardSuccess()

        /// Delete this if you want. Just here so you notice the loading indicator :)
        try await Task.sleep(for: .seconds(1))

        /// Handle the interaction data
        switch interaction.data {
        case let .applicationCommand(applicationCommand):
            switch DiscordCommand(rawValue: applicationCommand.name) {
            case .echo:
                if let echo = applicationCommand.option(named: "text")?.value?.asString {
                    /// Edits the interaction response.
                    /// This response is intentionally too fancy just so you see what's possible :)
                    try await client.updateOriginalInteractionResponse(
                        token: interaction.token,
                        payload: Payloads.EditWebhookMessage(
                            content: "Hello, You wanted me to echo something!",
                            embeds: [Embed(
                                title: "This is an embed",
                                description: """
                                    You sent this, so I'll echo it to you!

                                    > \(DiscordUtils.escapingSpecialCharacters(echo))
                                    """,
                                timestamp: Date(),
                                color: .init(value: .random(in: 0 ..< (1 << 24) )),
                                footer: .init(text: "Footer!"),
                                author: .init(name: "Authored by DiscordBM!"),
                                fields: [
                                    .init(name: "field name!", value: "field value!")
                                ]
                            )],
                            components: [[.button(.init(
                                label: "Open DiscordBM!",
                                url: "https://github.com/DiscordBM/DiscordBM"
                            ))]]
                        )
                    ).guardSuccess()
                } else {
                    try await client.updateOriginalInteractionResponse(
                        token: interaction.token,
                        payload: Payloads.EditWebhookMessage(
                            content: "Hello, You wanted me to echo something!",
                            embeds: [Embed(
                                title: "This is an embed",
                                description: """
                                    You sent this, so I'll echo it to you but there was nothing!
                                    """,
                                timestamp: Date().addingTimeInterval(90),
                                color: .green,
                                footer: .init(text: "Footer!"),
                                author: .init(name: "Authored by DiscordBM!"),
                                fields: [
                                    .init(name: "field name!", value: "field value!")
                                ]
                            )]
                        )
                    ).guardSuccess()
                }
            case .link:
                /// `DiscordBM` has some "require" functions for easier unwrapping of
                /// application commands. These "require" functions will either give you
                /// what you want, or throw an error.
                /// See the full list below.
                let subcommandOption = try (applicationCommand.options?.first).requireValue()
                let subcommandName = subcommandOption.name
                let subcommand = try LinkSubCommand(rawValue: subcommandName).requireValue()

                let id = try (subcommandOption.options?.first).requireValue().requireString()
                let name = subcommand.rawValue.capitalized

                try await client.updateOriginalInteractionResponse(
                    token: interaction.token,
                    payload: Payloads.EditWebhookMessage(
                        content: "Hi, did you wanted me to link your accounts?",
                        embeds: [.init(
                            description: "Will link a \(name) account with id '\(id)'",
                            color: .yellow
                        )]
                    )
                ).guardSuccess()
            case .none: break
            }
        default: break
        }
    }
}
```
In a new file like `DiscordCommand.swift`, to keep things organized: 
```swift
// MARK: - Define a nice clean enum for your commands
enum DiscordCommand: String, CaseIterable {
    case echo
    case link

    /// The description of the command that Discord users will see.
    var description: String? {
        switch self {
        case .echo:
            return "Echos what you say"
        case .link:
            return "Links your accounts "
        }
    }

    /// The options of the command that Discord users will have.
    var options: [ApplicationCommand.Option]? {
        switch self {
        case .echo:
            return [ApplicationCommand.Option(
                type: .string,
                name: "text",
                description: "What to echo :)"
            )]
        case .link:
            return LinkSubCommand.allCases.map { subCommand in
                return ApplicationCommand.Option(
                    type: .subCommand,
                    name: subCommand.rawValue,
                    description: subCommand.description,
                    options: subCommand.options
                )
            }
        }
    }
}

// MARK: - You can use enums for subcommands too 
enum LinkSubCommand: String, CaseIterable {
    case discord
    case github

    /// The description of the subcommand that Discord users will see.
    var description: String {
        switch self {
        case .discord:
            return "Link your Discord account"
        case .github:
            return "Link your Github account"
        }
    }

    /// The options of the subcommand that Discord users will have.
    var options: [ApplicationCommand.Option] {
        switch self {
        case .discord: return [ApplicationCommand.Option(
            type: .string,
            name: "id",
            description: "Your Discord account ID",
            required: true
        )]
        case .github: return [ApplicationCommand.Option(
            type: .string,
            name: "id",
            description: "Your Github account ID",
            required: true
        )]
        }
    }
}
```

#### Interaction Parsing Helpers
* `StringIntDoubleBool` has:
  * `requireString() throws -> String`
  * `requireInt() throws -> Int`
  * `requireDouble() throws -> Double`
  * `requireBool() throws -> Bool`
* `Interaction.ApplicationCommand.Option` has all the `StringIntDoubleBool` functions for unwrapping an option's `value` .
* `Interaction.ApplicationCommand.Option` and related types (like `[Option]`) have:
  * `option(named: String) -> Option?`
  * `requireOption(named: String) throws -> Option`
* `[Interaction.ActionRow]` and `[Interaction.ActionRow.Component]` have:
  * `component(customId: String) -> Interaction.ActionRow.Component?`
  * `requireComponent(customId: String) throws -> Interaction.ActionRow.Component`
* `Interaction.ActionRow.Component` has:
  * `requireButton() throws -> Button`
  * `requireStringSelect() throws -> StringSelectMenu`
  * `requireTextInput() throws -> TextInput`
  * `requireUserSelect() throws -> SelectMenu`
  * `requireRoleSelect() throws -> SelectMenu`
  * `requireMentionableSelect() throws -> SelectMenu`
  * `requireChannelSelect() throws -> ChannelSelectMenu`
* `Interaction.Data` has:
  * `requireApplicationCommand() throws -> ApplicationCommand`
  * `requireMessageComponent() throws -> MessageComponent`
  * `requireModalSubmit() throws -> ModalSubmit`
* Swift's `Optional` has a `requireValue() throws` function overload (only in `DiscordBM`).                                             

</details>

### Sending Attachments
<details>
  <summary> Click to expand </summary>
  
`DiscordBM` has support for sending files as attachments.   

> It's usually better to send a link to your media to Discord, instead of sending the actual file everytime.   

```swift
/// Raw data of anything like an image
let image: ByteBuffer = <#Your Image Buffer#>

/// Example 1
try await bot.client.createMessage(
    channelId: <#Channel ID#>,
    payload: .init(
        content: "A message with an attachment!",
        files: [.init(data: image, filename: "pic.png")],
        attachments: [.init(index: 0, description: "Picture of something secret :)")]
        ///                 ~~~~~~~^
        /// `0` is the index of the attachment in the `files` array.
    )
)

/// Example 2
try await bot.client.createMessage(
    channelId: <#Channel ID#>,
    payload: .init(
        embeds: [.init(
            title: "An embed with an attachment!",
            image: .init(url: .attachment(name: "penguin.png"))
            ///                          ~~~~~~~^ 
            /// `penguin.png` is the name of the attachment in the `files` array.   
        )],
        files: [.init(data: image, filename: "penguin.png")]
    )
)
```
Take a look at `testMultipartPayload()` in [/Tests/DiscordClientTests](https://github.com/DiscordBM/DiscordBM/blob/main/Tests/IntegrationTests/DiscordClient.swift) to see how you can send media in a real-world situation.

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
let slashCommandMessage = "Use this command: \(slashCommandMention)"
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

### Sharding
<details>
  <summary> Click to expand </summary>

Sharding is a way of splitting up your bot's load accross different `GatewayManager`s. It is useful if:
* You want to implement zero-down-time scaling/updating.
* You have too many guilds to be handeled by just 1 `GatewayManager`.

> Discord says sharding is required for bots with 2500 and more guilds. For more info, refer to the [Discord docs](https://discord.com/developers/docs/topics/gateway#sharding)

To enable sharding, simply replace your `BotGatewayManager` with `ShardingGatewayManager`:
```swift
let bot = await ShardingGatewayManager(
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
    /// You can also use `Gateway.Intent.unprivileged` or `Gateway.Intent.allCases`
    intents: [.guildMessages, .messageContent]
)
```
And that's it! You've already enabled sharding. `DiscordBM` will create as many `BotGatewayManager`s as Discord suggests under the hood of `ShardingGatewayManager`, and will automatically handle them. 

> `ShardingGatewayManager` might still only create 1 `BotGatewayManager` if that's what Discord suggests.

`ShardingGatewayManager` takes a few more options than `BotGatewayManager` to customize how you want to perform sharding:
```swift
let bot: any GatewayManager = await ShardingGatewayManager(
    eventLoopGroup: httpClient.eventLoopGroup,
    httpClient: httpClient,
    configuration: .init(
        /// You can request an exact amount of shard counts using `.exact(<number>)`.
        /// Defaults to `.automatic` which means it will ask Discord for a suggestion of how many shards to spin up.
        shardCount: .exact(<#number#>),
        /// This is an opportunity to customize what shard takes care of which intents.
        /// By default, all intents are passed to all shards.
        makeIntents: { (indexOfShard: Int, totalShardCount: Int) -> [Gateway.Intent] in
            /// return a value of type `[Gateway.Intent]` based on `indexOfShard` and `totalShardCount`.
        }
    ),
    ...
)
```
</details>

## Related Projects

### Discord Logger

<details>
  <summary> Click to expand </summary>

`DiscordLogger` enables you to send your logs to Discord with beautiful formatting and a lot of customization options.
Read more about it at https://github.com/DiscordBM/DiscordLogger.

</details>

### React-To-Role
<details>
  <summary> Click to expand </summary>

React-To-Role helps you assign roles to members when they react to a message.
Read more about it at https://github.com/DiscordBM/DiscordReactToRole.

</details>

## Testability
<details>
  <summary> Click to expand </summary>

`DiscordBM` comes with tools to make testing your app easier.   
* You can type-erase your `BotGatewayManager`s using the `GatewayManager` protocol so you can override your gateway manager with a mocked implementation in tests.   
* You can also do the same for `DefaultDiscordClient` and type-erase it using the `DiscordClient` protocol so you can provide a mocked implementation when testing.

</details>

## Implementation Details

### Default Discord Client
<details>
  <summary> Click to expand </summary>

These are some general implementation detail notes about the `DefaultDiscordClient`.   
Generally, the `DefaultDiscordClient` will try to be as smart as possible with minimal compromise.

> I'll refer to `DefaultDiscordClient` as "DDC" to be more concise.

#### Rate Limits
`DiscordBM` comes with a `HTTPRateLimiter` type that keeps track of the `x-ratelimit` headers.    
This, in conjunction with `ClientConfiguration`'s `RetryPolicy`, helps `DiscordBM` to recover from what that can otherwise be a `429 Too Many Requests` error from Discord.   
The behavior specified below is enabled by default.

* Before each request, DDC will ask the rate-limiter if the headers allow a request.
* The rate-limiter will respond with `yes, you can`, `no, you can't` or `yes, but you must wait x seconds first, otherwise no`.
* If the response is `yes`, the DDC will continue performing the request.
* If the response is `no`, the DDC will throw a "rate-limited" error.
* If the response is `yes, but you must wait x seconds first, otherwise no`, then the DDC will look at the `retryPolicy` of its `configuration`.
* The DDC will act like there has been a `429` error, and will ask the `retryPolicy` if it's possible to retry such a failure, and under what circumstances.
* The `retryPolicy` may specify that `429` requests can be retried `basedOnHeaders` if not longer than `maxAllowed` seconds.
* The DDC will wait as long as `x seconds` which the rate-limiter specified, then will perform the request. This only happens if the `x seconds` is not longer than the `maxAllowed`.
* In any other cases other than specified above, the DDC will fail with a "rate-limited" error.

#### Concurrent Requests
`ClientConfiguration`s `CachingBehavior` has the ability to avoid multiple concurrent requests with the same "cacheable identity".   
* You can enable caching using DDC's `configuration.cachingBehavior` through the initializers by passing `cachingBehavior: .minimal`, `.enabled` or the `.custom` static functions.  
* As an example, if you have caching enabled for a cacheable endpoint, and you make 10 concurrent requests to the endpoint with the same parameters, the DDC will only perform 1 of those requests, and let the other 9 requests use the cached value. 

</details>

## How To Add DiscordBM To Your Project

To use the `DiscordBM` library in a SwiftPM project, 
add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/DiscordBM/DiscordBM", from: "1.0.0"),
```

Include `DiscordBM` as a dependency for your targets:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "DiscordBM", package: "DiscordBM"),
]),
```

Finally, add `import DiscordBM` to your source code.

## Versioning
`DiscordBM` will try to follow Semantic Versioning 2.0.0, with exceptions:    
* To keep `DiscordBM` up to date with Discord API's frequent changes, `DiscordBM` will **add** any new properties to any types in **minor** versions, even if it's technically a breaking change.   
* `DiscordBM` tries to minimize the effect of this requirement. For example most enums have an underscored case named `__undocumented` which asks users to use non-exhaustive switch statements, preventing future code-breakages.  

## Contribution & Support
* If you need help with anything, ask in [DiscordBM's Discord server](https://discord.gg/kxfs5n7HVE).
* Any contribution is more than welcome. You can find me in the server to discuss your ideas.    
* If there is missing/upcoming feature, you can make an issue/PR for it with a link to the related Discord docs page or the related issue/PR in [Discord docs repository](https://github.com/discord/discord-api-docs).   
* Passing the `linux-integration` tests is not required for PRs because of token/access problems.
