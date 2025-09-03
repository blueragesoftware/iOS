import SwiftUI

@MainActor
@Observable
final class AgentLoadedViewModel {
    
    private(set) var tools: [EditableToolItem] = []

    private(set) var steps: [EditableStepItem] = []

    @ObservationIgnored
    var focusedStepIndex: Int? = nil {
        didSet {
            if self.focusedStepIndex == nil {
                self.cleanupEmptySteps()
            }
        }
    }

    @ObservationIgnored
    let onRunAgent: () -> Void

    @ObservationIgnored
    private let onToolsChanged: ([Tool]) -> Void

    @ObservationIgnored
    private let onStepsChanged: ([Agent.Step]) -> Void

    init(agent: Agent,
         tools: [Tool],
         onToolsChanged: @escaping ([Tool]) -> Void,
         onStepsChanged: @escaping ([Agent.Step]) -> Void,
         onRunAgent: @escaping () -> Void) {
        self.onToolsChanged = onToolsChanged
        self.onStepsChanged = onStepsChanged
        self.onRunAgent = onRunAgent
        self.update(steps: agent.steps)
        self.update(tools: tools)
    }
    
    func update(steps: [Agent.Step]) {
        var stepsList: [EditableStepItem] = steps.map { .content($0) }
        stepsList.append(.empty(id: UUID().uuidString))
        self.steps = stepsList
    }

    func update(tools: [Tool]) {
        var toolsList: [EditableToolItem] = tools.map { .content($0) }
        toolsList.append(.empty(id: UUID().uuidString))
        self.tools = toolsList
    }

    func addTool(_ tool: Tool) {
        if let lastIndex = self.tools.indices.last,
           case .empty = self.tools[lastIndex] {
            self.tools[lastIndex] = .content(tool)
            self.tools.append(.empty(id: UUID().uuidString))
        } else {
            self.tools.append(.content(tool))
            self.tools.append(.empty(id: UUID().uuidString))
        }
        
        self.notifyToolsChanged()
    }
    
    func handleStepChange(at index: Int, newValue: String) {
        guard index < self.steps.count else { return }
        
        let currentStepItem = self.steps[index]
        let isLast = self.isLastItem(index: index, in: self.steps)
        let isFocused = self.focusedStepIndex == index
        
        if newValue.isEmpty {
            if isLast {
                return
            } else if isFocused {
                let stepId = currentStepItem.id
                self.steps[index] = .empty(id: stepId)
                return
            } else {
                self.steps.remove(at: index)

                if let focusedIndex = self.focusedStepIndex, focusedIndex > index {
                    self.focusedStepIndex = focusedIndex - 1
                }

                self.notifyStepsChanged()
            }
        } else {
            let stepId = currentStepItem.id
            self.steps[index] = .content(Agent.Step(id: stepId, value: newValue))

            if isLast {
                self.steps.append(.empty(id: UUID().uuidString))
            }
            
            self.notifyStepsChanged()
        }
    }
    
    private func cleanupEmptySteps() {
        var indicesToRemove: [Int] = []
        
        for (index, step) in self.steps.enumerated() {
            let isLast = index == self.steps.count - 1
            
            if !isLast {
                switch step {
                case .empty:
                    indicesToRemove.append(index)
                case .content(let stepContent):
                    if stepContent.value.isEmpty {
                        indicesToRemove.append(index)
                    }
                }
            }
        }

        for index in indicesToRemove.reversed() {
            self.steps.remove(at: index)
        }
        
        if !indicesToRemove.isEmpty {
            self.notifyStepsChanged()
        }
    }
    
    func deleteTools(at offsets: IndexSet) {
        self.tools.remove(atOffsets: offsets)
        self.notifyToolsChanged()
    }
    
    func deleteSteps(at offsets: IndexSet) {
        self.steps.remove(atOffsets: offsets)
        self.notifyStepsChanged()
    }
    
    func moveSteps(from: IndexSet, to: Int) {
        self.steps.move(fromOffsets: from, toOffset: to)
        self.notifyStepsChanged()
    }
    
    func isEditable(index: Int, in items: [any Identifiable]) -> Bool {
        return items.count == 1 || self.isLastItem(index: index, in: items)
    }
    
    func isLastItem<T>(index: Int, in items: [T]) -> Bool {
        return index == items.count - 1
    }
    
    private func notifyToolsChanged() {
        let contentTools = self.tools.compactMap { item in
            if case .content(let tool) = item {
                return tool
            }

            return nil
        }

        self.onToolsChanged(contentTools)
    }
    
    private func notifyStepsChanged() {
        let contentSteps = self.steps.compactMap { item in
            if case .content(let step) = item {
                return step
            }

            return nil
        }

        self.onStepsChanged(contentSteps)
    }
}
