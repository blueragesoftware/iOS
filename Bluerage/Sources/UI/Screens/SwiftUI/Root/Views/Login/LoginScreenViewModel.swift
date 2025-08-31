import Foundation
import AuthenticationServices
import OSLog
import FactoryKit

@Observable
@MainActor
final class LoginScreenViewModel {

    @ObservationIgnored
    @Injected(\.authSession) private var authSession

    func handle(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Logger.login.error("appleIDCredential is not ASAuthorizationAppleIDCredential")
            return
        }

        guard let idToken = appleIDCredential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
            Logger.login.error("Can't construct authorizationCode from appleIDCredential")
            return
        }

        Task {
            do {
                try await self.authSession.signInWithApple(idToken: idToken)
            } catch {
                Logger.login.error("Login error: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

}
