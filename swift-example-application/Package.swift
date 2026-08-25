// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example-application",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Example Application",
            targets: ["Example Application"]
        ),
        .library(
            name: "Example CLI",
            targets: ["Example CLI"]
        ),
        .library(
            name: "Example Client Local",
            targets: ["Example Client Local"]
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
            url: "https://github.com/swift-primitives/swift-application-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Example Application",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Application Primitives", package: "swift-application-primitives"),
            ]
        ),
        .target(
            name: "Example CLI",
            dependencies: [
                "Example Application",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
            ]
        ),
        .target(
            name: "Example Client Local",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Client", package: "swift-client"),
            ]
        ),
        .testTarget(
            name: "Example Application Tests",
            dependencies: [
                "Example Application",
                "Example Client Local",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Application Primitives", package: "swift-application-primitives"),
            ]
        ),
        .testTarget(
            name: "Example CLI Tests",
            dependencies: [
                "Example Application",
                "Example CLI",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
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
