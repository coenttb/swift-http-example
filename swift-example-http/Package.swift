// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-example-http",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Example Greeting HTTP",
            targets: ["Example Greeting HTTP"]
        ),
        .library(
            name: "Example Counter HTTP",
            targets: ["Example Counter HTTP"]
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
            url: "https://github.com/swift-institute/swift-example-client-remote.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-institute/swift-example-application.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-institute/swift-example-application-remote.git",
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
            url: "https://github.com/swift-foundations/swift-http.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-http-coder.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-http-client.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-http-responder.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-coder-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-either-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-parser-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-serializer-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-ietf/swift-rfc-3986.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Example Greeting HTTP",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(
                    name: "Example Greeting Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(name: "Client", package: "swift-client"),
                .product(name: "Client Remote", package: "swift-client-remote"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "HTTP Coder", package: "swift-http-coder"),
                .product(name: "HTTP Client", package: "swift-http-client"),
                .product(name: "HTTP Responder", package: "swift-http-responder"),
                .product(name: "Byte Primitive", package: "swift-byte-primitives"),
                .product(name: "Coder Witness Primitives", package: "swift-coder-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
            ]
        ),
        .target(
            name: "Example Counter HTTP",
            dependencies: [
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(
                    name: "Example Counter Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(name: "Client", package: "swift-client"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "HTTP Coder", package: "swift-http-coder"),
                .product(name: "HTTP Client", package: "swift-http-client"),
                .product(name: "HTTP Responder", package: "swift-http-responder"),
                .product(name: "Byte Primitive", package: "swift-byte-primitives"),
                .product(name: "Coder Witness Primitives", package: "swift-coder-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Parser Primitive", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitive", package: "swift-serializer-primitives"),
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
            ]
        ),
        .testTarget(
            name: "Example HTTP Tests",
            dependencies: [
                "Example Greeting HTTP",
                "Example Counter HTTP",
                .product(name: "Example", package: "swift-example"),
                .product(name: "Example Greeting", package: "swift-example"),
                .product(name: "Example Counter", package: "swift-example"),
                .product(name: "Example Greeting Client", package: "swift-example-client"),
                .product(name: "Example Counter Client", package: "swift-example-client"),
                .product(name: "Example Client", package: "swift-example-client"),
                .product(name: "Example Client Remote", package: "swift-example-client-remote"),
                .product(
                    name: "Example Greeting Client Remote",
                    package: "swift-example-client-remote"
                ),
                .product(name: "Example Application", package: "swift-example-application"),
                .product(
                    name: "Example Application Remote",
                    package: "swift-example-application-remote"
                ),
                .product(name: "Client", package: "swift-client"),
                .product(name: "HTTP", package: "swift-http"),
                .product(name: "HTTP Coder", package: "swift-http-coder"),
                .product(name: "HTTP Client", package: "swift-http-client"),
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
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
