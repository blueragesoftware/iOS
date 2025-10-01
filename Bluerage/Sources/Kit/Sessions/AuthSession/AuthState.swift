import Foundation

enum AuthState: Equatable {
    case loading
    case error
    case unauthenticated
    case authenticated(id: String)
}
