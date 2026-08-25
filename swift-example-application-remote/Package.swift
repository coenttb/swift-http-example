// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example-application-remote",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .executable(
            name: "example-remote",
            targets: ["example-remote"]
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
            url: "https://github.com/swift-institute/swift-example-client-remote.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-institute/swift-example-application.git",
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
            url: "https://github.com/swift-foundations/swift-application.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Example Application Remote",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(
                    name: "Example Greeting Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(
                    name: "Example Counter Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(name: "Example Client Remote", package: "swift-example-client-remote"),
                .product(name: "Example Application", package: "swift-example-application"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Application", package: "swift-application"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .executableTarget(
            name: "example-remote",
            dependencies: [
                "Example Application Remote",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(
                    name: "Example Greeting Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(
                    name: "Example Counter Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(name: "Example Client Remote", package: "swift-example-client-remote"),
                .product(name: "Example Application", package: "swift-example-application"),
                .product(name: "Example CLI", package: "swift-example-application"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Remote", package: "swift-client-remote"),
                .product(name: "Application", package: "swift-application"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),
        .testTarget(
            name: "example-remote Tests",
            dependencies: [
                "Example Application Remote",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(
                    name: "Example Greeting Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(
                    name: "Example Counter Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(name: "Example Client Remote", package: "swift-example-client-remote"),
                .product(name: "Example Application", package: "swift-example-application"),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Remote", package: "swift-client-remote"),
                .product(name: "Application", package: "swift-application"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
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
