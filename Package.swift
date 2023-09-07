// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let swiftSettings: [SwiftSetting] = [
    /// `DiscordBM` passes the `complete` level.
    ///
    /// `minimal` / `targeted` / `complete`
        .enableExperimentalFeature("strict-concurrency=complete"),

    /// `-enable-upcoming-feature` flags will get removed in the future
    /// and we'll need to remove them from here too.

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    /// Require `any` for existential types.
        .enableUpcomingFeature("ExistentialAny"),

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0274-magic-file.md
    /// Nicer `#file`.
        .enableUpcomingFeature("ConciseMagicFile"),

    /// https://github.com/apple/swift-evolution/blob/main/proposals/0286-forward-scan-trailing-closures.md
    /// This one shouldn't do much to be honest, but shouldn't hurt as well.
        .enableUpcomingFeature("ForwardTrailingClosures"),

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
            name: "DiscordCore",
            targets: ["DiscordCore"]
        ),
        .library(
            name: "DiscordHTTP",
            targets: ["DiscordHTTP"]
        ),
        .library(
            name: "DiscordGateway",
            targets: ["DiscordGateway"]
        ),
        .library(
            name: "DiscordModels",
            targets: ["DiscordModels"]
        ),
        .library(
            name: "DiscordUtilities",
            targets: ["DiscordUtilities"]
        ),
        .library(
            name: "DiscordAuth",
            targets: ["DiscordAuth"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.49.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.15.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.3"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.23.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.15.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.5"),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-08-29-a"
        )
    ],
    targets: [
        .target(
            name: "DiscordBM",
            dependencies: [
                .target(name: "DiscordAuth"),
                .target(name: "DiscordHTTP"),
                .target(name: "DiscordCore"),
                .target(name: "DiscordGateway"),
                .target(name: "DiscordModels"),
                .target(name: "DiscordUtilities"),
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
            name: "DiscordHTTP",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .target(name: "DiscordModels"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordGateway",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .target(name: "DiscordWebSocket"),
                .target(name: "DiscordHTTP"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordModels",
            dependencies: [
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "MultipartKit", package: "multipart-kit"),
                .target(name: "DiscordCore"),
                .target(name: "UnstableEnumMacro"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordUtilities",
            dependencies: [
                .target(name: "DiscordModels")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DiscordAuth",
            dependencies: [
                .target(name: "DiscordModels")
            ],
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
                .target(name: "CZlib"),
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
            dependencies: [
                .target(name: "GenerateAPIEndpointsExec")
            ]
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
        .macro(
            name: "UnstableEnumMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "./Macros/UnstableEnumMacro",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DiscordBMTests",
            dependencies: [
                .target(name: "DiscordBM")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "MacroTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .target(name: "UnstableEnumMacro")
            ],
            swiftSettings: swiftSettings
        ),
        /// Vapor's `WebSocketKit` tests with modifications to fit `DiscordBM` better.
        .testTarget(
            name: "WebSocketTests",
            dependencies: [
                .target(name: "DiscordWebSocket")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                .target(name: "DiscordBM")
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
