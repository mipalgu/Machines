// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PingPongMachine",
    products: [
        .library(
            name: "PingPongMachine",
            type: .dynamic,
            targets: ["PingPongMachine"]
        )
    ],
    dependencies: [
        .package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", .branch("swift-4.2")),
        .package(url: "ssh://git.mipal.net/git/swift_wb", .branch("swift-4.2"))
    ],
    targets: [
        .target(name: "PingPongMachine", dependencies: ["GUSimpleWhiteboard"])
    ]
)
