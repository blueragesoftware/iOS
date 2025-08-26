import SwiftUI

struct AgentCellView: View {

    private let agent: Agent

    private let onOpen: () -> Void

    init(agent: Agent, onOpen: @escaping () -> Void) {
        self.agent = agent
        self.onOpen = onOpen
    }

    var body: some View {
        Button {
            self.onOpen()
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.agent.name)
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(UIColor.label.swiftUI)
                }

                Spacer()

                Button {
                    self.onOpen()
                } label: {
                    Text("agents_list_open_button_title")
                        .foregroundStyle(UIColor.label.swiftUI)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 18)
                        .fixedSize()
                }
                .buttonStyle(.borderGradientProminentButtonStyle)
            }
        }
    }

}
