# DiscordBM

[![Build Status](https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml/badge.svg)](https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml)

A library for making Discord bots in Swift.

## How To Use
First you need to initialize a `GatewayManager` instance, then tell it to connect and start using it:

### Initializing A Manager With Vapor
```swift
import DiscordBM
import Vapor

let app: Application = YOUR_VAPOR_APPLICATION
let manager = GatewayManager(
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

### Initializing A Manager On Your Own
Make sure you've added [AsyncHTTPClient](https://github.com/swift-server/async-http-client) to your dependancies.
```swift
import DiscordBM
import AsyncHTTPClient

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
let manager = GatewayManager(
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
/// libraries like Vapor take care of this on their own if you use the shared http client
try await httpClient.shutdown()
```

### Using The Gateway Manager
```swift
import DiscordBM

let manager: GatewayManager = ... /// Make an instance like above

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
    try await manager.client.createMessage(
        channelId: CHANNEL_ID,
        payload: .init(content: "Hello Everybody!")
    )
}

// If you don't use libraires like Vapor that do this for you, 
// you'll need to uncomment this line and call it from a non-async context.
// Otherwise your executable will exit immediately after every run.
// RunLoop.current.run()
```

### Finding Your Bot Token
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](/images/bot_token.png)

### Finding Your App ID
In [Discord developer portal](https://discord.com/developers/applications):
![Finding App ID](/images/bot_app_id.png)

## How To Add DiscordBM To Your Project

To use the `DiscordBM` library in a SwiftPM project, 
add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/MahdiBM/DiscordBM", branch: "main"),
```

Include `"DiscordBM"` as a dependency for your targets:

```swift
.target(name: "<target>", dependencies: [
    .product(name: "DiscordBM", package: "DiscordBM"),
]),
```

Finally, add `import DiscordBM` to your source code.

## Warnings
This library will try to follow the no-breaking-changes-in-minor-versions rule, with exceptions:
* If Discord has made some changes that need breaking changes in this library, but are not worth a major release and are rather small.
* When adding enum cases.

## Wishlist / Not Yet Supported
* Better documentation
* More tests (Currently very little tests)
* Support more endpoints (Easy to add yourself; PRs appreciated)
* Make eveything Sendable
* Remove a few redundant structs
* Attachments support (For now you can provide media links instead, which is usually better anyway)
* OAuth-2 support

## Showcase
You can see Vapor community's Penny bot as a showcase of using this library in production. Penny is used to give coins to the helpful members of the Vapor community as a sign of appreciation.   
Penny is available [here](https://github.com/vapor/penny-bot) and you can find `DiscordBM` used in the [PennyBOT](https://github.com/vapor/penny-bot/tree/main/CODE/Sources/PennyBOT) target.

## Contribution
Any contribution is more than welcome. You can find me in [Vapor's Discord server](https://discord.com/invite/vapor) to discuss your ideas.
