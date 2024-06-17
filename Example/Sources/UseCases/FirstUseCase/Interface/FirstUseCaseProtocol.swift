import RxSwift

public protocol FirstUseCase {
    func generateGreeting() -> Observable<String>
}
