# DiscordBM

A Discord libarary for making Discord bots in Swift.

## How to use
```swift
import NIO
import AsyncHTTPClient

/// Optionally modify `DiscordGlobalConfiguration` proprerties.
let eventLoopGroup: EventLoopGroup = ... /// Provide you app's `EventLoopGroup`
let httpClient: HTTPClient = ... /// Provide you app's `HTTPClient`

let manager = DiscordManager(
    eventLoopGroup: eventLoopGroup,
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

## Not (yet) supported:
* Better documentation
* More tests (add ci too)
* A snowflake type
* Support more endpoints
* Remove a few redundant structs
* Attachements support (for now, you can provide media links instead)
* OAuth support
* Sharding support
