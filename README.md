# tuist-modularization-plugin
This plugin aim to able to easy construct Micro Features Architecture(µFeatures Architecture).

It pursuing µFeatures Architecture like below.

<img src="https://github.com/Woin2ee-Modules/tuist-micro-feature-plugin/assets/81426024/d227aba4-27e8-4e51-8f34-4bd823b2f292" width="500">

If you want more information for µFeatures Architecture such as each components' means, dependency relationships and etc, see [What is a µFeature](https://docs.tuist.io/guide/scale/ufeatures-architecture#what-is-a-%CE%BCfeature)

## Prepare

### Import plugin

To use the features provided by this plugin, declare that using plugin in `Config.swift` file.

**Note**: You have to specify exact version via tag. Typically, recommend using latest version.

#### Config.swift

```swift
import ProjectDescription

let config = Config(
    plugins: [
        .git(url: "https://github.com/Woin2ee-Modules/tuist-micro-feature-plugin.git", tag: "0.2.4"),
    ]
)
```

## Concept

Decalre manifest object for each µFeature and resolve required targets.

### FeatureManifest

The `FeatureManifest` is `struct` contains all information to create the modules that is described in `µFeatures Architecture`.
Each module is represented by a single Xcode target.

**Basic usage**

First of all, you have to declare instance of `FeatureManifest` to use.

As needed, You can pass additional parameters related to source path or dependency.

```swift
public let homeFeature = FeatureManifest(
    baseName: "Home",
    baseBundleID: "BaseBundleID",
    destinations: .iOS,
    sourceProduct: .framework,
    deploymentTargets: .iOS("17.4"),
    externalDependencies: [
        .external(name: "RxSwift"),
    ],
    testsDependencies: [
        .external(name: "RxBlocking")
    ],
    adoptedModules: [.interface, .source, .unitTests, .example(product: .app)]
)

public let appFeature = FeatureManifest(
    baseName: "App",
    baseBundleID: "BaseBundleID",
    destinations: .iOS,
    sourceProduct: .app,
    deploymentTargets: .iOS("17.4"),
    featureDependencies: [
        homeFeature,
    ],
    adoptedModules: [.source, .uiTests]
)

```

And, append the resolved targets to project manifest!

```swift
let project = Project(
    name: "Project",
    targets: [
        // ...
    ]
    + homeFeature.resolveModules()
    + appFeature.resolveModules()
)
```

Then, a Graph is formed as follows. It matches dependency relationships described in the `µFeatures Architecture`.

<img src="https://github.com/Woin2ee-Modules/tuist-micro-feature-plugin/assets/81426024/8eaf7533-d599-4130-a1c8-3d1ad82fc02b" width="500">


## Detail points

The following may be arbitrary rules of only this plugin to easy construct µFeatures Architecture.

- If interface module doesn't exist, you can't make testing module.
- If any feature's interface module doesn't exist, other feature that depends on the one actually depends on source module when you configure dependencies between multiple features.
- Interface, Testing, Example modules can't be maked unless product type of source module is framework or library.
- Each test modules depends on all source/testing modules of its descendent dependencies.
- The path of Source files is fixed. Follow is example of sources directory structure,
  <pre>
    ㄴ Root (Manifest file)
      ㄴ Sources
        ㄴ Feature
          ㄴ Interface
          ㄴ Source
          ㄴ Testing
          ㄴ Example
          ㄴ Tests
            ㄴ UnitTests
            ㄴ UITests
  </pre>

## Compatibility

- [Tuist](https://github.com/tuist/tuist) : 4.11.0 ~


