import SwiftUI
import NukeUI
import PostHog
import NavigatorUI

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
            .navigationDestinationAutoReceive(AgentDestinations.self)
            .postHogScreenView("AgentScreenView", ["agentId": self.agentId])
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            LoadingView()
                .transition(.blurReplace)
        case .loaded(let loadedViewModel):
            AgentLoadedView(viewModel: loadedViewModel)
                .transition(.blurReplace)
        case .error:
            PlaceholderView.error {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

}
