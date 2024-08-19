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
        .package(name: "Stratum", path: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/Stratum"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "CommandInterface",
            dependencies: [
                "Stratum",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CICComponent"
            ],
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["CommandInterface", "Stratum"],
            path: "Tests",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
        .target(name: "CICComponent"),
        .executableTarget(
            name: "Client",
            dependencies: [
                "CommandInterface",
                "Stratum",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Client",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        )
    ],
    swiftLanguageModes: [.v5]
)
