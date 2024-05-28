import ProjectDescription

let config = Config(
    plugins: [
        .local(path: .relativeToRoot("TuistMicroFeaturePlugin"))
//        .git(url: "https://github.com/Woin2ee-Modules/tuist-micro-feature-plugin.git", tag: "0.1.2"),
    ]
)
