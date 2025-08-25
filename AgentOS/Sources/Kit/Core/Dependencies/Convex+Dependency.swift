import Foundation
import ConvexMobile
import FactoryKit

extension Container {

    var convex: Factory<ConvexClient> {
        self {
            print("CONVEX_DEPLOYMENT_URL: " + self.env().CONVEX_DEPLOYMENT_URL)
            return ConvexClient(deploymentUrl: self.env().CONVEX_DEPLOYMENT_URL)
        }.shared
    }

}
