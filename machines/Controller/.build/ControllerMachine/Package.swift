import PackageDescription
let packages = Package(
    name: "ControllerMachine",
    dependencies: [
        .Package(url: "ssh://git.mipal.net/git/CGUSimpleWhiteboard", majorVersion: 1),
        .Package(url: "%machines_tests%/PingPong.machine/.build/PingPongMachine", majorVersion: 0),
        .Package(url: "%machines_tests%/Controller.machine/.build/ControllerMachineBridging", majorVersion: 0)
    ]
)

products.append(
    Product(
        name: "ControllerMachine",
        type: .Library(.Dynamic),
        modules: ["ControllerMachine"]
    )
)
