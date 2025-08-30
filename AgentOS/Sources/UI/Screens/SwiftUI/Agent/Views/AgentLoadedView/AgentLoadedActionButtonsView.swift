import SwiftUI

struct AgentLoadedActionButtonsView: View {
    
    private let onExecutions: () -> Void

    private let onRunAgent: () -> Void

    init(onExecutions: @escaping () -> Void, onRunAgent: @escaping () -> Void) {
        self.onExecutions = onExecutions
        self.onRunAgent = onRunAgent
    }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                self.onExecutions()
            } label: {
                Text("Executions")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.label.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderGradientProminentButtonStyle)
            
            Button {
                self.onRunAgent()
            } label: {
                Text("Run Agent")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primaryButtonStyle)
        }
        .padding(.horizontal, 20)
    }

}
