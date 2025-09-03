import Combine

extension Publisher {

    typealias Pairwise<T> = (previous: T?, current: T)

    func pairwise() -> AnyPublisher<Pairwise<Output>, Failure> {
        scan(nil) { previousPair, currentElement -> Pairwise<Output>? in
            Pairwise(previous: previousPair?.current, current: currentElement)
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }

}
