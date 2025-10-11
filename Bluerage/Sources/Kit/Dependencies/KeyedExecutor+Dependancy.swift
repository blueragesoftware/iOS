import Foundation
import FactoryKit

extension Container {

    var keyedExecutor: Factory<KeyedExecutor> {
        self {
            return KeyedExecutor()
        }.shared
    }

}
