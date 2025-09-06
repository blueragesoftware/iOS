import SwiftUI
import NavigatorUI
import OSLog

struct ToolsSelectionScreenView: View {

    @State private var viewModel: ToolsSelectionScreenViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigator) private var navigator

    private let onToolSelected: (Tool) -> Void

    init(agentToolsSlugSet: Set<String>, onToolSelected: @escaping (Tool) -> Void) {
        self.viewModel = ToolsSelectionScreenViewModel(agentToolsSlugSet: agentToolsSlugSet)
        self.onToolSelected = onToolSelected
    }

    var body: some View {
        ManagedNavigationStack {
            self.content
                .navigationTitle("tools_selection_navigation_title")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(ToolsSelectionDestinations.self)
        }
        .onAppear {
            self.viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.viewModel.load()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .errorAlert(error: self.viewModel.state.alertError) {
            self.viewModel.resetAlertError()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state.main {
        case .loading:
            ProgressView()
        case .loaded(let activeTools, let inactiveTools):
            ToolsSelectionLoadedView(
                activeTools: activeTools,
                inactiveTools: inactiveTools,
                onActiveToolSelected: { activeTool in
                    self.onToolSelected(activeTool)
                    self.dismiss()
                }, onInactiveToolSelected: { inactiveTool in
                    Task {
                        do {
                            let redirectUrl = try await self.viewModel.connectTool(with: inactiveTool.authConfigId)

                            self.navigator.navigate(to: ToolsSelectionDestinations.authWebView(
                                url: redirectUrl,
                                callback: Callback { [weak viewModel] _ in
                                    viewModel?.load()
                                }
                            ))
                        } catch {
                            Logger.tools.error("Error connecting tool: \(error.localizedDescription, privacy: .public)")

                            self.viewModel.showErrorAlert(with: error)
                        }
                    }
                }
            )
        case .empty:
            PlaceholderView(imageName: "tools_placeholder_100",
                            title: "tools_selection_empty_placeholder_title",
                            description: "tools_selection_empty_placeholder_description")
        case .error:
            PlaceholderView.error(title: "tools_selection_error_placeholder_title") {
                self.viewModel.load()
            }
        case .allToolsUsed:
            PlaceholderView(imageName: "tools_placeholder_100",
                            title: "All tools connected",
                            description: "tools_selection_all_tools_connected_placeholder_placeholder")
        }
    }
}
