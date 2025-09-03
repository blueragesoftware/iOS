import ProjectDescription

let project = Project(
    name: "Bluerage",
    targets: [
        .target(
            name: "Bluerage",
            destinations: .iOS,
            product: .app,
            bundleId: bundleId(),
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
            sources: ["Bluerage/Sources/**"],
            resources: ["Bluerage/Resources/**"],
            entitlements: nil,
            scripts: [
                .post(
                    script: """
# This script is responsible for uploading debug symbols and source context for Sentry.
if which sentry-cli >/dev/null; then
  export SENTRY_ORG=\(sentryOrg())
  export SENTRY_PROJECT=apple-ios
  ERROR=$(sentry-cli debug-files upload --include-sources "$DWARF_DSYM_FOLDER_PATH" 2>&1 >/dev/null)
  if [ ! $? -eq 0 ]; then
    echo "warning: sentry-cli - $ERROR"
  fi
else
  echo "warning: sentry-cli not installed, download from https://github.com/getsentry/sentry-cli/releases"
fi
""",
                    name: "Upload Debug Symbols to Sentry",
                    inputPaths: ["${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}"],
                    basedOnDependencyAnalysis: true,
                )
            ],
            dependencies: [
                .external(name: "ConvexMobile"),
                .external(name: "FactoryKit"),
                .external(name: "Nuke"),
                .external(name: "NukeUI"),
                .external(name: "PinLayout"),
                .external(name: "PostHog"),
                .external(name: "Sentry"),
                .external(name: "Shimmer"),
                .external(name: "Clerk"),
                .external(name: "SVGKit"),
                .external(name: "Queue")
            ],
            settings: .settings(
                base: SettingsDictionary()
                    .currentProjectVersion("1.0.0")
                    .otherLinkerFlags(["-ObjC"]),
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

func bundleId() -> String {
    if case let .string(environmentAppName) = Environment.bundleId {
        return environmentAppName
    } else {
        fatalError("Bundle id env param should be set via TUIST_BUNDLE_ID=")
    }
}

func sentryOrg() -> String {
    if case let .string(environmentSentryOrg) = Environment.sentryOrg {
        return environmentSentryOrg
    } else {
        fatalError("Sentry org env param should be set via TUIST_SENTRY_ORG=")
    }
}
