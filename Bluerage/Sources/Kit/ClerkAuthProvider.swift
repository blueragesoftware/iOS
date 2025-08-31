import Clerk
import ConvexMobile
import FactoryKit
import OSLog

final class ClerkAuthProvider: AuthProvider {

    enum Error: Swift.Error {
        case unauthorized
    }

    struct AuthInfo {

        let user: User

        let jwt: String

    }

    struct AppleLoginParams {

        let idToken: String

    }

    private let clerk: Clerk

    private let env: Env

    init(clerk: Clerk, env: Env) {
        self.clerk = clerk
        self.env = env
    }

    func logout() async throws {
        try await self.clerk.signOut()
    }
    
    func loginFromCache() async throws -> AuthInfo {
        let user = await self.clerk.user

        if let user, let jwt = try await self.clerk.session?.getToken(.init(template: "convex"))?.jwt {
            return AuthInfo(user: user, jwt: jwt)
        }

        throw Error.unauthorized
    }
    
    func extractIdToken(from authResult: AuthInfo) -> String {
        return authResult.jwt
    }


    func login(with loginParams: AppleLoginParams) async throws -> AuthInfo {
        try await SignIn.authenticateWithIdToken(provider: .apple, idToken: loginParams.idToken)

        return try await self.loginFromCache()
    }


}
