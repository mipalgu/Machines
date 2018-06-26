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
        .package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", .branch("master"))
    ],
    targets: [
        .target(name: "PingPongMachine", dependencies: [])
    ]
)
