import Foundation
import Knock
import FactoryKit

extension Container {

    var knock: Factory<Knock> {
        self {
            return Knock.shared
        }.shared
    }

}
