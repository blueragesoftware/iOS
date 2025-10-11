import Foundation
import Clerk
import FactoryKit

extension Container {

    var clerk: Factory<Clerk> {
        self {
            return Clerk.shared
        }.singleton
    }

}
