// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ControllerMachine",
    products: [
        .library(
            name: "ControllerMachine",
            type: .dynamic,
            targets: ["ControllerMachine"]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", .branch("swift-4.2")),
        .package(url: "ssh://git.mipal.net/git/swift_wb", .branch("swift-4.2")),
        .package(url: "file:///home/callum/src/MiPal/GUNao/posix/Machines/machines/PingPong.machine/.build/PingPongMachine/", .branch("master")),
        .package(url: "file:///home/callum/src/MiPal/GUNao/posix/Machines/machines/Controller.machine/.build/ControllerMachineBridging/", .branch("master"))
    ],
    targets: [
        .target(name: "ControllerMachine", dependencies: ["GUSimpleWhiteboard", "PingPongMachine"])
    ]
)
