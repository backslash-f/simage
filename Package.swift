// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SImage",
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
