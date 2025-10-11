import Foundation
import FactoryKit

extension Container {

    var authSession: Factory<AuthSession> {
        self {
            return AuthSessionImpl()
        }.singleton
    }

}
