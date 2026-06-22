// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GameSim",
    dependencies: [
        .package(path: "../GameCore")
    ],
    targets: [
        .executableTarget(
            name: "GameSim",
            dependencies: ["GameCore"]
        )
    ]
)
