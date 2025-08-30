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
                                   selectedAgent: self.$selectedAgent) {
                        self.createNewAgent()
                    } refresh: {
                        self.viewModel.connect()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                self.createNewAgentButton
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(self.viewModel.state.isLoading || self.viewModel.state.isError)
            .onFirstAppear {
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
                self.createNewAgent()
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

    private func createNewAgent() {
        Task {
            do {
                self.selectedAgent = try await self.viewModel.createNewAgent()
            } catch {
                Logger.agentsList.error("Error creating new agent: \(error.localizedDescription)")
            }
        }
    }

}
