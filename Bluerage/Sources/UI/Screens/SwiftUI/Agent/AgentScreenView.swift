import SwiftUI
import NukeUI

struct AgentScreenView: View {

    @State private var viewModel: AgentScreenViewModel

    init(agent: Agent) {
        self.viewModel = AgentScreenViewModel(agent: agent)
    }

    var body: some View {
        Group {
            switch self.viewModel.state {
            case .loaded(let agent):
                AgentLoadedView(agent: agent, viewModel: self.viewModel)
            case .error:
                AgentScreenErrorView {
                    self.viewModel.connect()
                }
            }
        }
        .onFirstAppear {
            self.viewModel.connect()
        }
        .onDisappear {
            self.viewModel.flush()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.viewModel.flush()
        }
    }

}
