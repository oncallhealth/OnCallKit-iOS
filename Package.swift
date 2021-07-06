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
        .package(url: "https://github.com/slackhq/PanModal", .exact("1.2.7")),
        .package(url: "https://github.com/Alamofire/Alamofire", .exact("5.4.2")),
        .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.15.3")),
        .package(url: "https://github.com/daltoniam/Starscream", .exact("4.0.4")),
        .package(url: "https://github.com/MessageKit/MessageKit", .exact("3.6.0")),
        .package(name: "Material Components iOS", url: "https://github.com/DomenicBianchi01/material-components-ios", .exact("110.0.0")),
        .package(url: "https://github.com/Minitour/EasyNotificationBadge", .exact("1.2.5"))
    ],
    targets: [
        .target(
            name: "OnCallKit",
            dependencies: [
                "SnapKit",
                "PanModal",
                "Alamofire",
                "PromiseKit",
                "Starscream",
                "MessageKit",
                "EasyNotificationBadge",
                .product(name: "MaterialComponents", package: "Material Components iOS")
            ]
        .binaryTarget(
            name: "MobileRTC",
            path: "MobileRTC.xcframework"
        ),
        .testTarget(
            name: "OnCallKitTests",
            dependencies: ["OnCallKit"]),
    ]
)
