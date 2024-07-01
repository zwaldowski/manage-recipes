// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "manage-recipes",
    platforms: [ .macOS(.v13) ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/zwaldowski/HTML", branch: "main"),
        .package(url: "https://github.com/zwaldowski/NotesArchive", branch: "main"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "manage-recipes",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "HTMLAttributedString", package: "HTML"),
                .product(name: "NotesArchive", package: "NotesArchive"),
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios")
            ]
        ),
    ]
)
