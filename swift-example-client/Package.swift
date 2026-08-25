// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example-client",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Example Greeting Client",
            targets: ["Example Greeting Client"]
        ),
        .library(
            name: "Example Counter Client",
            targets: ["Example Counter Client"]
        ),
        .library(
            name: "Example Client",
            targets: ["Example Client"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-foundations/swift-client-macros.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-client.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-institute/swift-example.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Example Greeting Client",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Macros", package: "swift-client-macros"),
            ]
        ),
        .target(
            name: "Example Counter Client",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Macros", package: "swift-client-macros"),
            ]
        ),
        .target(
            name: "Example Client",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                "Example Greeting Client",
                "Example Counter Client",
            ]
        ),
        .testTarget(
            name: "Example Client Tests",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Client", package: "swift-client"),
                "Example Greeting Client",
                "Example Counter Client",
                "Example Client",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
