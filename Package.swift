// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UtilityKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "UtilityKit",
            targets: ["UtilityKit"]
        ),
        .library(
            name: "ContextMenu",
            targets: ["ContextMenu"]
        )
    ],
    targets: [
        .target(
            name: "UtilityKit",
            path: "Sources/UtilityKit"
        ),
        .target(
            name: "ContextMenu",
            path: "Sources/ContextMenu"
        )
    ]
)
