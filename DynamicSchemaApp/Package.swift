// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DynamicSchemaApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "DynamicSchemaApp",
            targets: ["DynamicSchemaApp"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "DynamicSchemaApp",
            dependencies: [],
            path: ".",
            exclude: [
                "README.md",
                "Package.swift"
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
