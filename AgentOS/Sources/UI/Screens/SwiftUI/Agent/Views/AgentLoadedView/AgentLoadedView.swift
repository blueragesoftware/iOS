import SwiftUI

struct AgentLoadedView: View {
    
    @State private var name: String
    
    @State private var goal: String
    
    @State private var modelId: String
    
    @State private var viewModel: AgentLoadedViewModel

    @FocusState private var isFocused: Bool
    
    @FocusedValue(\.agentLoadedStepsSectionViewFocusedStepIndex) private var focusedStepIndex: Int?

    private let agent: Agent
    
    private let screenViewModel: AgentScreenViewModel
    
    init(agent: Agent, viewModel: AgentScreenViewModel) {
        self.agent = agent
        self.screenViewModel = viewModel
        
        self._name = State(initialValue: agent.name)
        self._goal = State(initialValue: agent.goal)
        self._modelId = State(initialValue: agent.modelId)
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
                                        modelId: self.$modelId,
                                        isFocused: self.$isFocused) { name, goal, modelId in
                self.screenViewModel.updateAgent(name: name, goal: goal, modelId: modelId)
            }
            
            AgentLoadedToolsSectionView(viewModel: self.viewModel) {
                // onAddTool callback if needed
            }

            AgentLoadedStepsSectionView(viewModel: self.viewModel, isFocused: self.$isFocused)
        }
        .onChange(of: self.agent) { _, newAgent in
            self.name = newAgent.name
            self.goal = newAgent.goal
            self.modelId = newAgent.modelId
            
            self.viewModel.updateFromAgent(newAgent)
        }
        .onChange(of: self.focusedStepIndex) { _, newFocusedIndex in
            self.viewModel.focusedStepIndex = newFocusedIndex
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

#Preview {
    AgentLoadedView(
        agent: Agent(
            id: "",
            name: "Test Agent",
            description: "Test description",
            iconUrl: "",
            goal: "Goal",
            tools: [Tool(id: "1", name: "Tool 1"), Tool(id: "2", name: "Tool 2")],
            steps: [Agent.Step(id: "1", value: "Step 1"), Agent.Step(id: "2", value: "Step 2")],
            modelId: "claude-sonnet-4"
        ),
        viewModel: AgentScreenViewModel(
            agent: Agent(
                id: "",
                name: "Test Agent",
                description: "Test description",
                iconUrl: "",
                goal: "Goal",
                tools: [Tool(id: "1", name: "Tool 1"), Tool(id: "2", name: "Tool 2")],
                steps: [Agent.Step(id: "1", value: "Step 1"), Agent.Step(id: "2", value: "Step 2")],
                modelId: "claude-sonnet-4"
            )
        )
    )
}
