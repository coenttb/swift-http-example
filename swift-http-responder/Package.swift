// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-http-responder",
    platforms: [
        .macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27),
    ],
    products: [
        .library(name: "HTTP Responder", targets: ["HTTP Responder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-client.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-http.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-serializer-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "HTTP Responder",
            dependencies: [
                .product(name: "Client", package: "swift-client"),
                .product(name: "HTTP Coder", package: "swift-http-coder"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(), .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"), .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"), .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
