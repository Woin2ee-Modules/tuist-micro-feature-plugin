import ProjectDescription

public enum MicroFeatureModuleType: Hashable {
    case interface
    case source
    case testing
    case unitTests
    case uiTests
    case example(product: Product)
}
