// swift-tools-version: 5.7

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    /// Versioned releases can't use this flag?! So can't commit this flag to git.
    /// `DiscordBM` passes the `complete` level.
    ///
    /// `minimal` / `targeted` / `complete`
//    .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])

    /// `-enable-upcoming-feature` flags will get removed in the future
    /// and we'll need to remove them from here too.

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    /// Require `any` for existential types.
        .unsafeFlags(["-enable-upcoming-feature", "ExistentialAny"]),

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0274-magic-file.md
    /// Nicer `#file`.
        .unsafeFlags(["-enable-upcoming-feature", "ConciseMagicFile"]),

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0286-forward-scan-trailing-closures.md
    /// This one shouldn't do much to be honest, but shouldn't hurt as well.
        .unsafeFlags(["-enable-upcoming-feature", "ForwardTrailingClosures"]),

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0354-regex-literals.md
    /// `BareSlashRegexLiterals` not enabled since we don't use regex anywhere.

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0384-importing-forward-declared-objc-interfaces-and-protocols.md
    /// `ImportObjcForwardDeclarations` not enabled because it's objc-related.
]

let package = Package(
    name: "DiscordBM",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "DiscordBM",
            targets: ["DiscordBM"]
        ),
        .library(
            name: "DiscordLogger",
            targets: ["DiscordLogger"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.49.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.15.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.5"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.23.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.15.0"),
    ],
    targets: [
        .target(
            name: "DiscordBM",
            dependencies: [
                "DiscordAuth",
                "DiscordHTTP",
                "DiscordCore",
                "DiscordGateway",
                "DiscordLogger",
                "DiscordModels",
                "DiscordUtilities",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordHTTP",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                "DiscordModels",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "MultipartKit", package: "multipart-kit"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordGateway",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                "DiscordWebSocket",
                "DiscordHTTP",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordLogger",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                "DiscordHTTP",
                "DiscordUtilities",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordModels",
            dependencies: [
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "MultipartKit", package: "multipart-kit"),
                "DiscordCore"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordUtilities",
            dependencies: [
                "DiscordModels"
            ]
        ),
        .target(
            name: "DiscordAuth",
            dependencies: [
                "DiscordModels"
            ],
            swiftSettings: swiftSettings
        ),
        .plugin(
            name: "GenerateAPIEndpoints",
            capability: .command(
                intent: .custom(
                    verb: "generate-api-endpoints",
                    description: "Generates API Endpoints"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Add Generated Endpoints")
                ]
            ),
            dependencies: ["GenerateAPIEndpointsExec"]
        ),
        .executableTarget(
            name: "GenerateAPIEndpointsExec",
            dependencies: [
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Yams", package: "Yams")
            ],
            path: "Plugins/GenerateAPIEndpointsExec",
            resources: [.copy("Resources/openapi.yml")],
            swiftSettings: swiftSettings
        ),
        /// Vapor's `WebSocketKit` with modifications to fit `DiscordBM` better.
        .target(
            name: "DiscordWebSocket",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
                .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
                .product(name: "Atomics", package: "swift-atomics"),
                "CZlib"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CZlib",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .testTarget(
            name: "DiscordBMTests",
            dependencies: ["DiscordBM"]
        ),
        /// Vapor's `WebSocketKit` tests with modifications to fit `DiscordBM` better.
        .testTarget(
            name: "WebSocketTests",
            dependencies: ["DiscordWebSocket"]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["DiscordBM"]
        ),
    ]
)
