import SwiftUI
import NukeUI

struct AgentCellView: View {

    private static let iconSize: CGFloat = 60

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
                LazyImage(url: URL(string: self.agent.iconUrl)) { state in
                    if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else {
                        UIColor.quaternarySystemFill.swiftUI
                    }
                }
                .processors([.resize(height: Self.iconSize), .circle()])
                .clipShape(Circle())
                .frame(width: Self.iconSize, height: Self.iconSize)
                .fixedSize()
                .padding(.trailing, 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(self.agent.name)
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    Text(self.agent.description)
                        .font(.system(size: 13, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                OpenButton(onOpen: self.onOpen)
            }
        }
    }

}
