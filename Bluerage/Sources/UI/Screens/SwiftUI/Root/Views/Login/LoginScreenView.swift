import SwiftUI
import AuthenticationServices
import OSLog
import PostHog

struct LoginScreenView: View {

    @State private var signInAppleButtonId = UUID().uuidString

    @State private var viewModel = LoginScreenViewModel()

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Text("login_title")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .font(.custom("InstrumentSerif-Regular", size: 60))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 62)

            Spacer()

            (Text("login_image_suggestion_prompt") + Text(" ") + Text("[X](https://x.com/ertembiyik)!").underline())
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email, .fullName]
                request.nonce = UUID().uuidString
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    self.viewModel.handle(authorization: authorization)
                case .failure(let error):
                    self.viewModel.error = error

                    Logger.login.error("Sign in failed: \(error.localizedDescription, privacy: .public)")
                }
            }
            .id(self.signInAppleButtonId)
            .signInWithAppleButtonStyle(self.colorScheme == .light ? .black : .white)
            .onChange(of: self.colorScheme, { _, _ in
                self.signInAppleButtonId = UUID().uuidString
            })
            .font(.system(.largeTitle))
            .frame(height: 52)
            .clipShape(Capsule())
            .ignoresSafeArea()
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .errorAlert(error: self.$viewModel.error)
        .postHogScreenView("LoginScreenView")
    }

}
