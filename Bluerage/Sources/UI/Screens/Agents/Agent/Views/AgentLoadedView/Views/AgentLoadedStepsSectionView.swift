import SwiftUI

struct AgentLoadedStepsSectionView: View {

    @FocusState.Binding private var isFocused: Bool

    private let steps: [Agent.Step]

    private let onAdd: () -> Void

    private let onChange: (Int, String) -> Void

    private let onMove: (IndexSet, Int) -> Void

    private let onRemove: (IndexSet) -> Void

    init(steps: [Agent.Step],
         isFocused: FocusState<Bool>.Binding,
         onAdd: @escaping () -> Void,
         onChange: @escaping (Int, String) -> Void,
         onMove: @escaping (IndexSet, Int) -> Void,
         onRemove: @escaping (IndexSet) -> Void) {
        self.steps = steps
        self._isFocused = isFocused
        self.onAdd = onAdd
        self.onChange = onChange
        self.onMove = onMove
        self.onRemove = onRemove
    }

    var body: some View {
        Section {
            ForEach(Array(zip(self.steps.indices, self.steps)), id: \.1.id) { index, _ in
                HStack {
                    TextField(BluerageStrings.agentStepPlaceholder,
                              text: Binding(
                                get: {
                                    return self.steps[safeIndex: index]?.value ?? ""
                                },
                                set: { newValue in
                                    self.onChange(index, newValue)
                                }
                              ),
                              axis: .vertical)
                    .multilineTextAlignment(.leading)
                    .focused(self.$isFocused)

                    Spacer()

                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .deleteDisabled(false)
                .moveDisabled(false)
            }
            .onDelete { offsets in
                self.onRemove(offsets)
            }
            .onMove { from, to in
                self.onMove(from, to)
            }

            Button {
                self.onAdd()
            } label: {
                Text(BluerageStrings.agentNewStepButtonTitle)
                    .foregroundStyle(.link)
            }
        } header: {
            Text(BluerageStrings.agentStepsSectionHeader)
        }
    }

}
