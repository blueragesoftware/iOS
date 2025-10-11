import Foundation

enum LoadingViewModelState<T: Equatable>: Equatable {

    // MARK: - Equatable

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .loading:
            if case .loading = rhs {
                return true
            }

            return false
        case .loaded(let lhsValue):
            if case .loaded(let rhsValue) = rhs {
                return lhsValue == rhsValue
            }

            return false
        case .empty:
            if case .empty = rhs {
                return true
            }

            return false
        case .error(let lhsError):
            if case .error(let rhsError) = rhs {
                return "\(lhsError)" == "\(rhsError)"
            }

            return false
        }
    }

    // MARK: - Properties

    case loading
    case loaded(T)
    case empty
    case error(Error)

    var isLoading: Bool {
        if case .loading = self {
            true
        } else {
            false
        }
    }

    var isError: Bool {
        if case .error = self {
            true
        } else {
            false
        }
    }

    var isLoaded: Bool {
        if case .loaded = self {
            true
        } else {
            false
        }
    }

    var isEmpty: Bool {
        if case .empty = self {
            true
        } else {
            false
        }
    }

    var title: String {
        switch self {
        case .loading:
            BluerageStrings.commonLoading
        case .loaded:
            BluerageStrings.commonLoaded
        case .error:
            BluerageStrings.commonError
        case .empty:
            BluerageStrings.commonEmpty
        }
    }

}
