import SwiftUI
import NavigatorUI
import OSLog

struct MCPServerLoadedView: View {

    private struct ConnectButton: View {

        private let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        var body: some View {
            Button {
                self.action()
            } label: {
                Text("Connect")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .buttonStyle(.primaryButtonStyle)
        }

    }

    @State private var viewModel: MCPServerLoadedViewModel

    @State private var name: String

    @State private var url: String

    @State private var apiKey: String

    @FocusState private var isFocused: Bool

    @Environment(\.navigator) private var navigator

    init(viewModel: MCPServerLoadedViewModel) {
        self._viewModel = State(wrappedValue: viewModel)

        self._name = State(wrappedValue: viewModel.mcpServer.name)
        self._url = State(wrappedValue: viewModel.mcpServer.url)
        self._apiKey = State(wrappedValue: viewModel.mcpServer.apiKey ?? "")
    }

    var body: some View {
        Form {
            MCPServerEditSectionView(
                name: self.$name,
                url: self.$url,
                apiKey: self.$apiKey,
                isFocused: self.$isFocused,
                onUpdate: { name, url, apiKey in
                    self.viewModel.updateMCPServer(name: name, url: url, apiKey: apiKey)
                }
            )
        }
        .safeAreaInset(edge: .bottom) {
            ConnectButton {
                Task {
                    do {
                        let res = try await self.viewModel.connect()

                        if let redirectUrlString = res.redirectUrl,
                            let redirectUrl = URL(string: redirectUrlString) {
                            self.navigator.navigate(to: MCPServerScreenViewDestinations.authWebView(
                                url: redirectUrl
                            ))
                        }
                    } catch {
                        Logger.mcpServers.error("Error connecting to mcpServer with id: \(self.viewModel.mcpServer.id, privacy: .public), error: \(error.localizedDescription, privacy: .public)")

                        self.viewModel.alertError = error
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(UIColor.systemGroupedBackground.swiftUI)
        .overlay {
            KeyboardDismissView(isFocused: self.$isFocused)
        }
        .errorAlert(error: self.$viewModel.alertError)
        .onDisappear {
            self.viewModel.flush()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.viewModel.flush()
        }
        .navigationTitle(BluerageStrings.mcpServerNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

}
