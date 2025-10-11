import Foundation
import AuthenticationServices
import OSLog
import FactoryKit
import Clerk

@Observable
@MainActor
final class LoginScreenViewModel {

    private enum LoginScreenViewModelError: LocalizedError {

        case failedToExtractAppleIDCredential
        case failedToExtractIdToken

        var errorDescription: String? {
            switch self {
            case .failedToExtractAppleIDCredential:
                return "appleIDCredential is not ASAuthorizationAppleIDCredential"
            case .failedToExtractIdToken:
                return "Can't construct authorizationCode from appleIDCredential"
            }
        }

    }

    var error: Error?

    @ObservationIgnored
    @Injected(\.authSession) private var authSession

    @ObservationIgnored
    @Injected(\.clerk) private var clerk

    func handle(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Logger.login.error("\(LoginScreenViewModelError.failedToExtractAppleIDCredential.localizedDescription, privacy: .public)")

            self.error = LoginScreenViewModelError.failedToExtractAppleIDCredential
            return
        }

        guard let idToken = appleIDCredential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
            Logger.login.error("\(LoginScreenViewModelError.failedToExtractIdToken.localizedDescription, privacy: .public)")

            self.error = LoginScreenViewModelError.failedToExtractIdToken
            return
        }

        Task {
            do {
                try await self.authSession.signInWithApple(idToken: idToken)
            } catch {
                Logger.login.error("Login error: \(error.localizedDescription, privacy: .public)")

                self.error = error
            }
        }
    }

}
