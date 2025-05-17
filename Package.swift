// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UtilityKit",
    products: [
        .library(
            name: "UtilityKit",
            targets: ["UtilityKit"]),
        .library(name: "ContextMenu", targets: ["ContextMenu"])
    ],
    targets: [
        .target(
            name: "UtilityKit"),
        .target(name: "ContextMenu", dependencies: ["UtilityKit"])
    ]
)
