// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OptTab",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "OptTab", targets: ["OptTab"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "OptTab",
            dependencies: [],
            path: "Sources"
        )
    ]
)
