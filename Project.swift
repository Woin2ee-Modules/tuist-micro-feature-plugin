import ProjectDescription

let project = Project(
    name: "TuistMicroFeaturePlugin",
    targets: [
        Target.target(
            name: "TuistMicroFeaturePlugin",
            destinations: .macOS,
            product: .framework,
            bundleId: "org.woin2ee.TuistMicroFeaturePlugin",
            deploymentTargets: .macOS("14.0"),
            sources: [
                "Plugin.swift",
                "ProjectDescriptionHelpers/**",
            ],
            settings: .settings(base: [
                "FRAMEWORK_SEARCH_PATHS": "$(SRCROOT)"
            ])
        ),
        Target.target(
            name: "TuistMicroFeaturePluginTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "org.woin2ee.TuistMicroFeaturePluginTests",
            deploymentTargets: .macOS("14.0"),
            sources: "Tests/**",
            dependencies: [
                .target(name: "TuistMicroFeaturePlugin"),
            ],
            settings: .settings(base: [
                "FRAMEWORK_SEARCH_PATHS": "$(SRCROOT)",
                "LD_RUNPATH_SEARCH_PATHS": "$(SRCROOT)",
            ])
        ),
    ]
)
