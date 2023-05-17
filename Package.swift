// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlpineConnect",
    platforms: [
        .iOS(.v15)
    ], products: [
        .library(
            name: "AlpineConnect",
            targets: ["AlpineConnect"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jenyalebid/AlpineCore.git", .branch("main")),
        .package(url: "https://github.com/jenyalebid/AlpineUI.git", .branch("main")),
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit.git", from: "1.4.3"),
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.2")
    ],
    targets: [
        .target(
            name: "AlpineConnect",
            dependencies: ["AlpineCore", "AlpineUI", "PostgresClientKit", "Zip"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "AlpineConnectTests",
            dependencies: ["AlpineConnect"]),
    ]
)
