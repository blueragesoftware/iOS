import SwiftUI
import NavigatorUI
import OSLog

struct MCPServerLoadedView: View {

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
        .safeAreaPadding(.bottom, 52)
        .safeAreaInset(edge: .bottom) {
            ActionButton(title: "Connecting") {
                Task {
                    do {
                        let result = try await self.viewModel.connect()

                        if case .redirect(let redirectUrl) = result {
                            self.navigator.navigate(
                                to: MCPServerScreenViewDestinations.authWebView(url: redirectUrl)
                            )
                        } else {
                            self.navigator.pop()
                        }
                    } catch {
                        Logger.mcpServers.error("Error connecting to mcpServer with id: \(self.viewModel.mcpServer.id, privacy: .public), error: \(error.localizedDescription, privacy: .public)")

                        self.viewModel.alertError = error
                    }
                }
            }
            .isLoading(self.viewModel.isConnecting)
            .padding(.horizontal, 20)
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
    }

}
