// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OnCallKit",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "OnCallKit",
            targets: ["OnCallKit", "MobileRTC"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", .exact("5.0.1")),
        .package(name: "Bugsnag", url: "https://github.com/bugsnag/bugsnag-cocoa", .exact("6.8.3")),
        .package(url: "https://github.com/huri000/SwiftEntryKit", .exact("1.2.7")),
        .package(url: "https://github.com/slackhq/PanModal", .exact("1.2.7")),
        .package(url: "https://github.com/Alamofire/Alamofire", .exact("5.4.2")),
        .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.13.2")),
        .package(name: "KeychainSwift", url: "https://github.com/evgenyneu/keychain-swift", .exact("19.0.0")),
        .package(url: "https://github.com/daltoniam/Starscream", .exact("4.0.4")),
        .package(url: "https://github.com/MessageKit/MessageKit", .exact("3.6.0"))
    ],
    targets: [
        .target(
            name: "OnCallKit",
            dependencies: [
                "SnapKit",
                "Bugsnag",
                "SwiftEntryKit",
                "PanModal",
                "Alamofire",
                "PromiseKit",
                "KeychainSwift",
                "Starscream",
                "MessageKit"],
            resources: [
                .process("MobileRTCResources.bundle")]),
        .binaryTarget(
            name: "MobileRTC",
            path: "MobileRTC.xcframework"
        ),
        .testTarget(
            name: "OnCallKitTests",
            dependencies: ["OnCallKit"]),
    ]
)
