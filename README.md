# DiscordBM

[![Build Status](https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml/badge.svg)](https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml)

A Swift library for making Discord bots.

## Notable Features
* Everything with structured concurrency and async/await. Full integration with all the latest Server-Side Swift packages.
* Connect to the Discord gateway and receive all events easily.
* Send requests to the Discord API using library's Discord client.
* hard-typed APIs. All Gateway events have their own type and all Discord API responses can be decoded easily.
* Abstractions for easier testability.

## Showcase
You can see Vapor community's Penny bot as a showcase of using this library in production. Penny is used to give coins to the helpful members of the Vapor community as a sign of appreciation.   
Penny is available [here](https://github.com/vapor/penny-bot) and you can find `DiscordBM` used in the [PennyBOT](https://github.com/vapor/penny-bot/tree/main/CODE/Sources/PennyBOT) target.

## How To Use
First you need to initialize a `BotGatewayManager` instance, then tell it to connect and start using it:

### Initializing a Gateway Manager On Your Own
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
    intents: [.guildMessages, .messageContent] /// Add all the intents you want
)

/// it's important to shutdown the httpClient _after all requests are done_, even if one failed
/// libraries like Vapor take care of this on their own if you use the shared http client
try httpClient.syncShutdown()
/// Prefer to use `shutdown()` in async contexts:
/// try await httpClient.shutdown()
```
See the [GatewayConnection tests](https://github.com/MahdiBM/DiscordBM/blob/main/Tests/IntegrationTests/GatwayConnection.swift) or [Vapor community's Penny bot](https://github.com/vapor/penny-bot/blob/main/CODE/Sources/PennyBOT/Bot.swift) for real-world examples.

### Initializing a Gateway Manager With Vapor
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
    intents: [.guildMessages, .messageContent] /// Add all the intents you want
)
```

### Using The Gateway Manager
```swift
import DiscordBM

let bot: BotGatewayManager = ... /// Make an instance like above

/// Add event handlers
Task {
    await bot.addEventHandler { event in
        switch event.data {
        case let .messageCreate(message):
            print("GOT MESSAGE!", message)
            /// Switch over other cases you have intents for and you care about.
        default: break
        }
    }
    
    /// If you care about library parsing failures, handle them here
    await bot.addEventParseFailureHandler { error, text in
        /// Handle the failure using the `error` thrown and the `text` received.
    }

    /// Tell the manager to connect to Discord
    await bot.connect()

    /// Use `bot.client` to send requests to discord.
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

### Finding Your Bot Token
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](/images/bot_token.png)

### Finding Your App ID
In [Discord developer portal](https://discord.com/developers/applications):
![Finding App ID](/images/bot_app_id.png)

## Testability
`DiscordBM` comes with tools to make testing your app easier.   
* You can type-erase your `BotGatewayManager`s using the `GatewayManager` protocol so you can override your gateway manager with a mocked implementation in tests.   
* You can also do the same for `DefaultDiscordClient` and type-erase it using the `DiscordClient` protocol so you can provide a mocked implementation when testing.

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

## Warnings
This library will try to follow Semantic Versioning, with exceptions:
* If Discord has made some changes that need breaking changes in this library, but are not worth a major release and are rather small.
* When adding enum cases.

## Contribution & Support
Any contribution is more than welcome. You can find me in [Vapor's Discord server](https://discord.com/invite/vapor) to discuss your ideas.   
I'm also actively looking for any new info in the Discord API, and will add them to the library as soon as I can.
