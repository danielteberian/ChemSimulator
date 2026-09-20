// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChemLab",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "ChemLabCore", targets: ["ChemLabCore"]),
        .library(name: "ChemLabUI", targets: ["ChemLabUI"]),
        .executable(name: "ChemLab", targets: ["ChemLab"]),
    ],
    targets: [
        // Chemistry logic. No UI dependency.
        .target(name: "ChemLabCore"),
        // SwiftUI views shared by the macOS and iOS apps.
        .target(name: "ChemLabUI", dependencies: ["ChemLabCore"]),
        // macOS app, runnable with `swift run`. The iOS app (Xcode) imports ChemLabUI too.
        .executableTarget(name: "ChemLab", dependencies: ["ChemLabUI"]),
        .testTarget(name: "ChemLabCoreTests", dependencies: ["ChemLabCore"]),
        .testTarget(name: "ChemLabUITests", dependencies: ["ChemLabUI", "ChemLabCore"]),
    ]
)
