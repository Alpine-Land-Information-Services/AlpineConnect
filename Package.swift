// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlpineConnect",
    platforms: [
        .iOS(.v17)
    ], products: [
        .library(
            name: "AlpineConnect",
            targets: ["AlpineConnect"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jenyalebid/AlpineCore.git", branch: "main"),
        .package(url: "https://github.com/jenyalebid/AlpineUI.git", branch: "main"),
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit.git", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "AlpineConnect",
            dependencies: ["AlpineCore", "AlpineUI", "PostgresClientKit"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "AlpineConnectTests",
            dependencies: ["AlpineConnect"]),
    ]
)
