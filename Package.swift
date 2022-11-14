// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ASN1Codable",
    platforms: [
        // specify each minimum deployment requirement,
        //otherwise the platform default minimum is used.
       .macOS(.v10_12),
       .iOS(.v9),
       .tvOS(.v9),
       .watchOS(.v2)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ASN1Codable",
            targets: ["ASN1Codable"]),
        .executable(
            name: "cert2json",
            targets: ["cert2json", "ASN1Codable"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/PADL/ASN1Kit", .branch("lhoward/pr")),
        .package(url: "https://github.com/Azoy/Echo", .branch("main")),
        .package(url: "https://github.com/mkrd/Swift-BigInt", .branch("master")),
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.7"),
        .package(url: "https://github.com/Carthage/Commandant", from: "0.9.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ASN1Codable",
            dependencies: ["ASN1Kit", "Echo", .product(name: "BigNumber", package: "Swift-BigInt"), "AnyCodable"]),
        .target(
            name: "cert2json",
            dependencies: ["ASN1Codable", "Commandant", .product(name: "Algorithms", package: "swift-algorithms")],
            path: "Sources/CLI/cert2json")
    ],
    swiftLanguageVersions: [.v5]
)
