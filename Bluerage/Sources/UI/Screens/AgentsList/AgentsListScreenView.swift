import SwiftUI
import OSLog
import PostHog
import NavigatorUI
import FactoryKit

struct AgentsListScreenView: View {

    @State private var viewModel = AgentsListScreenViewModel()

    @Environment(\.navigator) private var navigator

    @Injected(\.hapticManager) private var hapticManager

    var body: some View {
        ManagedNavigationStack {
            self.content
                .safeAreaInset(edge: .bottom) {
                    self.createNewAgentButton
                }
                .scrollDisabled(self.viewModel.state.main.isLoading || self.viewModel.state.main.isError)
                .onFirstAppear {
                    self.viewModel.connect()
                }
                .navigationTitle("agents_list_navigation_title")
                .navigationDestination(AgentListDestinations.self)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.navigator.navigate(to: AgentListDestinations.settings)
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .background(UIColor.systemGroupedBackground.swiftUI)
        .errorAlert(error: self.viewModel.state.alertError) {
            self.viewModel.resetAlertError()
        }
        .postHogScreenView("AgentsListScreenView")
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state.main {
        case .loading:
            SkeletonAgentsListView()
                .transition(.blurReplace)
        case .loaded(let agents):
            LoadedAgentsListView(agents: agents,
                                 onRemove: { ids in
                self.removeAgents(with: ids)
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
        if self.viewModel.state.main.isLoaded {
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
            self.hapticManager.triggerSelectionFeedback()

            do {
                let agent = try await self.viewModel.createNewAgent()

                self.navigator.navigate(to: AgentListDestinations.agent(agent))
            } catch {
                Logger.agentsList.error("Error creating new agent: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

    private func removeAgents(with ids: [String]) {
        Task {
            do {
                try await self.viewModel.removeAgents(with: ids)
            } catch {
                Logger.agentsList.error("Error removing agents: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

}
