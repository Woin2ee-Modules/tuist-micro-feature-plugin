import Foundation
import ProjectDescription

public protocol MicroFeaturing {
    
    /// A interface module.
    ///
    /// If the `interface` module is not adopted in the `FeatureManifest`, a fatal error is occured.
    ///
    /// - Note: It's recommended that you use `resolveModules()` method instead of using this property directly.
    var interface: Target { get }
    
    /// A source module.
    ///
    /// If the `source` module is not adopted in the `FeatureManifest`, a fatal error is occured.
    ///
    /// - Note: It's recommended that you use `resolveModules()` method instead of using this property directly.
    var source: Target { get }
    
    /// A testing module.
    ///
    /// If the `testing` module is not adopted in the `FeatureManifest`, a fatal error is occured.
    ///
    /// - Note: It's recommended that you use `resolveModules()` method instead of using this property directly.
    var testing: Target { get }
    
    /// A unit tests module.
    ///
    /// If the `unitTests` module is not adopted in the `FeatureManifest`, a fatal error is occured.
    ///
    /// - Note: It's recommended that you use `resolveModules()` method instead of using this property directly.
    var unitTests: Target { get }
    
    /// A ui tests module.
    ///
    /// If the `uiTests` module is not adopted in the `FeatureManifest`, a fatal error is occured.
    ///
    /// - Note: It's recommended that you use `resolveModules()` method instead of using this property directly.
    var uiTests: Target { get }
    
    /// A example module.
    ///
    /// If the `example` module is not adopted in the `FeatureManifest`, a fatal error is occured.
    ///
    /// - Note: It's recommended that you use `resolveModules()` method instead of using this property directly.
    var example: Target { get }
}

public struct FeatureManifest {
    
    /// The name of the feature. Must be unique.
    let baseName: String
    
    /// A base bundle ID that will be prefix of feature's all modules.
    /// For example, `"com.tuist.micro-feature-plugin"`
    let baseBundleID: String
    
    let destinations: Destinations
    
    /// A product type of the source module.
    let sourceProduct: Product
    
    let deploymentTargets: DeploymentTargets
    
    /// An info plist of the source module.
    let sourceInfoPlist: InfoPlist?
    
    /// A group path that you can specify when you want to group source files.
    /// For example: `"Scenes"` or `"IOS/Scenes"`
    let sourceFilesGroupPath: String?
    
    /// Resource files of interface module.
    let resourcesForInterface: ResourceFileElements?
    
    /// Resource files of source module.
    let resourcesForSource: ResourceFileElements?
    
    let sourceEntitlements: Entitlements?
    
    /// It will execute in build phase of the interface module.
    let scripts: [TargetScript]
    
    /// Dependencies between the other features.
    let featureDependencies: [FeatureManifest]
    
    let basicDependencies: [TargetDependency]
    
    /// Dependencies only using test targets.
    let testsDependencies: [TargetDependency]
    
    /// A settings for the source module only. It is useful when source module is app product.
    let sourceSettings: Settings?
    
    /// The modules this feature uses.
    let adoptedModules: Set<MicroFeatureModuleType>
    
    /// - Parameters:
    ///   - baseName: The name of the feature. Must be unique.
    ///   - baseBundleID: The bundle ID to place before the each module name.
    ///   - destinations: .
    ///   - sourceProduct: A product type of the source module.
    ///   - exampleProduct: A product type of the only example module only.
    ///   - deploymentTargets: .
    ///   - sourceInfoPlist: An info plist of the source module.
    ///   - sourceFilesGroupPath: A prefix to use when you want to group source files.
    ///   - resourcesForInterface: Resource files of interface module.
    ///   - resourcesForSource: Resource files of source module.
    ///   - sourceEntitlements: .
    ///   - scripts: It will execute in build phase of the interface module.
    ///   - featureDependencies: Dependencies between the other features.
    ///   - basicDependencies: Dependencies that all modules depend on.
    ///   - testsDependencies: Dependencies only using test targets.
    ///   - sourceSettings: A settings for the source module only. It is useful when source module is app product.
    ///   - adoptedModules: The modules this feature uses.
    public init(
        baseName: String,
        baseBundleID: String,
        destinations: Destinations,
        sourceProduct: Product,
        deploymentTargets: DeploymentTargets,
        sourceInfoPlist: InfoPlist? = .default,
        sourceFilesGroupPath: String? = nil,
        resourcesForInterface: ResourceFileElements? = nil,
        resourcesForSource: ResourceFileElements? = nil,
        sourceEntitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        featureDependencies: [FeatureManifest] = [],
        basicDependencies: [TargetDependency] = [],
        testsDependencies: [TargetDependency] = [],
        sourceSettings: Settings? = nil,
        adoptedModules: Set<MicroFeatureModuleType>
    ) {
        self.baseName = baseName
        self.baseBundleID = baseBundleID
        self.destinations = destinations
        self.sourceProduct = sourceProduct
        self.deploymentTargets = deploymentTargets
        self.sourceInfoPlist = sourceInfoPlist
        self.sourceFilesGroupPath = sourceFilesGroupPath
        self.resourcesForInterface = resourcesForInterface
        self.resourcesForSource = resourcesForSource
        self.sourceEntitlements = sourceEntitlements
        self.scripts = scripts
        self.featureDependencies = featureDependencies
        self.basicDependencies = basicDependencies
        self.testsDependencies = testsDependencies
        self.sourceSettings = sourceSettings
        self.adoptedModules = adoptedModules
    }
}

// MARK: Modules' names
extension FeatureManifest {
    
    var interfaceName: String { baseName + "Interface" }
    
    var sourceName: String { baseName + "Source" }
    
    var testingName: String { baseName + "Testing" }
    
    var unitTestsName: String { baseName + "UnitTests" }
    
    var uiTestsName: String { baseName + "UITests" }
    
    var exampleName: String { baseName + "Example" }
}

// MARK: Adopts MicroFeaturing
extension FeatureManifest: MicroFeaturing {
    
    public var interface: Target {
        guard hasInterfaceModule else { fatalError("🛑 \(baseName) feature don't have interface module.") }
        checkIfSourceModuleIsFrameworkOrLibrary()
        
        let bundleID = baseBundleID + "." + interfaceName.toValidInBundleIdentifier()
        var sources = "Sources"
        if let sourceFilesGroupPath = sourceFilesGroupPath {
            sources += "/\(sourceFilesGroupPath)"
        }
        sources += "/\(baseName)/Interface/**"
        
        return Target.target(
            name: interfaceName,
            destinations: destinations,
            product: .framework,
            productName: nil,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: resourcesForInterface,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: scripts,
            dependencies: basicDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
    }
    
    public var source: Target {
        guard hasSourceModule else { fatalError("🛑 \(baseName) feature don't have source module.") }
        
        let bundleID = baseBundleID + "." + sourceName.toValidInBundleIdentifier()
        var sources = "Sources"
        if let sourceFilesGroupPath = sourceFilesGroupPath {
            sources += "/\(sourceFilesGroupPath)"
        }
        sources += "/\(baseName)/Source/**"
        
        var dependencies = featureDependencies
            .map { $0.hasInterfaceModule ? $0.interfaceName : $0.sourceName }
            .map { TargetDependency.target(name: $0) }
        if hasInterfaceModule {
            dependencies.append(TargetDependency.target(name: interfaceName))
        } else {
            dependencies += basicDependencies
        }
        
        return Target.target(
            name: sourceName,
            destinations: destinations,
            product: sourceProduct,
            productName: nil,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: sourceInfoPlist,
            sources: "\(sources)",
            resources: resourcesForSource,
            copyFiles: nil,
            headers: nil,
            entitlements: sourceEntitlements,
            scripts: [],
            dependencies: dependencies,
            settings: sourceSettings,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
    }
    
    public var testing: Target {
        guard hasTestingModule else { fatalError("🛑 \(baseName) feature don't have testing module.") }
        guard hasInterfaceModule else {
            fatalError("🛑 \(baseName) feature requires interface module to have testing module.")
        }
        checkIfSourceModuleIsFrameworkOrLibrary()
        
        let bundleID = baseBundleID + "." + testingName.toValidInBundleIdentifier()
        var sources = "Sources"
        if let sourceFilesGroupPath = sourceFilesGroupPath {
            sources += "/\(sourceFilesGroupPath)"
        }
        sources += "/\(baseName)/Testing/**"
        
        let featureTargetDependencies = [TargetDependency.target(name: interfaceName)]
        
        return Target.target(
            name: testingName,
            destinations: destinations,
            product: .framework,
            productName: nil,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: nil,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
    }
    
    public var unitTests: Target {
        guard hasUnitTestsModule else { fatalError("🛑 \(baseName) feature don't have unit tests module.") }
        guard hasSourceModule else {
            fatalError("🛑 \(baseName) feature requires source module to have unit tests module.")
        }
        
        let bundleID = baseBundleID + "." + unitTestsName.toValidInBundleIdentifier()
        var sources = "Sources"
        if let sourceFilesGroupPath = sourceFilesGroupPath {
            sources += "/\(sourceFilesGroupPath)"
        }
        sources += "/\(baseName)/Tests/UnitTests/**"
        
        var featureTargetDependencies = [TargetDependency.target(name: sourceName)]
        
        featureDependencies.forEach { featureDependency in
            resolveAllDescendants(of: featureDependency, to: &featureTargetDependencies)
        }
        
        return Target.target(
            name: unitTestsName,
            destinations: destinations,
            product: .unitTests,
            productName: nil,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: nil,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies + testsDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
    }
    
    public var uiTests: Target {
        guard hasUITestsModule else { fatalError("🛑 \(baseName) feature don't have ui tests module.") }
        
        let bundleID = baseBundleID + "." + uiTestsName.toValidInBundleIdentifier()
        var sources = "Sources"
        if let sourceFilesGroupPath = sourceFilesGroupPath {
            sources += "/\(sourceFilesGroupPath)"
        }
        sources += "/\(baseName)/Tests/UITests/**"
        
        var featureTargetDependencies = [TargetDependency.target(name: sourceName)]
        
        featureDependencies.forEach { featureDependency in
            resolveAllDescendants(of: featureDependency, to: &featureTargetDependencies)
        }
        
        return Target.target(
            name: uiTestsName,
            destinations: destinations,
            product: .uiTests,
            productName: nil,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: "\(sources)",
            resources: nil,
            copyFiles: [],
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies + testsDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
    }
    
    public var example: Target {
        // It's duplicate checking with below guard-let, also keep it as comment due to explicit.
//        guard hasExampleModule else { fatalError("🛑 \(baseName) feature don't have example module.") }
        guard let exampleProduct = exampleProduct else {
            fatalError("🛑 There isn't specified product for example module.")
        }
        
        checkIfSourceModuleIsFrameworkOrLibrary()
        
        let bundleID = baseBundleID + "." + exampleName.toValidInBundleIdentifier()
        var sources = "Sources"
        if let sourceFilesGroupPath = sourceFilesGroupPath {
            sources += "/\(sourceFilesGroupPath)"
        }
        sources += "/\(baseName)/Example/**"
        
        var featureTargetDependencies = [TargetDependency.target(name: sourceName)]
        + featureDependencies
            .map(\.sourceName)
            .map { TargetDependency.target(name: $0) }
        + featureDependencies
            .compactMap { $0.hasTestingModule ? $0.testingName : nil }
            .map { TargetDependency.target(name: $0) }
        if hasTestingModule {
            featureTargetDependencies.append(TargetDependency.target(name: testingName))
        }
        
        return Target.target(
            name: exampleName,
            destinations: destinations,
            product: exampleProduct,
            productName: nil,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: iOSExampleInfoPlist,
            sources: "\(sources)",
            resources: nil,
            copyFiles: nil,
            headers: nil,
            entitlements: nil,
            scripts: [],
            dependencies: featureTargetDependencies,
            settings: nil,
            coreDataModels: [],
            environmentVariables: [:],
            launchArguments: [],
            additionalFiles: [],
            buildRules: [],
            mergedBinaryType: .disabled,
            mergeable: false
        )
    }
}

// MARK: Helpers

extension FeatureManifest {
    
    var hasInterfaceModule: Bool {
        adoptedModules.contains(.interface)
    }
    
    var hasSourceModule: Bool {
        adoptedModules.contains(.source)
    }
    
    var hasTestingModule: Bool {
        adoptedModules.contains(.testing)
    }
    
    var hasUnitTestsModule: Bool {
        adoptedModules.contains(.unitTests)
    }
    
    var hasUITestsModule: Bool {
        adoptedModules.contains(.uiTests)
    }
    
    var hasExampleModule: Bool {
        return adoptedModules.contains(where: {
            if case MicroFeatureModuleType.example = $0 {
                return true
            } else {
                return false
            }
        })
    }
    
    var exampleProduct: Product? {
        let exampleModuleProducts = adoptedModules.compactMap { adoptedModule -> Product? in
            if case .example(let product) = adoptedModule {
                return product
            }
            return nil
        }
        
        precondition(exampleModuleProducts.count <= 1, "You can't specify an example product more than one.")
        
        return exampleModuleProducts.first
    }
    
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
            "CFBundleLocalizations": [
                "en",
                "ko",
                "zh",
                "de",
                "it",
                "fr",
                "ja",
            ],
            "UISupportedInterfaceOrientations": [
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight",
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationPortraitUpsideDown"
            ],
            "UILaunchStoryboardName": "",
        ])
    }
    
    private func checkIfSourceModuleIsFrameworkOrLibrary() {
        let products: [Product] = [
            .framework,
            .staticFramework,
            .dynamicLibrary,
            .staticLibrary,
            .macro,
            // Maybe there are more.
        ]
        precondition(products.contains(sourceProduct), "🛑 It can't make Interface or Testing or Example modules with \(sourceProduct).")
    }
    
    /// `featureDependency`의 모든 하위 종속성에 대해 Source module과 Testing module을 `dependencies`에 추가합니다.
    private func resolveAllDescendants(
        of featureDependency: FeatureManifest,
        to dependencies: inout [TargetDependency]
    ) {
        guard featureDependency.hasSourceModule else {
            logger.error("🛑 \(featureDependency.baseName) feature don't have source module.")
            return
        }
        
        dependencies.append(TargetDependency.target(name: featureDependency.sourceName))
        
        if featureDependency.hasTestingModule {
            dependencies.append(TargetDependency.target(name: featureDependency.testingName))
        }
        
        featureDependency.featureDependencies.forEach { featureDependency in
            resolveAllDescendants(of: featureDependency, to: &dependencies)
        }
    }
}
