![DiscordBM](https://user-images.githubusercontent.com/54685446/201329617-9fd91ab0-35c2-42c2-8963-47b68c6a490a.png)

<p align="center">
	<a href="https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml">
        <img src="https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml/badge.svg" alt="Tests Badge">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.6%20/%205.7%20/%205.8-brightgreen.svg" alt="Minimum Swift Version">
    </a>
</p>

## Notable Features
* Everything with structured concurrency and async/await. Full integration with all the latest Server-Side Swift packages.
* Connect to the Discord gateway and receive all events easily.
* Send requests to the Discord API using library's Discord client.
* Hard-typed APIs. All Gateway events have their own type and all Discord API responses can be decoded easily.
* Abstractions for easier testability.

## Showcase
You can see Vapor community's Penny bot as a showcase of using this library in production. Penny is used to give coins to the helpful members of the Vapor community as a sign of appreciation.   
Penny is available [here](https://github.com/vapor/penny-bot) and you can find `DiscordBM` used in the [PennyBOT](https://github.com/vapor/penny-bot/tree/main/CODE/Sources/PennyBOT) target.

## How To Use
  
> If you're using `DiscordBM` on macOS Ventura (on either Xcode or VSCode), make sure you have **Xcode 14.1 or above**. Lower Xcode 14 versions have known issues that cause a lot of problems for libraries.    

### Initializing a Gateway Manager On Your Own

First you need to initialize a `BotGatewayManager` instance, then tell it to connect and start using it.   

Make sure you've added [AsyncHTTPClient](https://github.com/swift-server/async-http-client) to your dependancies.
```swift
import DiscordBM
import AsyncHTTPClient

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

let bot = BotGatewayManager(
    eventLoopGroup: httpClient.eventLoopGroup,
    httpClient: httpClient,
    token: YOUR_BOT_TOKEN,
    appId: YOUR_APP_ID,
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

### Initializing a Gateway Manager With Vapor
<details>
  <summary> Click to expand </summary>
  
```swift
import DiscordBM
import Vapor

let app: Application = YOUR_VAPOR_APPLICATION
let bot = BotGatewayManager(
    eventLoopGroup: app.eventLoopGroup,
    httpClient: app.http.client.shared,
    token: YOUR_BOT_TOKEN,
    appId: YOUR_APP_ID,
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
```swift
/// Make an instance like above
let bot: BotGatewayManager = ...

Task {
    /// Add event handlers
    await bot.addEventHandler { event in
        switch event.data {
        case let .messageCreate(message):
            print("GOT MESSAGE!", message)
            /// Switch over other cases you have intents for and you care about
        default: break
        }
    }
    
    /// Tell the manager to connect to Discord.
    /// FYI, This will return _before_ the connection is fully established
    await bot.connect()
    
    /// Use `bot.client` to send requests to Discord.
    try await bot.client.createMessage(
        channelId: CHANNEL_ID,
        payload: .init(content: "Hello Everybody!")
    )
}

/// If you don't use libraries like Vapor that do this for you, 
/// you'll need to uncomment this line and call it from a non-async context.
/// Otherwise your executable will exit immediately after every run.
/// RunLoop.current.run()
```

### Mindset
The way you can make sense of the library is to think of it as a direct implementation of the Discord API.   
In most cases, the library doesn't try to abstract away Discord's stuff.   

* If something is related to the Gateway, you should find it near `GatewayManager`. 
* If there is a HTTP request you want to make, you'll need to use `DiscordClient`.
* You should read Discord documentation's related notes when you want to use something of this library.   
  Everything in the library has its related Discord documentation section linked near it.

### Bot Token And App ID
<details>
  <summary> Click to expand </summary>
  
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](https://user-images.githubusercontent.com/54685446/200565393-ea31c2ad-fd3a-44a1-9789-89460ab5d1a9.png)
![Finding App ID](https://user-images.githubusercontent.com/54685446/200565475-9893d326-423e-4344-a853-9de2f9ed25b4.png)

</details>

### Sending Attachments
<details>
  <summary> Click to expand </summary>
  
It's usually better to send a link of your media to Discord, instead of sending the actual file.   
However, `DiscordBM` still supports sending files directly.   
```swift
Task {
    /// Raw data of anything like an image
    let image: ByteBuffer = ...
    
    /// Example 1
    try await bot.client.createMessage(
        channelId: CHANNEL_ID,
        payload: .init(
            content: "A message with an attachment!",
            files: [.init(data: image, filename: "pic.png")],
            attachments: [.init(index: 0, description: "Picture of something secret :)")]
            ///                 ~~~~~~~^ `0` is the index of the attachment in the `files` array.
        )
    )
    
    /// Example 2
    try await bot.client.createMessage(
        channelId: CHANNEL_ID,
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

### Discord Logger
<details>
  <summary> Click to expand </summary>

`DiscordBM` comes with a `LogHandler` which can send all your logs to Discord:
```swift
import DiscordLogger
import Logging

/// Configure the Discord Logging Manager.
DiscordGlobalConfiguration.logManager = DiscordLogManager(
    httpClient: HTTP_CLIENT_YOU_MADE_IN_PREVIOUS_STEPS
)

/// Bootstrap the `LoggingSystem`. After this, all your `Logger`s will automagically start using `DiscordLogHandler`.
/// Do not use a `Task { }`. Wait before the `LoggingSystem` is bootstrapped.  
await LoggingSystem.bootstrapWithDiscordLogger(
    /// The address to send the logs to. 
    /// You can easily create a webhook using Discord client apps.
    address: try .url(WEBHOOK_URL),
    makeMainLogHandler: StreamLogHandler.standardOutput(label:metadataProvider:)
)

/// Make sure you haven't called `LoggingSystem.bootstrap` anywhere else, because you can only call it once.
/// For example Vapor's templates use `LoggingSystem.bootstrap` on boot, and you need to remove that.
```
`DiscordLogManager` comes with a ton of useful configuration options.   
Here is an example of a decently-configured `DiscordLogManager`:   
Read `DiscordLogManager.Configuration.init` documentation for full info.

```swift
DiscordGlobalConfiguration.logManager = DiscordLogManager(
    httpClient: HTTP_CLIENT_YOU_MADE_IN_PREVIOUS_STEPS,
    configuration: .init(
        aliveNotice: .init(
            address: try .url(WEBHOOK_URL),
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
    gatewayManager: GatewayManager_YOU_MADE_IN_PREVIOUS_STEPS,
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
let aGuild = await cache.guilds[GUILD_ID]
print("Guild name is:", aGuild.name)
```
  
</details>

### React-To-Role
<details>
  <summary> Click to expand </summary>
  
`DiscordBM` can automatically assign a role to members when they react to a message with specific emojis:

```swift
let handler = try await ReactToRoleHandler(
    gatewayManager: GatewayManager_YOU_MADE_IN_PREVIOUS_STEPS,
    /// Your DiscordCache. This is not necessary (you can pass `nil`)
    /// Only helpful if the cache has `guilds` and/or `guildMembers` intents enabled
    cache: cache,
    /// The role-creation payload
    role: .init(
        name: "cool-gang",
        color: .green
    ),
    guildId: THE_GUILD_ID_OF_THE_MESSAGE_YOU_CREATED,
    channelId: THE_CHANNEL_ID_OF_THE_MESSAGE_YOU_CREATED,
    messageId: THE_MESSAGE_ID_OF_THE_MESSAGE_YOU_CREATED,
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

Include `"DiscordBM"` as a dependency for your targets:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "DiscordBM", package: "DiscordBM"),
]),
```

Finally, add `import DiscordBM` to your source code.

## Versioning
`DiscordBM` will try to follow Semantic Versioning 2.0.0, with exceptions.     
These exceptions should not be a big deal depending on your code style, but might result in slight code breakage if you don't follow the instructions below.       
* Adding enum cases.
  * This is so `DiscordBM` can continue to add new cases to public enums in minor versions.
  * If you care about code breakage, you can't use exhaustive switch statements.   
    Either include `default:` in your switch statements, or use `if case`/`if case let`.
  * See [this](https://forums.swift.org/t/extensible-enumerations-for-non-resilient-libraries/35900) for more info.
* Passing initializers/functions as arguments, or directly using their signatures somehow else.
  * This is so `DiscordBM` can continue to add new parameters to public initializers/functions in minor versions.   
  * If you care about code breakage, you can't write code like `value.map(SomeDiscordBMType.init)`.   
    Luckily, not many people do or need these stuff anyway.

## Contribution & Support
Any contribution is more than welcome. You can find me in [Vapor's Discord server](https://discord.com/invite/vapor) to discuss your ideas.   
Passing the `linux-integration` tests is not required for PRs because of token/access problems.
