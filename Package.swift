// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppConnectSDK",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppConnectSDK",
            targets: ["AppConnectSDKSwift", "AppConnectSDKObjC"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppConnectSDKSwift",
            path: "Sources/AppConnectSDKSwift"
        ),
        .target(
            name: "AppConnectSDKObjC",
            path: "Sources/AppConnectSDKObjC",
            publicHeadersPath: "headers"
        ),
//        .testTarget(
//            name: "AppConnectSDKTests",
//            dependencies: ["AppConnectSDK"]),
    ]
)


//products: [
//    .library(
//        name: "MyLibrary",
//        targets: ["MyLibrarySwift", "MyLibraryObjC"]),
//],
//.target(name: "MyLibraryObjC",
//        path: "Sources/MyLibraryObjC"
//),
//.target(name: "MyLibrarySwift",
//        path: "Sources/MyLibrarySwift"
//)
