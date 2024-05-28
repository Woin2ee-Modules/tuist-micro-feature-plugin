import ProjectDescription
@testable import TuistMicroFeaturePlugin
import XCTest

final class TuistMicroFeaturePluginTests: XCTestCase {
    
    func test_unitTestsDependencies() {
        let iOSDeploymentTargets = DeploymentTargets.iOS("17.0")
        let baseBundleID = "TestBundleID"

        let firstService = FeatureManifest(
            baseName: "FirstService",
            baseBundleID: baseBundleID,
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: iOSDeploymentTargets,
            adoptedModules: [.interface, .source, .testing, .unitTests]
        )

        let firstUseCase = FeatureManifest(
            baseName: "FirstUseCase",
            baseBundleID: baseBundleID,
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: iOSDeploymentTargets,
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
            adoptedModules: [.interface, .source, .testing, .unitTests]
        )

        let firstSceneFeature = FeatureManifest(
            baseName: "FirstScene",
            baseBundleID: baseBundleID,
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: iOSDeploymentTargets,
            featureDependencies: [
                firstUseCase,
                secondUseCase,
            ],
            adoptedModules: [.source, .unitTests, .example(product: .app)]
        )
        
        // Then
        let dependenciesNames = firstSceneFeature.unitTests.dependencies.map { dependency in
            if case .target(let name, _) = dependency {
                return name
            } else {
                XCTFail("It is different type of dependency.")
                return ""
            }
        }
        XCTAssertTrue(dependenciesNames.contains("FirstSceneSource"))
        
        XCTAssertTrue(dependenciesNames.contains("FirstUseCaseSource"))
        
        XCTAssertTrue(dependenciesNames.contains("SecondUseCaseSource"))
        XCTAssertTrue(dependenciesNames.contains("SecondUseCaseTesting"))
        
        XCTAssertTrue(dependenciesNames.contains("FirstServiceSource"))
        XCTAssertTrue(dependenciesNames.contains("FirstServiceTesting"))
    }
    
    func test_uiTestsDependencies() {
        let iOSDeploymentTargets = DeploymentTargets.iOS("17.0")
        let baseBundleID = "TestBundleID"

        let firstService = FeatureManifest(
            baseName: "FirstService",
            baseBundleID: baseBundleID,
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: iOSDeploymentTargets,
            adoptedModules: [.interface, .source, .testing, .unitTests]
        )

        let firstUseCase = FeatureManifest(
            baseName: "FirstUseCase",
            baseBundleID: baseBundleID,
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: iOSDeploymentTargets,
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
            adoptedModules: [.interface, .source, .testing, .unitTests]
        )

        let firstSceneFeature = FeatureManifest(
            baseName: "FirstScene",
            baseBundleID: baseBundleID,
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: iOSDeploymentTargets,
            featureDependencies: [
                firstUseCase,
                secondUseCase,
            ],
            adoptedModules: [.source, .unitTests, .uiTests, .example(product: .app)]
        )
        
        // Then
        let dependenciesNames = firstSceneFeature.uiTests.dependencies.map { dependency in
            if case .target(let name, _) = dependency {
                return name
            } else {
                XCTFail("It is different type of dependency.")
                return ""
            }
        }
        XCTAssertTrue(dependenciesNames.contains("FirstSceneSource"))
        
        XCTAssertTrue(dependenciesNames.contains("FirstUseCaseSource"))
        
        XCTAssertTrue(dependenciesNames.contains("SecondUseCaseSource"))
        XCTAssertTrue(dependenciesNames.contains("SecondUseCaseTesting"))
        
        XCTAssertTrue(dependenciesNames.contains("FirstServiceSource"))
        XCTAssertTrue(dependenciesNames.contains("FirstServiceTesting"))
    }
}
