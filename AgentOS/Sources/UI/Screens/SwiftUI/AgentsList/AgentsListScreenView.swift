import SwiftUI
import OSLog

struct AgentsListScreenView: View {

    @State private var viewModel = AgentsListScreenViewModel()
    @State private var selectedAgent: Agent?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    AgentsListView(state: self.viewModel.state,
                                   selectedAgent: self.$selectedAgent)
                }
            }
            .overlay(alignment: .bottom) {
                self.createNewAgentButton
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(self.viewModel.state.isSkeleton || self.viewModel.state.isError)
            .onAppear() {
                self.viewModel.connect()
            }
            .background(UIColor.systemGroupedBackground.swiftUI)
            .navigationTitle("agents_list_navigation_title")
            .navigationDestination(item: self.$selectedAgent) { agent in
                AgentScreenView(agent: agent)
            }
        }
    }

    @ViewBuilder private var createNewAgentButton: some View {
        if self.viewModel.state.isLoaded {
            Button {

            } label: {
                Text("agents_list_create_new_agent_button_title")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .buttonStyle(.primaryButtonStyle)
        }
    }

}
