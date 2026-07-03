// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DesktopDog",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "DesktopDog", targets: ["DesktopDog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "DesktopDog",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
            ],
            path: "Sources/DesktopDog",
            resources: [
                .copy("Resources/Memes"),
                .copy("Resources/Notes"),
                .copy("Resources/dog_animation.json"),
                .copy("Resources/dog_click.json"),
            ],
            linkerSettings: [
                .linkedFramework("AuthenticationServices"),
            ]
        ),
    ]
)
