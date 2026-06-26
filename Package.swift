// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DesktopGoose",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "DesktopGoose", targets: ["DesktopGoose"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "DesktopGoose",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "Sources/DesktopGoose",
            resources: [
                .copy("Resources/Memes"),
                .copy("Resources/Notes"),
                .copy("Resources/dog_animation.json"),
                .copy("Resources/dog_click.json"),
            ]
        ),
    ]
)
