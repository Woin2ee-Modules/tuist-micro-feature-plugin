import Foundation
import ProjectDescription

public protocol MicroFeaturing {
    var interface: Target { get }
    var source: Target { get }
    var testing: Target { get }
    var unitTests: Target { get }
    var uiTests: Target { get }
    var example: Target { get }
}

extension FeatureManifest {
    
    var interfaceName: String { baseName + "Interface" }
    
    var sourceName: String { baseName + "Source" }
    
    var testingName: String { baseName + "Testing" }
    
    var unitTestsName: String { baseName + "UnitTests" }
    
    var uiTestsName: String { baseName + "UITests" }
    
    var exampleName: String { baseName + "Example" }
}

public struct FeatureManifest: MicroFeaturing {
    
    /// The name of the feature. Must be unique.
    let baseName: String
    
    let destinations: Destinations
    
    /// A product type of the source feature.
    let sourceProduct: Product
    
    /// A product type of the only example feature only.
    let exampleProduct: Product?
    
    let deploymentTargets: DeploymentTargets
    
    /// An info plist of the source feature.
    let sourceInfoPlist: InfoPlist?
    
    /// A prefix to use when you want to group source files.
    let preSourceFilesPath: Path?
    
    /// Resource files of interface feature.
    let resourcesForInterface: ResourceFileElements?
    
    /// Resource files of source feature.
    let resourcesForSource: ResourceFileElements?
    
    let sourceEntitlements: Entitlements?
    
    /// It will execute in build phase of the interface feature.
    let scripts: [TargetScript]
    
    /// Dependencies between other features.
    let featureDependencies: [FeatureManifest]
    
    let externalDependencies: [TargetDependency]
    
    /// Dependencies only using test targets.
    let testsDependencies: [TargetDependency]
    
    /// A settings for the source feature only. It is useful when source feature is app product.
    let sourceSettings: Settings?
    
    let testType: TestType?
    
    public init(
        baseName: String,
        destinations: Destinations,
        sourceProduct: Product,
        exampleProduct: Product? = nil,
        deploymentTargets: DeploymentTargets,
        sourceInfoPlist: InfoPlist? = .default,
        preSourceFilesPath: Path? = nil,
        resourcesForInterface: ResourceFileElements? = nil,
        resourcesForSource: ResourceFileElements? = nil,
        sourceEntitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        featureDependencies: [FeatureManifest] = [],
        externalDependencies: [TargetDependency] = [],
        testsDependencies: [TargetDependency] = [],
        sourceSettings: Settings? = nil,
        testType: TestType? = nil
    ) {
        self.baseName = baseName
        self.destinations = destinations
        self.sourceProduct = sourceProduct
        self.exampleProduct = exampleProduct
        self.deploymentTargets = deploymentTargets
        self.sourceInfoPlist = sourceInfoPlist
        self.preSourceFilesPath = preSourceFilesPath
        self.resourcesForInterface = resourcesForInterface
        self.resourcesForSource = resourcesForSource
        self.sourceEntitlements = sourceEntitlements
        self.scripts = scripts
        self.featureDependencies = featureDependencies
        self.externalDependencies = externalDependencies
        self.testsDependencies = testsDependencies
        self.sourceSettings = sourceSettings
        self.testType = testType
    }
    
    public var interface: Target {
        checkIfCanMakeInterfaceOrTestingOrExampleFeatures()
        
        let sources = (preSourceFilesPath?.pathString ?? "") + "/\(baseName)" + "/Interface"
        
        let interfaceTarget = Target.target(
            name: interfaceName,
            destinations: destinations,
            product: .framework,
            productName: nil,
            bundleId: interfaceName,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: resourcesForInterface,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: scripts,
            dependencies: externalDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
        
        return interfaceTarget
    }
    
    public var source: Target {
        let sources = (preSourceFilesPath?.pathString ?? "") + "/\(baseName)" + "/Source"
        let featureTargetDependencies = featureDependencies
            .map(\.interfaceName)
            .map { TargetDependency.target(name: $0) }
        
        let sourceTarget = Target.target(
            name: sourceName,
            destinations: destinations,
            product: sourceProduct,
            productName: nil,
            bundleId: sourceName,
            deploymentTargets: deploymentTargets,
            infoPlist: sourceInfoPlist,
            sources: "\(sources)",
            resources: resourcesForSource,
            copyFiles: nil,
            headers: nil,
            entitlements: sourceEntitlements,
            scripts: [],
            dependencies: featureTargetDependencies + externalDependencies,
            settings: sourceSettings,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
        
        return sourceTarget
    }
    
    public var testing: Target {
        checkIfCanMakeInterfaceOrTestingOrExampleFeatures()
        
        let sources = (preSourceFilesPath?.pathString ?? "") + "/\(baseName)" + "/Testing"
        let featureTargetDependencies = featureDependencies
            .map(\.interfaceName)
            .map { TargetDependency.target(name: $0) }
        
        let testingTarget = Target.target(
            name: testingName,
            destinations: destinations,
            product: .framework,
            productName: nil,
            bundleId: testingName,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: nil,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies + externalDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
        
        return testingTarget
    }
    
    public var unitTests: Target {
        let sources = (preSourceFilesPath?.pathString ?? "") + "/\(baseName)" + "/Tests" + "/UnitTests"
        let featureTargetDependencies = featureDependencies
            .map(\.sourceName)
            .map { TargetDependency.target(name: $0) }
        + featureDependencies
            .map(\.testingName)
            .map { TargetDependency.target(name: $0) }
        
        let unitTestsTarget = Target.target(
            name: unitTestsName,
            destinations: destinations,
            product: .unitTests,
            productName: nil,
            bundleId: unitTestsName,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: nil,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies + externalDependencies + testsDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
        
        return unitTestsTarget
    }
    
    public var uiTests: Target {
        let sources = (preSourceFilesPath?.pathString ?? "") + "/\(baseName)" + "/Tests" + "/UITests"
        let featureTargetDependencies = featureDependencies
            .map(\.sourceName)
            .map { TargetDependency.target(name: $0) }
        + featureDependencies
            .map(\.testingName)
            .map { TargetDependency.target(name: $0) }
        
        let uiTestsTarget = Target.target(
            name: uiTestsName,
            destinations: destinations,
            product: .uiTests,
            productName: nil,
            bundleId: uiTestsName,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: nil,
            copyFiles: [],
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies + externalDependencies + testsDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
        
        return uiTestsTarget
    }
    
    public var example: Target {
        guard let exampleProduct = exampleProduct else {
            fatalError("There isn't specified product for example feature.")
        }
                
        checkIfCanMakeInterfaceOrTestingOrExampleFeatures()
        
        let sources = (preSourceFilesPath?.pathString ?? "") + "/\(baseName)" + "/Example"
        let featureTargetDependencies = featureDependencies
            .map(\.sourceName)
            .map { TargetDependency.target(name: $0) }
        + featureDependencies
            .map(\.testingName)
            .map { TargetDependency.target(name: $0) }
        
        let exampleTarget = Target.target(
            name: exampleName,
            destinations: destinations,
            product: exampleProduct,
            productName: nil,
            bundleId: exampleName,
            deploymentTargets: deploymentTargets,
            infoPlist: iOSExampleInfoPlist,
            sources: "\(sources)",
            resources: nil,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies + externalDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
        
        return exampleTarget
    }
}

// MARK: Helpers
extension FeatureManifest {
    
    private var iOSExampleInfoPlist: InfoPlist {
        .dictionary([
            "CFBundleDevelopmentRegion": "en",
            "CFBundleExecutable": "$(EXECUTABLE_NAME)",
            "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
            "CFBundleInfoDictionaryVersion": "6.0",
            "CFBundleName": "$(PRODUCT_NAME)",
            "CFBundlePackageType": "$(PRODUCT_BUNDLE_PACKAGE_TYPE)",
            "CFBundleShortVersionString": "1.0.0",
            "CFBundleVersion": "1",
            "LSRequiresIPhoneOS": true,
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": false,
                "UISceneConfigurations": [
                    "UIWindowSceneSessionRoleApplication": [
                        [
                            "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                            "UISceneConfigurationName": "DefaultConfiguration"
                        ]
                    ]
                ]
            ],
            "UISupportedInterfaceOrientations": [
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight",
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationPortraitUpsideDown"
            ],
        ])
    }
    
    private func checkIfCanMakeInterfaceOrTestingOrExampleFeatures() {
        let productsAllowedInterface: [Product] = [
            .framework,
            .staticFramework,
            .dynamicLibrary,
            .staticLibrary,
            // Maybe there are more.
        ]
        precondition(productsAllowedInterface.contains(sourceProduct), "It can't make Interface or Testing or Example features with \(sourceProduct).")
    }
}
