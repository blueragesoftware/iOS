import ProjectDescription

let projectVersion = "1.0.0"

let scheme: Scheme = .scheme(
    name: "AgentOS",
    shared: true,
    hidden: false,
    buildAction: .buildAction(
        targets: ["AgentOS"]
    ),
    testAction: nil,
    runAction: .runAction(arguments:
            .arguments(
                environmentVariables: [
                    "POSTHOG_API_KEY": .environmentVariable(value: "POSTHOG_API_KEY", isEnabled: true),
                    "POSTHOG_HOST": .environmentVariable(value: "https://us.i.posthog.com", isEnabled: true),
                    "SENTRY_DSN": .environmentVariable(value: "SENTRY_DSN", isEnabled: true)
                ]
            )
    ),
    archiveAction: .archiveAction(
        configuration: "Production",
        postActions: [
            .executionAction(
                scriptText: "cd \"${PROJECT_DIR}\"; agvtool bump"
            )
        ]
    ),
    profileAction: nil,
    analyzeAction: nil
)

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
            ],
            settings: .settings(
                base: SettingsDictionary().currentProjectVersion(projectVersion)
            )
        )
    ],
    schemes: [scheme]
)
