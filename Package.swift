// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "NukeBuilder",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "NukeBuilder", targets: ["NukeBuilder"])
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "10.0.0")
    ],
    targets: [
        .target(name: "NukeBuilder", dependencies: ["Nuke"], path: "Source"),
        .testTarget(name: "NukeBuilderTests", dependencies: ["NukeBuilder"], path: "Tests")
    ]
)
