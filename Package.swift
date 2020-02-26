// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SImage",
    platforms: [
        // Minimum required versions due to "FileManager.default.temporaryDirectory"
        .iOS(.v12),
        .macOS(.v10_12)
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
