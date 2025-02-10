// swift-tools-version: 5.10

import CompilerPluginSupport
import PackageDescription

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
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.49.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.5"),
        .package(url: "https://github.com/apple/swift-syntax.git", "509.0.0"..<"601.0.0"),
        .package(url: "https://github.com/adam-fowler/compress-nio.git", from: "1.3.0"),
        .package(url: "https://github.com/hummingbird-project/swift-websocket.git", from: "1.2.0"),
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
                .product(name: "WSClient", package: "swift-websocket"),
                .product(name: "CompressNIO", package: "compress-nio"),
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
                .product(name: "Yams", package: "Yams"),
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
                .target(name: "UnstableEnumMacro"),
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

var featureFlags: [SwiftSetting] {
    [
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
}

var experimentalFeatureFlags: [SwiftSetting] {
    [
        /// `DiscordBM` passes the `complete` level.
        ///
        /// `minimal` / `targeted` / `complete`
        .enableExperimentalFeature("StrictConcurrency=complete")
    ]
}

var swiftSettings: [SwiftSetting] {
    featureFlags + experimentalFeatureFlags
}
