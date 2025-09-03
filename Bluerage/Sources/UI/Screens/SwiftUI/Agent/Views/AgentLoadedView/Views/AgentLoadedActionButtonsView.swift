import SwiftUI

struct AgentLoadedActionButtonsView: View {
    
    private let onHistory: () -> Void

    private let onRunAgent: () -> Void

    init(onHistory: @escaping () -> Void, onRunAgent: @escaping () -> Void) {
        self.onHistory = onHistory
        self.onRunAgent = onRunAgent
    }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                self.onHistory()
            } label: {
                Text("History")
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
