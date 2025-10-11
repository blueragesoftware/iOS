import SwiftUI
import OSLog
import PostHog
import NavigatorUI
import FactoryKit

struct AgentsListScreenView: View {

    private struct CreateNewAgentButton: View {

        private let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        var body: some View {
            Button {
                self.action()
            } label: {
                Text(BluerageStrings.agentsListCreateNewAgentButtonTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .buttonStyle(.primaryButtonStyle)
        }

    }

    @State private var viewModel = AgentsListScreenViewModel()

    @Injected(\.hapticManager) private var hapticManager

    var body: some View {
        ManagedNavigationStack { navigator in
            self.content(with: navigator)
                .navigationDestinationAutoReceive(AgentListDestinations.self)
                .safeAreaInset(edge: .bottom) {
                    if self.viewModel.state.main.isLoaded {
                        CreateNewAgentButton {
                            self.createNewAgent(with: navigator)
                        }
                    }
                }
                .scrollDisabled(self.viewModel.state.main.isLoading || self.viewModel.state.main.isError)
                .onFirstAppear {
                    self.viewModel.connect()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            navigator.navigate(to: AgentListDestinations.settings)
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .navigationTitle(BluerageStrings.agentsListNavigationTitle)
                .toolbarTitleDisplayMode(.inlineLarge)
        }
        .background(UIColor.systemGroupedBackground.swiftUI)
        .errorAlert(error: self.viewModel.state.alertError) {
            self.viewModel.resetAlertError()
        }
        .postHogScreenView("AgentsListScreenView")
    }

    @ViewBuilder
    private func content(with navigator: Navigator) -> some View {
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
                self.createNewAgent(with: navigator)
            }
                .transition(.blurReplace)
        case .error:
            ErrorAgentsListView {
                self.viewModel.connect()
            }
                .transition(.blurReplace)
        }
    }

    private func createNewAgent(with navigator: Navigator) {
        self.hapticManager.triggerSelectionFeedback()

        Task {
            do {
                let agent = try await self.viewModel.createNewAgent()

                navigator.navigate(to: AgentListDestinations.agent(agent))
            } catch {
                Logger.agents.error("Error creating new agent: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

    private func removeAgents(with ids: [String]) {
        Task {
            do {
                try await self.viewModel.removeAgents(with: ids)
            } catch {
                Logger.agents.error("Error removing agents: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

}
