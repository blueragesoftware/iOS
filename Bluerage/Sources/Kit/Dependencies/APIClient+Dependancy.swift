import Get
import Foundation
import FactoryKit

extension Container {

    var apiClient: Factory<APIClient> {
        self {
            return APIClient(baseURL: URL(string: self.env().CONVEX_DEPLOYMENT_URL))
        }.shared
    }

}
