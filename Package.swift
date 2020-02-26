// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SImage",
    platforms: [
       .macOS(.v10_12) // Minimum macOS version due to "FileManager.default.temporaryDirectory"
    ],
    products: [
        .library(
            name: "SImage",
            targets: ["SImage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/backslash-f/worker", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SImage",
            dependencies: ["Worker"]),
        .testTarget(
            name: "SImageTests",
            dependencies: ["SImage"]),
    ]
)
