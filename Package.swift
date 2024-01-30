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
        .package(name: "Stratum", path: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/Stratum")
    ], targets: [
        .target(name: "CommandInterface", dependencies: ["Stratum"]),
        .executableTarget(name: "Executable", dependencies: ["CommandInterface"]),
        .testTarget(name: "CommandInterfaceTests", dependencies: ["CommandInterface"]),
    ]
)
