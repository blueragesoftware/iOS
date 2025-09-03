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
        
        self.name = agent.name
        self.goal = agent.goal
        self.model = model
        self.viewModel = AgentLoadedViewModel(agent: agent, tools: tools,
                                              onToolsChanged: { tools in
            viewModel.updateAgent(tools: tools)
        },
                                              onStepsChanged: { steps in
            viewModel.updateAgent(steps: steps)
        }, onRunAgent: {
            viewModel.run()
        }
        )
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
        .scrollIndicators(.hidden)
        .onChange(of: self.agent) { _, newAgent in
            self.name = newAgent.name
            self.goal = newAgent.goal
            
            self.viewModel.update(steps: newAgent.steps)
        }
        .onChange(of: self.tools, { _, newTools in
            self.viewModel.update(tools: newTools)
        })
        .onChange(of: self.focusedStepIndex) { _, newFocusedIndex in
            self.viewModel.focusedStepIndex = newFocusedIndex
        }
        .sheet(isPresented: self.$isShowingToolsSelection) {
            ToolsSelectionScreenView(agentToolsSlugSet: Set(self.tools.map(\.slug))) { selectedTool in
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
                    onHistory: {
                        // Handle executions action
                    },
                    onRunAgent: {
                        self.viewModel.onRunAgent()
                    }
                )
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
