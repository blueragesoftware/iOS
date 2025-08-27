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
                AgentLoadedView(agent: agent)
            case .error:
                AgentScreenErrorView {
                    self.viewModel.connect()
                }
            }
        }
        .onAppear {
            self.viewModel.connect()
        }
    }

}
