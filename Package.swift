// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package (
    name: "CommandInterface",
    platforms: [
        .macOS(.v13)
    ], products: [
        .library(name: "CommandInterface", targets: ["CommandInterface"]),
    ], dependencies: [
        .package(name: "Stratum", path: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/Stratum"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ], targets: [
        .target(name: "CommandInterface", dependencies: ["Stratum", .product(name: "ArgumentParser", package: "swift-argument-parser"), "CICComponent"]),
        .testTarget(name: "CommandInterfaceTests", dependencies: ["CommandInterface"]),
        .target(name: "CICComponent")
    ]
)
