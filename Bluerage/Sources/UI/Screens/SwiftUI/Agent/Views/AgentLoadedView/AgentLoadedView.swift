import SwiftUI

struct AgentLoadedView: View {
    
    @State private var name: String
    
    @State private var goal: String

    @State private var model: Model

    @State private var viewModel: AgentLoadedViewModel

    @FocusState private var isFocused: Bool
    
    @FocusedValue(\.agentLoadedStepsSectionViewFocusedStepIndex) private var focusedStepIndex: Int?
    
    @State private var isShowingToolsSelection = false

    private let agent: Agent

    private let tools: [Tool]

    private let availableModels: [Model]

    private let screenViewModel: AgentScreenViewModel
    
    init(agent: Agent,
         model: Model,
         tools: [Tool],
         availableModels: [Model],
         viewModel: AgentScreenViewModel) {
        self.agent = agent
        self.tools = tools
        self.availableModels = availableModels
        self.screenViewModel = viewModel
        
        self._name = State(initialValue: agent.name)
        self._goal = State(initialValue: agent.goal)
        self._model = State(initialValue: model)
        self._viewModel = State(initialValue: AgentLoadedViewModel(
            agent: agent,
            onToolsChanged: { tools in
                viewModel.updateAgent(tools: tools)
            },
            onStepsChanged: { steps in
                viewModel.updateAgent(steps: steps)
            }
        ))
    }
    
    var body: some View {
        Form {
            AgentLoadedHeaderView(iconUrl: self.agent.iconUrl)
            
            AgentLoadedAboutSectionView(name: self.$name,
                                        goal: self.$goal,
                                        model: self.$model,
                                        availableModels: self.availableModels,
                                        isFocused: self.$isFocused) { name, goal, modelId in
                self.screenViewModel.updateAgent(name: name, goal: goal, modelId: modelId)
            }
            
            AgentLoadedToolsSectionView(viewModel: self.viewModel) {
                self.isShowingToolsSelection = true
            }

            AgentLoadedStepsSectionView(viewModel: self.viewModel, isFocused: self.$isFocused)
        }
        .onChange(of: self.agent) { _, newAgent in
            self.name = newAgent.name
            self.goal = newAgent.goal
            
            self.viewModel.updateFromAgent(newAgent)
        }
        .onChange(of: self.focusedStepIndex) { _, newFocusedIndex in
            self.viewModel.focusedStepIndex = newFocusedIndex
        }
        .sheet(isPresented: self.$isShowingToolsSelection) {
            ToolsSelectionScreenView { selectedTool in
                self.viewModel.addTool(selectedTool)
            }
        }
        .background(UIColor.systemGroupedBackground.swiftUI)
        .safeAreaPadding(.bottom, 52)
        .overlay {
            AgentLoadedKeyboardDismissView(isFocused: self.$isFocused)
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer()
                
                AgentLoadedActionButtonsView(
                    onExecutions: {
                        // Handle executions action
                    },
                    onRunAgent: {
                        // Handle run agent action
                    }
                )
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
