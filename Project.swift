import ProjectDescription

let projectVersion = "1.0.0"

let project = Project(
    name: "AgentOS",
    targets: [
        .target(
            name: "AgentOS",
            destinations: .iOS,
            product: .app,
            bundleId: "com.ertembiyik.AgentOS",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "POSTHOG_API_KEY": "$(POSTHOG_API_KEY)",
                    "POSTHOG_HOST": "$(POSTHOG_HOST)",
                    "SENTRY_DSN": "$(SENTRY_DSN)",
                    "CONVEX_DEPLOYMENT_URL": "$(CONVEX_DEPLOYMENT_URL)"
                ]
            ),
            sources: ["AgentOS/Sources/**"],
            resources: ["AgentOS/Resources/**"],
            dependencies: [
                .external(name: "ConvexMobile"),
                .external(name: "FactoryKit"),
                .external(name: "Nuke"),
                .external(name: "PinLayout"),
                .external(name: "PostHog"),
                .external(name: "Sentry"),
                .external(name: "Shimmer"),
            ],
            settings: .settings(
                base: SettingsDictionary().currentProjectVersion(projectVersion),
                configurations: [
                    .debug(name: "Debug", xcconfig: "./xcconfigs/Config.xcconfig"),
                    .release(name: "Release", xcconfig: "./xcconfigs/Config.xcconfig")
                ]
            )
        )
    ]
)
