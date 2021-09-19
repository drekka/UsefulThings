// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UsefulThings",
    platforms: [
        .iOS(.v15),
        .tvOS(.v11),
        //.macOS(.v10_11),
    ],
    products: [
        .library(
            name: "UsefulThings",
            targets: ["UsefulThings"]
        ),
    ],
    dependencies: [
        .package(name: "Nimble", url: "https://github.com/quick/nimble", branch: "main"),
    ],
    targets: [
        .target(
            name: "UsefulThings",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "UsefulThingsTests",
            dependencies: ["UsefulThings", "Nimble"],
            path: "Tests"
        ),
    ]
)
