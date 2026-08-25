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
            ]
        ),
        .testTarget(
            name: "Example Application Tests",
            dependencies: [
                "Example Application",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Client", package: "swift-client"),
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
