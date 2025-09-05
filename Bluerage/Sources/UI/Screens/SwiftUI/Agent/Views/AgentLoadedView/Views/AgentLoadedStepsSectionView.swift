import SwiftUI

struct AgentLoadedStepsSectionView: View {
    
    private let viewModel: AgentLoadedViewModel

    @FocusState.Binding private var isFocused: Bool

    init(viewModel: AgentLoadedViewModel, isFocused: FocusState<Bool>.Binding) {
        self.viewModel = viewModel
        self._isFocused = isFocused
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.viewModel.steps.indices, self.viewModel.steps)), id: \.1.id) { index, stepItem in
                HStack {
                    TextField(self.viewModel.isLastItem(index: index, in: self.viewModel.steps) ? "Add a Step" : "Step",
                             text: Binding(
                                get: {
                                    guard index < self.viewModel.steps.count else { return "" }
                                    switch self.viewModel.steps[index] {
                                    case .content(let step):
                                        return step.value
                                    case .empty:
                                        return ""
                                    }
                                },
                                set: { newValue in
                                    self.viewModel.handleStepChange(at: index, newValue: newValue)
                                }
                             ),
                             axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .focusedValue(\.agentLoadedStepsSectionViewFocusedStepIndex, index)
                    
                    Spacer()
                    
                    if !self.viewModel.isLastItem(index: index, in: self.viewModel.steps) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                .deleteDisabled(self.viewModel.isEditable(index: index, in: self.viewModel.steps))
                .moveDisabled(self.viewModel.isEditable(index: index, in: self.viewModel.steps))
            }
            .onDelete { offsets in
                self.viewModel.deleteSteps(at: offsets)
            }
            .onMove { from, to in
                self.viewModel.moveSteps(from: from, to: to)
            }
        } header: {
            Text("Steps")
        } footer: {
            Text("Swipe left to delete")
        }
    }

}
