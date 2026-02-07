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
        .package(path: "../NextToGoViewModel")
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
                "NextToGoUI"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
