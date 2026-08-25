// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example-client-remote",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Example Greeting Client Remote",
            targets: ["Example Greeting Client Remote"]
        ),
        .library(
            name: "Example Counter Client Remote",
            targets: ["Example Counter Client Remote"]
        ),
        .library(
            name: "Example Client Remote",
            targets: ["Example Client Remote"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-institute/swift-example.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-institute/swift-example-client.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-client.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-client-remote.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Example Greeting Client Remote",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Client", package: "swift-client"),
            ]
        ),
        .target(
            name: "Example Counter Client Remote",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Remote", package: "swift-client-remote"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .target(
            name: "Example Client Remote",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Example Client", package: "swift-example-client"),
                "Example Greeting Client Remote",
                "Example Counter Client Remote",
            ]
        ),
        .testTarget(
            name: "Example Client Remote Tests",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Remote", package: "swift-client-remote"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                "Example Greeting Client Remote",
                "Example Counter Client Remote",
                "Example Client Remote",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
