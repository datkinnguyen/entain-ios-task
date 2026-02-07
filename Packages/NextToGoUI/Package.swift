// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NextToGoUI",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NextToGoUI",
            targets: ["NextToGoUI"]
        )
    ],
    dependencies: [
        .package(path: "../NextToGoCore"),
        .package(path: "../NextToGoViewModel"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.0")
    ],
    targets: [
        .target(
            name: "NextToGoUI",
            dependencies: [
                "NextToGoCore",
                "NextToGoViewModel"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "NextToGoUITests",
            dependencies: [
                "NextToGoUI",
                // TODO: Implement snapshot tests for visual regression testing
                // SnapshotTesting is configured but tests are not yet implemented
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
