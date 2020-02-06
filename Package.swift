// swift-tools-version:999.0
import PackageDescription
import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

let package = Package(
  name: "SwiftSyntax",
  targets: [
    .target(name: "_CSwiftSyntax", exclude: ["README.md"]),
    .testTarget(name: "SwiftSyntaxTest", dependencies: ["SwiftSyntax"], exclude: ["Inputs"]),
    .target(
        name: "SwiftSyntaxBuilder",
        dependencies: ["SwiftSyntax"],
        exclude: ["README.md"]
    ),
    .testTarget(name: "SwiftSyntaxBuilderTest", dependencies: ["SwiftSyntaxBuilder"]),
    .target(name: "lit-test-helper", dependencies: ["SwiftSyntax"]),
    .testTarget(name: "PerformanceTest", dependencies: ["SwiftSyntax"]),
    .binaryTarget(name: "_InternalSwiftSyntaxParser", path: "Sources/_InternalSwiftSyntaxParser/_InternalSwiftSyntaxParser.xcframework"),
    // Also see targets added below
  ]
)

let swiftSyntaxTarget: PackageDescription.Target

/// If we are in a controlled CI environment, we can use internal compiler flags
/// to speed up the build or improve it.
if getenv("SWIFT_BUILD_SCRIPT_ENVIRONMENT") != nil {
  let groupFile = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("utils")
    .appendingPathComponent("group.json")

  var swiftSyntaxUnsafeFlags = ["-Xfrontend", "-group-info-path",
                                "-Xfrontend", groupFile.path]
  // Enforcing exclusivity increases compile time of release builds by 2 minutes.
  // Disable it when we're in a controlled CI environment.
  swiftSyntaxUnsafeFlags += ["-enforce-exclusivity=unchecked"]

  swiftSyntaxTarget = .target(name: "SwiftSyntax", dependencies: ["_CSwiftSyntax"],
                              swiftSettings: [.unsafeFlags(swiftSyntaxUnsafeFlags)]
  )
} else {
  swiftSyntaxTarget = .target(
      name: "SwiftSyntax", 
      dependencies: ["_CSwiftSyntax", "_InternalSwiftSyntaxParser"],
      exclude: [
          "SyntaxNodes.swift.gyb.template",
          "SyntaxFactory.swift.gyb",
          "SyntaxEnum.swift.gyb",
          "Trivia.swift.gyb",
          "SyntaxBuilders.swift.gyb",
          "SyntaxCollections.swift.gyb",
          "SyntaxClassification.swift.gyb",
          "SyntaxBaseNodes.swift.gyb",
          "SyntaxTraits.swift.gyb",
          "SyntaxVisitor.swift.gyb",
          "SyntaxRewriter.swift.gyb",
          "SyntaxKind.swift.gyb",
          "TokenKind.swift.gyb",
          "SyntaxAnyVisitor.swift.gyb",
          "Misc.swift.gyb",
      ]
  )
}

package.targets.append(swiftSyntaxTarget)

let libraryType: Product.Library.LibraryType

/// When we're in a build-script environment, we want to build a dylib instead
/// of a static library since we install the dylib into the toolchain.
if getenv("SWIFT_BUILD_SCRIPT_ENVIRONMENT") != nil {
  libraryType = .dynamic
} else {
  libraryType = .static
}

package.products.append(.library(name: "SwiftSyntax", type: libraryType, targets: ["SwiftSyntax"]))
package.products.append(.library(name: "SwiftSyntaxBuilder", type: libraryType, targets: ["SwiftSyntaxBuilder"]))
