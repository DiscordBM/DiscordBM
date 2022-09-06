// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiscordBM",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "DiscordBM",
            targets: ["DiscordBM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.41.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.4")
    ],
    targets: [
        .target(
            name: "DiscordBM",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "WebSocketKit", package: "websocket-kit")
            ]),
        .testTarget(
            name: "DiscordBMTests",
            dependencies: ["DiscordBM"]),
    ]
)
