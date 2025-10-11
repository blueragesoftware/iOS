import ProjectDescription

let project = Project(
  name: "Bluerage",
  targets: [
    .target(
      name: "Bluerage",
      destinations: [.iPhone, .iPad],
      product: .app,
      bundleId: "$(BUNDLE_ID)",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .extendingDefault(
        with: [
          "ITSAppUsesNonExemptEncryption": false,
          "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
          ],
          "UIBackgroundModes": [
            "remote-notification"
          ],
          "UIAppFonts": [
            "InstrumentSerif-Regular.ttf"
          ],
          "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                "CFBundleURLSchemes": [
                    "$(URL_SCHEME)"
                ],
            ]
          ],
          "UIApplicationSceneManifest": [
            "UISceneConfigurations": [
              "UIWindowSceneSessionRoleApplication": [
                [
                  "UISceneConfigurationName": "Default Configuration",
                  "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                ]
              ]
            ],
            "UIApplicationSupportsMultipleScenes": true,
          ],
          "LSRequiresIPhoneOS": false,
          "CFBundleDisplayName": "$(BUNDLE_DISPLAY_NAME)",
          "CFBundleName": "$(BUNDLE_NAME)",
          "POSTHOG_API_KEY": "$(POSTHOG_API_KEY)",
          "POSTHOG_HOST": "$(POSTHOG_HOST)",
          "SENTRY_DSN": "$(SENTRY_DSN)",
          "CONVEX_DEPLOYMENT_URL": "$(CONVEX_DEPLOYMENT_URL)",
          "CLERK_PUBLISHABLE_KEY": "$(CLERK_PUBLISHABLE_KEY)",
          "KNOCK_PUBLISHABLE_KEY": "$(KNOCK_PUBLISHABLE_KEY)",
          "BUNDLE_ID": "$(BUNDLE_ID)",
          "SENTRY_ORG": "$(SENTRY_ORG)",
          "KNOCK_CHANNEL_ID": "$(KNOCK_CHANNEL_ID)",
          "BUNDLE_DISPLAY_NAME": "$(BUNDLE_DISPLAY_NAME)",
          "BUNDLE_NAME": "$(BUNDLE_NAME)",
          "APP_ICON_ASSET_NAME": "$(APP_ICON_ASSET_NAME)",
          "URL_SCHEME": "$(URL_SCHEME)",
        ]
      ),
      sources: ["Bluerage/Sources/**"],
      resources: [
        "Bluerage/Resources/**",
        "Bluerage/Supporting Files/*.bundle",
      ],
      entitlements: nil,
      scripts: [
        .post(
          script: """
            # This script is responsible for uploading debug symbols and source context for Sentry.
            if which sentry-cli >/dev/null; then
              export SENTRY_ORG=$(SENTRY_ORG)
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
          inputPaths: [
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}"
          ],
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
        .external(name: "MarkdownUI"),
        .external(name: "SVGView"),
        .external(name: "NavigatorUI"),
        .external(name: "SwiftUIIntrospect"),
        .external(name: "Get"),
        .external(name: "Knock"),
        .external(name: "Queue"),
        .external(name: "AsyncAlgorithms"),
      ],
      settings: .settings(
        base: .init()
          .currentProjectVersion("9999")
          .marketingVersion("1.0.0"),
        configurations: [
          .debug(
            name: "Debug",
            xcconfig: "./xcconfigs/Debug.xcconfig"
          ),
          .release(
            name: "Release",
            xcconfig: "./xcconfigs/Release.xcconfig"
          ),
        ],
        defaultSettings: .recommended(excluding: ["ASSETCATALOG_COMPILER_APPICON_NAME"])
      )
    )
  ],
  schemes: [
    .scheme(
      name: "Debug",
      shared: true,
      buildAction: .buildAction(
        targets: [.target("Bluerage")]
      ),
      runAction: .runAction(executable: "Bluerage")
    ),
    .scheme(
      name: "Release",
      shared: true,
      buildAction: .buildAction(
        targets: [.target("Bluerage")]
      ),
      runAction: .runAction(configuration: .release, executable: "Bluerage")
    ),
  ],
  additionalFiles: [
    "entitlements/*.entitlements",
    "xcconfigs/Common.xcconfig",
    "xcconfigs/Debug.xcconfig",
    "xcconfigs/Release.xcconfig",
  ],
  resourceSynthesizers: .default
)
