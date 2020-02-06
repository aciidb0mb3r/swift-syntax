// swift-tools-version:999.0
import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .package(name: "SwiftSyntax", path: "./..")
    ],
    targets: [
        .target(
            name: "Example",
            dependencies: ["SwiftSyntax"]),
    ]
)
