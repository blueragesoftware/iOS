import SwiftUI
import NavigatorUI
import OSLog

struct AgentLoadedView: View {

    @State private var viewModel: AgentLoadedViewModel

    @State private var name: String

    @State private var goal: String

    @State private var modelId: String

    @FocusState private var isFocused: Bool

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

            AgentLoadedToolsSectionView(tools: self.viewModel.tools,
                                        onRemove: { offsets in
                self.viewModel.removeTools(at: offsets)
            },
                                        onAdd: {
                self.addNewTool()
            }, onSelectTool: { tool in
                self.select(tool: tool)
            })

            AgentLoadedStepsSectionView(steps: self.viewModel.steps,
                                        isFocused: self.$isFocused,
                                        onAdd: {
                self.viewModel.addStep()
            },
                                        onChange: { index, value in
                self.viewModel.handleStepChange(at: index, newValue: value)
            },
                                        onMove: { from, to in
                self.viewModel.moveSteps(from: from, to: to)
            },
                                        onRemove: { offsets in
                self.viewModel.removeSteps(at: offsets)
            })

            AgentLoadedFilesSectionView(files: self.viewModel.files,
                                        isUploading: self.viewModel.isUploadingFile,
                                        onRemove: { offsets in
                self.viewModel.removeFiles(at: offsets)
            }, onAdd: { localFile in
                self.viewModel.add(localFile: localFile)
            })
        }
        .scrollIndicators(.hidden)
        .background(UIColor.systemGroupedBackground.swiftUI)
        .safeAreaPadding(.bottom, 52)
        .overlay {
            KeyboardDismissView(isFocused: self.$isFocused)
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer()

                HStack(spacing: 10) {
                    Button {
                        self.navigator.navigate(to: AgentDestinations.executionsList(agentId: self.viewModel.agent.id))
                    } label: {
                        Text(BluerageStrings.agentExecutionsButtonTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderGradientProminentButtonStyle)

                    ActionButton(title: BluerageStrings.agentRunButtonTitle) {
                        self.createTask()
                    }
                    .isLoading(self.viewModel.isCreatingNewRunTask)
                }
                .padding(.horizontal, 20)
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

    private func addNewTool() {
        let slugs = self.viewModel.tools.map(\.slug)

        let slugsSet = Set(slugs)

        self.navigator.navigate(to: AgentDestinations.toolsSelection(
            agentToolsSlugSet: slugsSet,
            callback: Callback { [weak viewModel] tool in
                viewModel?.add(tool: tool)
            })
        )
    }

    private func select(tool: Tool) {
        guard tool.status != .active && tool.status != .initializing else {
            return
        }

        Task {
            do {
                let redirectUrl = try await self.viewModel.connectTool(with: tool.authConfigId)

                self.navigator.navigate(to: ToolsSelectionDestinations.authWebView(
                    url: redirectUrl,
                    callback: Callback { [weak viewModel] _ in
                        viewModel?.reload()
                    }
                ))
            } catch {
                Logger.agents.error("Error connecting tool: \(error.localizedDescription, privacy: .public)")

                self.viewModel.alertError = error
            }
        }
    }

    private func createTask() {
        Task {
            do {
                let taskId = try await self.viewModel.createTask()

                self.navigator.send(
                    AgentDestinations.executionsList(agentId: self.viewModel.agent.id),
                    ExecutionsListDestinations.execution(taskId: taskId, index: 0)
                )
            } catch {
                Logger.agents.error("Error running agent: \(error.localizedDescription, privacy: .public)")

                self.viewModel.alertError = error
            }
        }
    }

}
