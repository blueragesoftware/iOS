import SwiftUI

struct ToolsSelectionScreenView: View {

    @State private var viewModel: ToolsSelectionScreenViewModel

    @Environment(\.dismiss) private var dismiss

    private let onToolSelected: (Tool) -> Void

    init(agentToolsSlugSet: Set<String>, onToolSelected: @escaping (Tool) -> Void) {
        self.viewModel = ToolsSelectionScreenViewModel(agentToolsSlugSet: agentToolsSlugSet)
        self.onToolSelected = onToolSelected
    }

    var body: some View {
        NavigationView {
            self.content
                .navigationTitle("tools_selection_navigation_title")
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.viewModel.load()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(item: self.$viewModel.authUrlConfig,
               onDismiss: {
            self.viewModel.load()
        }) { config in
            SafariView(url: config.url)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
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
                            try await self.viewModel.connectTool(with: inactiveTool.authConfigId)
                        } catch {
                            self.viewModel.state
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
