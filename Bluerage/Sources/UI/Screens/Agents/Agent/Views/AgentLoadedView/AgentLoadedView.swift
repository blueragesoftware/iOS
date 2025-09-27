import SwiftUI
import NavigatorUI

struct AgentLoadedView: View {

    @State private var viewModel: AgentLoadedViewModel

    @State private var name: String

    @State private var goal: String

    @State private var modelId: String

    @FocusState private var isFocused: Bool

    @FocusedValue(\.agentLoadedStepsSectionViewFocusedStepIndex) private var focusedStepIndex: Int?

    @Environment(\.navigator) private var navigator

    init(viewModel: AgentLoadedViewModel) {
        self._viewModel = State(wrappedValue: viewModel)

        self._name = State(wrappedValue: viewModel.agent.name)
        self._goal = State(wrappedValue: viewModel.agent.goal)
        self._modelId = State(wrappedValue: viewModel.model.id)
    }

    var body: some View {
        Form {
            AgentLoadedHeaderView(iconUrl: self.viewModel.agent.iconUrl)
                .stretchyFormHeader()

            AgentLoadedAboutSectionView(name: self.$name,
                                        goal: self.$goal,
                                        modelId: self.$modelId,
                                        availableModels: self.viewModel.availableModels,
                                        isFocused: self.$isFocused,
                                        onUpdate: { params in
                self.viewModel.updateAgentHeader(params: params)
            })

            AgentLoadedToolsSectionView(tools: self.viewModel.editableTools,
                                        onRemove: { offsets in
                self.viewModel.removeTools(at: offsets)
            },
                                        onAdd: {
                let slugs = self.viewModel.editableTools.compactMap { editableTool in
                    if case .content(let tool) = editableTool {
                        return tool.slug
                    }

                    return nil
                }

                let slugsSet = Set(slugs)

                self.navigator.navigate(to: AgentDestinations.toolsSelection(
                    agentToolsSlugSet: slugsSet,
                    callback: Callback { [weak viewModel] tool in
                        viewModel?.addTool(tool)
                    })
                )
            })

            AgentLoadedStepsSectionView(steps: self.viewModel.editableSteps,
                                        isFocused: self.$isFocused,
                                        onStepChange: { index, value in
                self.viewModel.handleStepChange(at: index, newValue: value)
            },
                                        onMove: { from, to in
                self.viewModel.moveSteps(from: from, to: to)
            },
                                        onRemove: { offsets in
                self.viewModel.removeSteps(at: offsets)
            })
        }
        .scrollIndicators(.hidden)
        .onChange(of: self.focusedStepIndex) { _, newFocusedIndex in
            self.viewModel.focusedStepIndex = newFocusedIndex
        }
        .background(UIColor.systemGroupedBackground.swiftUI)
        .safeAreaPadding(.bottom, 52)
        .overlay {
            KeyboardDismissView(isFocused: self.$isFocused)
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer()

                AgentLoadedActionButtonsView(
                    onExecutions: {
                        self.navigator.navigate(to: AgentDestinations.executionsList(
                            agentId: self.viewModel.agent.id)
                        )
                    },
                    onRunAgent: {
                        self.navigator.navigate(to: AgentDestinations.executionsList(
                            agentId: self.viewModel.agent.id)
                        )

                        self.viewModel.run()
                    }
                )
            }
            .ignoresSafeArea(.keyboard)
        }
        .errorAlert(error: self.$viewModel.alertError)
        .onDisappear {
            self.viewModel.flush()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.viewModel.flush()
        }
    }

}
