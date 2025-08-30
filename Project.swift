import ProjectDescription

let projectVersion = "1.0.0"

let project = Project(
    name: "AgentOS",
    targets: [
        .target(
            name: "AgentOS",
            destinations: .iOS,
            product: .app,
            bundleId: "com.ertembiyik.AgentOSS",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIAppFonts": [
                        "InstrumentSerif-Regular.ttf"
                    ],
                    "POSTHOG_API_KEY": "$(POSTHOG_API_KEY)",
                    "POSTHOG_HOST": "$(POSTHOG_HOST)",
                    "SENTRY_DSN": "$(SENTRY_DSN)",
                    "CONVEX_DEPLOYMENT_URL": "$(CONVEX_DEPLOYMENT_URL)",
                    "CLERK_PUBLISHABLE_KEY": "$(CLERK_PUBLISHABLE_KEY)",
                ]
            ),
            sources: ["AgentOS/Sources/**"],
            resources: ["AgentOS/Resources/**"],
            entitlements: nil,
            dependencies: [
                .external(name: "ConvexMobile"),
                .external(name: "FactoryKit"),
                .external(name: "Nuke"),
                .external(name: "NukeUI"),
                .external(name: "PinLayout"),
                .external(name: "PostHog"),
                .external(name: "Sentry"),
                .external(name: "Shimmer"),
                .external(name: "Clerk")
            ],
            settings: .settings(
                base: SettingsDictionary().currentProjectVersion(projectVersion),
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: ["CODE_SIGN_ENTITLEMENTS": "entitlements/Debug.entitlements"],
                        xcconfig: "./xcconfigs/Config.xcconfig"
                    ),
                    .release(
                        name: "Release",
                        settings: ["CODE_SIGN_ENTITLEMENTS": "entitlements/Release.entitlements"],
                        xcconfig: "./xcconfigs/Config.xcconfig"
                    )
                ]
            )
        )
    ],
    additionalFiles: [
        "entitlements/Debug.entitlements",
        "entitlements/Release.entitlements"
    ]
)

