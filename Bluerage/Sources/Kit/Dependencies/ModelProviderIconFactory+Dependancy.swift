import Get
import Foundation
import FactoryKit

extension Container {

    var modelProviderIconFactory: Factory<ModelProviderIconFactory> {
        self {
            return ModelProviderIconFactory()
        }.cached
    }

}
