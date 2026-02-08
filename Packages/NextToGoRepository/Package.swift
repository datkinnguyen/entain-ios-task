// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NextToGoRepository",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "NextToGoRepository",
            targets: ["NextToGoRepository"]
        )
    ],
    dependencies: [
        .package(path: "../NextToGoCore"),
        .package(path: "../NextToGoNetworking")
    ],
    targets: [
        .target(
            name: "NextToGoRepository",
            dependencies: [
                "NextToGoCore",
                "NextToGoNetworking"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "NextToGoRepositoryTests",
            dependencies: ["NextToGoRepository"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
