import MicroFeaturePlugin
import ProjectDescription

let iOSDeploymentTargets = DeploymentTargets.iOS("17.0")
let baseBundleID = "TuistMicroFeaturePluginExample"

let firstService = FeatureManifest(
    baseName: "FirstService",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: iOSDeploymentTargets,
    sourceFilesGroupPath: "Services",
    adoptedModules: [.interface, .source, .testing, .unitTests]
)

let firstUseCase = FeatureManifest(
    baseName: "FirstUseCase",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: iOSDeploymentTargets,
    sourceFilesGroupPath: "UseCases",
    featureDependencies: [
        firstService,
    ],
    adoptedModules: [.interface, .source, .unitTests]
)

let secondUseCase = FeatureManifest(
    baseName: "SecondUseCase",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: iOSDeploymentTargets,
    sourceFilesGroupPath: "UseCases",
    adoptedModules: [.interface, .source, .testing, .unitTests]
)

let iOSSupport = FeatureManifest(
    baseName: "IOSSupport",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: iOSDeploymentTargets,
    adoptedModules: [.source, .unitTests]
)

let iOSHomeSceneFeature = FeatureManifest(
    baseName: "IOSHomeScene",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: iOSDeploymentTargets,
    sourceFilesGroupPath: "IOSScenes",
    featureDependencies: [
        iOSSupport,
        firstUseCase,
        secondUseCase,
    ],
    adoptedModules: [.source, .unitTests, .example(product: .app)]
)

let iOSLoginSceneFeature = FeatureManifest(
    baseName: "IOSLoginScene",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: iOSDeploymentTargets,
    sourceFilesGroupPath: "IOSScenes",
    featureDependencies: [
        iOSSupport,
        firstUseCase,
    ],
    adoptedModules: [.source, .unitTests, .example(product: .app)]
)

let iOSAppFeature = FeatureManifest(
    baseName: "IOSAppFeature",
    baseBundleID: baseBundleID,
    destinations: .iOS,
    sourceProduct: .app,
    deploymentTargets: iOSDeploymentTargets,
    sourceInfoPlist: .file(path: .relativeToManifest("Resources/InfoPlist/Info.plist")),
    resourcesForSource: .resources([
        .glob(pattern: .relativeToManifest("Resources/Common/**")),
    ]),
    featureDependencies: [
        iOSLoginSceneFeature,
        iOSHomeSceneFeature,
    ],
    adoptedModules: [.source]
)


let project = Project(
    name: "TuistMicroFeaturePluginExample",
    targets: [
        iOSSupport.source,
        iOSSupport.unitTests,
        
        iOSHomeSceneFeature.source,
        iOSHomeSceneFeature.unitTests,
        iOSHomeSceneFeature.example,
        
        iOSLoginSceneFeature.source,
        iOSLoginSceneFeature.unitTests,
        iOSLoginSceneFeature.example,
    ]
    + firstService.resolveModules()
    + firstUseCase.resolveModules()
    + secondUseCase.resolveModules()
    + iOSAppFeature.resolveModules()
)
