// swift-tools-version: 5.6

import PackageDescription
#warning("fix 'dependencies' branch: 'mahdibm-decompression'")
let package = Package(
    name: "DiscordBM",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "DiscordBM",
            targets: ["DiscordBM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mahdibm/websocket-kit.git", branch: "mahdibm-decompression"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.42.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.4"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.4"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.2")
    ],
    targets: [
        .target(
            name: "DiscordBM",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "MultipartKit", package: "multipart-kit")
            ]
        ),
        .testTarget(
            name: "DiscordBMTests",
            dependencies: ["DiscordBM"]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["DiscordBM"]
        ),
    ]
)
