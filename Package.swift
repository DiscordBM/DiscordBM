// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiscordBM",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DiscordBM",
            targets: ["DiscordBM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.6.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.42.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.4"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.4"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.2"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.2")
    ],
    targets: [
        .target(
            name: "DiscordBM",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "WebSocketKit", package: "websocket-kit"),
                .product(name: "Atomics", package: "swift-atomics"),
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
