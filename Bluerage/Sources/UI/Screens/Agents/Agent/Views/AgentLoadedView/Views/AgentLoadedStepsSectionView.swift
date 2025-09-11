import SwiftUI

struct AgentLoadedStepsSectionView: View {

    @FocusState.Binding private var isFocused: Bool

    private let steps: [EditableStepItem]

    private let onStepChange: (Int, String) -> Void

    private let onMove: (IndexSet, Int) -> Void

    private let onRemove: (IndexSet) -> Void

    init(steps: [EditableStepItem],
         isFocused: FocusState<Bool>.Binding,
         onStepChange: @escaping (Int, String) -> Void,
         onMove: @escaping (IndexSet, Int) -> Void,
         onRemove: @escaping (IndexSet) -> Void) {
        self.steps = steps
        self._isFocused = isFocused
        self.onStepChange = onStepChange
        self.onMove = onMove
        self.onRemove = onRemove
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.steps.indices, self.steps)), id: \.1.id) { index, _ in
                HStack {
                    let placeholder: String = self.isLastItem(index: index)
                    ? BluerageStrings.agentNewStepPlaceholder
                    : BluerageStrings.agentStepPlaceholder

                    TextField(placeholder,
                             text: Binding(
                                get: {
                                    guard index < self.steps.count else {
                                        return ""
                                    }

                                    switch self.steps[index] {
                                    case .content(let step):
                                        return step.value
                                    case .empty:
                                        return ""
                                    }
                                },
                                set: { newValue in
                                    self.onStepChange(index, newValue)
                                }
                             ),
                             axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .focused(self.$isFocused)
                        .focusedValue(\.agentLoadedStepsSectionViewFocusedStepIndex, index)

                    Spacer()

                    if !self.isLastItem(index: index) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                .deleteDisabled(self.isEditable(index: index))
                .moveDisabled(self.isEditable(index: index))
            }
            .onDelete { offsets in
                self.onRemove(offsets)
            }
            .onMove { from, to in
                self.onMove(from, to)
            }
        } header: {
            Text(BluerageStrings.agentStepsSectionHeader)
        } footer: {
            Text(BluerageStrings.agentSectionFooter)
        }
    }

    private func isLastItem(index: Int) -> Bool {
        return index == self.steps.count - 1
    }

    private func isEditable(index: Int) -> Bool {
        guard index < self.steps.count else {
            return false
        }

        switch self.steps[index] {
        case .content:
            return false
        case .empty:
            return true
        }
    }

}
