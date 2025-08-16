import ProjectDescription

let project = Project(
    name: "AgentOS",
    targets: [
        .target(
            name: "AgentOS",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.AgentOS",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["AgentOS/Sources/**"],
            resources: ["AgentOS/Resources/**"],
            dependencies: [
                .external(name: "ConvexMobile"),
                .external(name: "Factory"),
                .external(name: "Nuke"),
                .external(name: "PinLayout"),
                .external(name: "PostHog"),
                .external(name: "Sentry"),
                .external(name: "Shimmer"),
            ]
        ),
        .target(
            name: "AgentOSTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.AgentOSTests",
            infoPlist: .default,
            sources: ["AgentOS/Tests/**"],
            resources: [],
            dependencies: [.target(name: "AgentOS")]
        ),
    ]
)
