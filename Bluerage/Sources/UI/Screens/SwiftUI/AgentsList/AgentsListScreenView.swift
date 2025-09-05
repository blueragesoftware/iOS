import SwiftUI
import OSLog
import PostHog

struct AgentsListScreenView: View {

    @State private var viewModel = AgentsListScreenViewModel()

    @State private var selectedAgent: Agent?

    var body: some View {
        NavigationStack {
            self.content
                .safeAreaInset(edge: .bottom) {
                    self.createNewAgentButton
                }
                .scrollDisabled(self.viewModel.state.isLoading || self.viewModel.state.isError)
                .onFirstAppear {
                    self.viewModel.connect()
                }
                .background(UIColor.systemGroupedBackground.swiftUI)
                .navigationTitle("agents_list_navigation_title")
                .navigationDestination(item: self.$selectedAgent) { agent in
                    AgentScreenView(agentId: agent.id)
                }
                .postHogScreenView()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state {
        case .loading:
            SkeletonAgentsListView()
                .transition(.blurReplace)
        case .loaded(let agents):
            LoadedAgentsListView(agents: agents,
                                 selectedAgent: self.$selectedAgent,
                                 onDelete: { ids in
                Task {
                    do {
                        try await self.viewModel.removeAgents(with: ids)
                    } catch {
                        Logger.agentsList.error("Error removing agents: \(error.localizedDescription)")
                    }
                }
            })
                .transition(.blurReplace)
        case .empty:
            EmptyAgentsListView {
                self.createNewAgent()
            }
                .transition(.blurReplace)
        case .error:
            ErrorAgentsListView {
                self.viewModel.connect()
            }
                .transition(.blurReplace)
        }
    }

    @ViewBuilder
    private var createNewAgentButton: some View {
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
