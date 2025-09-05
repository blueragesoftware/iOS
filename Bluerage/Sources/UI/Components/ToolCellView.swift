import SwiftUI
import NukeUI
import Nuke

struct ToolCellView<TrailingAccessory: View>: View {

    private let imageSize: CGFloat = 20

    private let tool: Tool
    
    private let onTap: ((Tool) -> Void)?

    @ViewBuilder
    private let trailingAccessory: ((Tool) -> TrailingAccessory)?

    init(tool: Tool,
         onTap: ((Tool) -> Void)? = nil,
         @ViewBuilder trailingAccessory: @escaping (Tool) -> TrailingAccessory) {
        self.tool = tool
        self.onTap = onTap
        self.trailingAccessory = trailingAccessory
    }

    var body: some View {
        Button {
            self.onTap?(self.tool)
        } label: {
            ZStack {
                Color.clear

                HStack {
                    LazyImage(url: self.tool.logoURL) { state in
                        let isSVG = (try? state.result?.get().request.url?.absoluteString.hasSuffix(".svg")) ?? false

                        if isSVG, let data = state.imageContainer?.data {
                            SVGImage(data: data, size: CGSize(width: self.imageSize, height: self.imageSize))
                        } else if let image = state.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            UIColor.quaternarySystemFill.swiftUI
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .frame(width: self.imageSize, height: self.imageSize)
                    .fixedSize()
                    .padding(.trailing, 4)

                    Text(self.tool.name)

                    Spacer()

                    self.trailingAccessory?(self.tool)
                }
            }
        }
        .buttonStyle(.plain)
    }

}

extension ToolCellView where TrailingAccessory == Never {

    init(tool: Tool, onTap: ((Tool) -> Void)? = nil) {
        self.tool = tool
        self.onTap = onTap
        self.trailingAccessory = nil
    }

}
