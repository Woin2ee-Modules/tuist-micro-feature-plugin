import FirstUseCaseInterface
import RxSwift

final class DefaultFirstUseCase: FirstUseCase {
    func generateGreeting() -> Observable<String> {
        return .just("Hello!")
    }
}
