// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SImage",
    products: [
        .library(
            name: "SImage",
            targets: ["SImage"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SImage",
            dependencies: []),
        .testTarget(
            name: "SImageTests",
            dependencies: ["SImage"]),
    ]
)
