import Foundation
import ConvexMobile
import FactoryKit

extension Container {

    var convex: Factory<ConvexClientWithAuth<ClerkAuthProvider.AuthInfo, ClerkAuthProvider.AppleLoginParams>> {
        self {
            let authProvider = ClerkAuthProvider(clerk: self.clerk(), env: self.env())

            return ConvexClientWithAuth(deploymentUrl: self.env().CONVEX_DEPLOYMENT_URL,
                                        authProvider: authProvider)
        }.shared
    }

}
