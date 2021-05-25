// swift-tools-version:5.2

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
        .package(url: "https://github.com/kean/Nuke.git", .exact("10.0.0-rc.2"))
    ],
    targets: [
        .target(name: "ImageTaskBuilder", dependencies: ["Nuke"], path: "Source")
    ]
)
