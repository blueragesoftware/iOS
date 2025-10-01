import Foundation
import Knock
import FactoryKit

extension Container {

    var knockManager: Factory<KnockManager> {
        self {
            return KnockManager()
        }.shared
    }

}
