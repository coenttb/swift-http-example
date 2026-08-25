// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Example",
            targets: ["Example"]
        ),
        .library(
            name: "Example Greeting",
            targets: ["Example Greeting"]
        ),
        .library(
            name: "Example Counter",
            targets: ["Example Counter"]
        ),
    ],
    targets: [
        .target(
            name: "Example"
        ),
        .target(
            name: "Example Greeting",
            dependencies: [
                "Example"
            ]
        ),
        .target(
            name: "Example Counter",
            dependencies: [
                "Example"
            ]
        ),
        .testTarget(
            name: "Example Greeting Tests",
            dependencies: [
                "Example",
                "Example Greeting",
            ]
        ),
        .testTarget(
            name: "Example Counter Tests",
            dependencies: [
                "Example",
                "Example Counter",
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
