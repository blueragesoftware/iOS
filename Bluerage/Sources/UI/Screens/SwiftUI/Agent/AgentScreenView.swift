import SwiftUI
import NukeUI
import PostHog

struct AgentScreenView: View {

    private let agentId: String

    @State private var viewModel: AgentScreenViewModel

    init(agentId: String) {
        self.agentId = agentId
        self.viewModel = AgentScreenViewModel(agentId: agentId)
    }

    var body: some View {
        self.content
            .onFirstAppear {
                self.viewModel.connect()
            }
            .onDisappear {
                self.viewModel.flush()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.viewModel.flush()
            }
            .postHogScreenView(nil, ["agentId": self.agentId])
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .loaded(let agent, let model, let tools, let availableModels):
            AgentLoadedView(agent: agent,
                            model: model,
                            tools: tools,
                            availableModels: availableModels,
                            viewModel: self.viewModel)
            .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

}
