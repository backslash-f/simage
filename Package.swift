// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SImage",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SImage",
            targets: ["SImage"]),
    ],
    dependencies: [
        .package(name: "Worker", url: "https://github.com/backslash-f/worker", from: "1.0.0"),
        .package(name: "AppLogger", url: "https://github.com/backslash-f/applogger", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SImage",
            dependencies: ["Worker", "AppLogger"]),
        .testTarget(
            name: "SImageTests",
            dependencies: ["SImage"],
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
