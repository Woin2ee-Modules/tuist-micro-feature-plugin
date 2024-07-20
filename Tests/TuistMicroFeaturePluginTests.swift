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
    
    func test_onlyOnceDependingStaticFramework_whenHasInterface() {
        // Given
        let featureManifest = FeatureManifest(
            baseName: "Feature",
            baseBundleID: "Feature",
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: .iOS("17.0"),
            basicDependencies: [
                .external(name: "FoundationPlus")
            ],
            adoptedModules: [.interface, .source, .testing, .unitTests]
        )
        
        // When
        let interfaceTarget = featureManifest.interface
        let testingTarget = featureManifest.testing
        let sourceTarget = featureManifest.source
        let unitTestsTarget = featureManifest.unitTests
        
        // Then
        XCTAssertEqual(Set(interfaceTarget.dependencies), Set([
            .external(name: "FoundationPlus"),
        ]))
        XCTAssertEqual(Set(sourceTarget.dependencies), Set([
            .target(name: "FeatureInterface"),
        ]))
        XCTAssertEqual(Set(testingTarget.dependencies), Set([
            .target(name: "FeatureInterface"),
        ]))
        XCTAssertEqual(Set(unitTestsTarget.dependencies), Set([
            .target(name: "FeatureSource"),
        ]))
    }
    
    func test_onlyOnceDependingStaticFramework_whenHasNotInterface() {
        // Given
        let featureManifest = FeatureManifest(
            baseName: "Feature",
            baseBundleID: "Feature",
            destinations: .iOS,
            sourceProduct: .framework,
            deploymentTargets: .iOS("17.0"),
            basicDependencies: [
                .external(name: "FoundationPlus")
            ],
            adoptedModules: [.source, .unitTests, .uiTests, .example(product: .app)]
        )
        
        // When
        let sourceTarget = featureManifest.source
        let unitTestsTarget = featureManifest.unitTests
        let uiTestsTarget = featureManifest.uiTests
        let exampleTarget = featureManifest.example
        
        // Then
        XCTAssertEqual(Set(sourceTarget.dependencies), Set([
            .external(name: "FoundationPlus")
        ]))
        XCTAssertEqual(Set(unitTestsTarget.dependencies), Set([
            .target(name: "FeatureSource"),
        ]))
        XCTAssertEqual(Set(uiTestsTarget.dependencies), Set([
            .target(name: "FeatureSource"),
        ]))
        XCTAssertEqual(Set(exampleTarget.dependencies), Set([
            .target(name: "FeatureSource"),
        ]))
    }
}
