// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UtilityKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "UtilityKit",
            targets: ["UtilityKit"]
        )
    ],
    targets: [
        .target(
            name: "UtilityKit",
            path: "Sources/UtilityKit"
        )
    ]
)
