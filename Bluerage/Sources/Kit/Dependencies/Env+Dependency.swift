import Foundation
import ConvexMobile
import FactoryKit

extension Container {

    var env: Factory<Env> {
        self {
            Env()
        }.singleton
    }

}
