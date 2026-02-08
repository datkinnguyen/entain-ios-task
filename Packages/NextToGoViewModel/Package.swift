// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NextToGoViewModel",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "NextToGoViewModel",
            targets: ["NextToGoViewModel"]
        )
    ],
    dependencies: [
        .package(path: "../NextToGoCore"),
        .package(path: "../NextToGoRepository"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "NextToGoViewModel",
            dependencies: [
                "NextToGoCore",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "NextToGoViewModelTests",
            dependencies: [
                "NextToGoViewModel",
                "NextToGoRepository"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
