// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HNMarkdownStream",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HNMarkdownStream",
            targets: ["HNMarkdownStream"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/mgriebling/SwiftMath.git",from: "1.7.1"),
        .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.16.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // No changes, skip based on thought process.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HNMarkdownStream",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                "SwiftMath",
                "Splash"
            ]
        ),
    ]
)
