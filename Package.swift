// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ImageTaskBuilder",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "ImageTaskBuilder", targets: ["ImageTaskBuilder"])
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "8.0.0")
    ],
    targets: [
        .target(name: "ImageTaskBuilder", dependencies: ["Nuke"], path: "Source")
    ]
)
