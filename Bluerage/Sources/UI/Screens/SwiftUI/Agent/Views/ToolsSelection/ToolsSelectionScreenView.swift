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
                .navigationTitle("Select a Tool")
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
                        try await self.viewModel.connectTool(with: inactiveTool.authConfigId)
                    }
                }
            )
        case .empty:
            PlaceholderView(imageSystemName: "wrench.and.screwdriver",
                            title: "No Tools Available",
                            description: "There are currently no tools available to add to your agent")
        case .error:
            PlaceholderView.error(title: "Failed to Load Tools") {
                self.viewModel.load()
            }
        case .allToolsUsed:
            PlaceholderView(imageSystemName: "wrench.and.screwdriver",
                            title: "All tools connected",
                            description: "Your agent is peaked with all available tools")
        }
    }
}
