![DiscordBM](https://user-images.githubusercontent.com/54685446/201329617-9fd91ab0-35c2-42c2-8963-47b68c6a490a.png)

<p align="center">
	<a href="https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml">
        <img src="https://github.com/MahdiBM/DiscordBM/actions/workflows/tests.yml/badge.svg" alt="Tests Badge">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.6-brightgreen.svg" alt="Minimum Swift Version">
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

First you need to initialize a `BotGatewayManager` instance, then tell it to connect and start using it:

### Initializing a Gateway Manager On Your Own

Make sure you've added [AsyncHTTPClient](https://github.com/swift-server/async-http-client) to your dependancies.
```swift
import DiscordBM
import AsyncHTTPClient

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
defer {
    /// it's important to shutdown the httpClient _after all requests are done_, even if one failed
    /// libraries like Vapor take care of this on their own if you use the shared http client
    /// You might need to move the shutdown call to somewhere more appropriate, based on your app:
    /// try httpClient.syncShutdown()
    /// Prefer to use `shutdown()` in async contexts:
    /// try await httpClient.shutdown()
}
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

/// Add event handlers
Task {
    await bot.addEventHandler { event in
        switch event.data {
        case let .messageCreate(message):
            print("GOT MESSAGE!", message)
            /// Switch over other cases you have intents for and you care about
        default: break
        }
    }
    
    /// If you care about library parsing failures, handle them here
    await bot.addEventParseFailureHandler { error, buffer in
        /// Handle the failure using the `Error` thrown and the `ByteBuffer` received
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

### Finding Your Bot Token
<details>
  <summary> Click to expand </summary>
  
In [Discord developer portal](https://discord.com/developers/applications):
![Finding Bot Token](https://user-images.githubusercontent.com/54685446/200565393-ea31c2ad-fd3a-44a1-9789-89460ab5d1a9.png)

</details>

### Finding Your App ID
<details>
  <summary> Click to expand </summary>
  
In [Discord developer portal](https://discord.com/developers/applications):
![Finding App ID](https://user-images.githubusercontent.com/54685446/200565475-9893d326-423e-4344-a853-9de2f9ed25b4.png)

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
I'm also actively looking for any new info in the Discord API, and will add them to the library as soon as I can.
