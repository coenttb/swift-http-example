// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example-application-local",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .executable(
            name: "example-local",
            targets: ["example-local"]
        )
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
            url: "https://github.com/swift-institute/swift-example-application.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-application-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .executableTarget(
            name: "example-local",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Example Application", package: "swift-example-application"),
                .product(name: "Example CLI", package: "swift-example-application"),
                .product(name: "Example Client Local", package: "swift-example-application"),
                .product(name: "Application Primitives", package: "swift-application-primitives"),
            ]
        )
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
