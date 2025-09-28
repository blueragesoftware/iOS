import SwiftUI
import NukeUI
import Nuke
import SVGView

struct ToolCellView: View {

    private struct TrailingAccessory: View {

        private let status: Tool.Status

        init(status: Tool.Status) {
            self.status = status
        }

        var body: some View {
            switch self.status {
            case .initializing:
                ProgressView()
            case .active:
                EmptyView()
            case .failed, .expired:
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.red)

                    Image(systemName: "arrow.up.right")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                }
            case .inactive:
                Image(systemName: "arrow.up.right")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.primary)
            case .initiated:
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.yellow)

                    Image(systemName: "arrow.up.right")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                }
            }
        }

    }

    private static let imageSize: CGFloat = 28

    private let tool: Tool

    private let onTap: ((Tool) -> Void)?

    init(tool: Tool,
         onTap: ((Tool) -> Void)? = nil) {
        self.tool = tool
        self.onTap = onTap
    }

    var body: some View {
        Button {
            self.onTap?(self.tool)
        } label: {
            HStack {
                LazyImage(url: self.tool.logoURL) { state in
                    let isSVG = (try? state.result?.get().request.url?.absoluteString.hasSuffix(".svg")) ?? false

                    if isSVG, let data = state.imageContainer?.data {
                        SVGView(data: data)
                    } else if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else {
                        UIColor.quaternarySystemFill.swiftUI
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(width: Self.imageSize, height: Self.imageSize)
                .fixedSize()
                .padding(.trailing, 4)

                Text(self.tool.name)

                Spacer()

                TrailingAccessory(status: self.tool.status)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
    }

}
