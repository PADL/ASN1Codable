// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ASN1Codable",
  platforms: [
    // specify each minimum deployment requirement,
    // otherwise the platform default minimum is used.
    .macOS(.v10_13),
    .iOS(.v12),
    .tvOS(.v12),
    .watchOS(.v4),
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "ASN1Codable",
      targets: ["ASN1Codable"]
    ),
    .executable(
      name: "asn1json2swift",
      targets: ["asn1json2swift"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/PADL/ASN1Kit", branch: "lhoward/pr"),
    .package(url: "https://github.com/PADL/Echo", branch: "fix-release-build"),
    .package(url: "https://github.com/mkrd/Swift-BigInt", branch: "master"),
    .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.7"),
    .package(url: "https://github.com/Carthage/Commandant", from: "0.9.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "ASN1Codable",
      dependencies: ["ASN1Kit", "Echo", .product(name: "BigNumber", package: "Swift-BigInt"), "AnyCodable"]
    ),
    .target(
      name: "HeimASN1Translator",
      dependencies: ["ASN1Kit", "AnyCodable"]
    ),
    .executableTarget(
      name: "asn1json2swift",
      dependencies: ["HeimASN1Translator", "Commandant"],
      path: "Sources/CLI/asn1json2swift"
    ),
  ],
  swiftLanguageVersions: [.v5]
)
