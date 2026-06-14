// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RRNetworking",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(name: "RRNetworking", targets: ["RRNetworking"])
    ],
    targets: [
        .target(
            name: "RRNetworking",
            path: "Sources/RRNetworking",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "RRNetworkingTests",
            dependencies: ["RRNetworking"],
            path: "Tests/RRNetworkingTests"
        )
    ]
)
