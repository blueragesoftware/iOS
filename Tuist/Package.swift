// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: ["MarkdownUI": .framework]
    )
#endif

let package = Package(
    name: "Bluerage",
    dependencies: [
        .package(url: "https://github.com/blueragesoftware/convex-swift", branch: "main"),
        .package(url: "https://github.com/hmlongco/Factory", from: "2.5.3"),
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
        .package(url: "https://github.com/layoutBox/PinLayout", from: "1.10.6"),
        .package(url: "https://github.com/PostHog/posthog-ios", from: "3.30.1"),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.55.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.5.1"),
        .package(url: "https://github.com/blueragesoftware/clerk-ios", branch: "main"),
        .package(url: "https://github.com/exyte/SVGView", from: "1.0.6"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui.git", from: "2.4.1"),
        .package(url: "https://github.com/hmlongco/Navigator", from: "1.2.2"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "26.0.0"),
        .package(url: "https://github.com/kean/Get", from: "2.2.1"),
        .package(url: "https://github.com/knocklabs/knock-swift", from: "1.2.4"),
        .package(url: "https://github.com/mattmassicotte/Queue", from: "0.2.2"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.4")
    ]
)
