import PackageDescription

let package = Package(
    name: "chaitools",
    targets: [
        Target(name: "chaitools", dependencies: ["ChaiToolsKit"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/jakeheis/SwiftCLI", majorVersion: 2, minor: 0)
    ]
)
