# DiscordBM

[![Build Status](https://github.com/MahdiBM/TwitchIRC/actions/workflows/tests.yml/badge.svg)](https://github.com/MahdiBM/TwitchIRC/actions/workflows/tests.yml)

A Discord libarary for making Discord bots in Swift.

## How to use
First you need to initialize a `DiscordManager` instance, then tell it to connect and start using it:

### Intializing A Manager With Vapor
```swift
import DiscordBM
import Vapor

let app: Application = YOUR_VAPOR_APPLICATION
let manager = DiscordManager(
    eventLoopGroup: app.eventLoopGroup,
    httpClient: app.http.client.shared,
    token: YOUR_BOT_TOKEN,
    appId: YOUR_APPLICATION_ID,
    presence: .init( /// Set up bot's initial presence
        activities: [.init(name: "Fortnite", type: .game)],
        status: .online,
        afk: false
    ),
    intents: [.guildMessages, .messageContent] /// Add all the intents you want
)
```

### Intializing A Manager On Your Own
```swift
import DiscordBM
import AsyncHTTPClient

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
let manager = DiscordManager(
    eventLoopGroup: httpClient.eventLoopGroup,
    httpClient: httpClient,
    token: YOUR_BOT_TOKEN,
    appId: YOUR_APPLICATION_ID,
    presence: .init( /// Set up bot's initial presence
        activities: [.init(name: "Fortnite", type: .game)],
        status: .online,
        afk: false
    ),
    intents: [.guildMessages, .messageContent] /// Add all the intents you want
)

/// it's important to shutdown the httpClient _after all requests are done_, even if one failed
/// libraries like vapor take care of this on their own if you use the shared http client
try await httpClient.shutdown()
```

### Using The Discord Manager
```swift
import DiscordBM

let manager: DiscordManager = ... /// Make an instance like above

/// Tell manager to connect to Discord
manager.connect()

/// Add event handlers
Task {
    await manager.addEventHandler { event in
        switch event.data {
        case let .messageCreate(message):
            print("GOT MESSAGE!", message)
            /// Switch over other cases you have intents for and you care about.
        default: break
        }
    }
    
    /// If you care about library parsing failures, handle them here
    await manager.addEventParseFailureHandler { error, text in
        /// Handle the failure using the `error` thrown and the `text` received.
    }
}

/// Use `manager.client` to send requests to discord.
Task {
    try await manager.client.postChannelCreateMessage(
        id: CHANNEL_ID,
        payload: .init(content: "Hello Everybody!")
    )
}
```

### Finding Your Bot Token
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](/images/bot_token.png)

### Finding Your App ID
In [Discord developer portal](https://discord.com/developers/applications):
![Finding App ID](/images/bot_app_id.png)

## Warnings
This libarary will try to follow the no-breaking-changes-in-minor-versions rule, with exceptions:
* If Discord has made some changes that need breaking changes in this library, but are not worth a major release and are rather small.
* When adding enum cases.

## Wishlist / Not Yet supported:
* Better documentation
* More tests (add ci too)
* A snowflake type
* Support more endpoints
* Remove a few redundant structs
* Attachements support (You can provide media links instead, for now, which is better anyway)
* OAuth support
* Full sharding support

## Contribution
Any contribution is more than welcome. You can find me in [Vapor's Discord server](https://discord.com/invite/vapor) to discuss your ideas.
