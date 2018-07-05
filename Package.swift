// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Machines",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Machines",
            targets: ["Machines"]),
        .library(name: "SwiftMachines",
            targets: ["SwiftMachines"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "ssh://git.mipal.net/git/swift_helpers.git",
        .branch("master")
      )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Machines",
            dependencies: ["swift_helpers", "IO"]),
        .target(
            name: "SwiftMachines",
            dependencies: ["swift_helpers", "Machines", "IO"]),
        .target(
            name: "CXXParser",
            dependencies: ["Machines", "swift_helpers", "Functional"]),
        .testTarget(
            name: "SwiftMachinesTests",
            dependencies: ["SwiftMachines"])
    ]
)
