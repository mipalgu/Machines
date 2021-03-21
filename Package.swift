// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Machines",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "Machines", targets: ["Machines", "SwiftMachines", "CXXMachines"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "ssh://git.mipal.net/Users/Shared/git/swift_helpers.git",
        .branch("master")
      )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "XMI",
            dependencies: []
        ),
        .target(
            name: "Attributes",
            dependencies: ["XMI", "swift_helpers"]
        ),
        .target(
            name: "SwiftMachines",
            dependencies: ["swift_helpers", .product(name: "IO", package: "swift_helpers")]
        ),
        .target(
            name: "CXXMachines",
            dependencies: [.product(name: "swift_helpers", package: "swift_helpers"), .product(name: "Functional", package: "swift_helpers")]
        ),
        .target(
            name: "VHDLMachines",
            dependencies: ["swift_helpers"]
        ),
        .target(
            name: "CXXBase",
            dependencies: []
        ),
        .target(
            name: "UCFSMMachines",
            dependencies: ["CXXBase"]
        ),
        .target(
            name: "Machines",
            dependencies: ["swift_helpers", .product(name: "IO", package: "swift_helpers"), .product(name: "Functional", package: "swift_helpers"), "SwiftMachines", "CXXMachines", "XMI", "VHDLMachines", "Attributes", "UCFSMMachines"]
        ),
        .testTarget(name: "AttributesTests", dependencies: ["Attributes"]),
        .testTarget(
            name: "SwiftMachinesTests",
            dependencies: ["SwiftMachines"]
        ),
        .testTarget(
            name: "UCFSMMachinesTests",
            dependencies: ["UCFSMMachines"]
        ),
        .testTarget(name: "MachinesTests",
            dependencies: ["Machines", "XMI"]
        )
    ]
)
