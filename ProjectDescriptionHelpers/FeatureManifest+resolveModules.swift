import ProjectDescription

extension FeatureManifest {
    
    public func resolveModules() -> [Target] {
        var targets: [Target] = []
        
        if self.hasInterfaceModule {
            targets.append(self.interface)
        }
        if self.hasSourceModule {
            targets.append(self.source)
        }
        if self.hasTestingModule {
            targets.append(self.testing)
        }
        if self.hasUnitTestsModule {
            targets.append(self.unitTests)
        }
        if self.hasUITestsModule {
            targets.append(self.uiTests)
        }
        if self.hasExampleModule {
            targets.append(self.example)
        }
        
        return targets
    }
}
