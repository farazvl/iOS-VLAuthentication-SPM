// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VLAuthentication",
    platforms: [
        .iOS(.v14),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VLAuthentication",
            targets: ["VLAuthentication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/farazvl/VLBeaconSwift.git", branch: "main"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "15.1.0"),
        .package(url: "https://github.com/Google/GoogleSignIn-iOS.git", from: "7.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VLAuthentication"),
        .testTarget(
            name: "VLAuthenticationTests",
            dependencies: ["VLAuthentication"]),
    ]
)
