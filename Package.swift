// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package (
    name: "CommandInterface",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "CommandInterface", targets: ["CommandInterface"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Vaida12345/FinderItem", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "CommandInterface",
            dependencies: [
                "FinderItem",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CICComponent"
            ],
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["CommandInterface", "FinderItem"],
            path: "Tests",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
        .target(name: "CICComponent"),
        .executableTarget(
            name: "Client",
            dependencies: [
                "CommandInterface",
                "FinderItem",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Client",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        )
    ],
    swiftLanguageModes: [.v5]
)
