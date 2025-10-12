import SwiftUI

struct ModelProviderIconFactory {

    @ViewBuilder
    func styledIcon(for modelProvider: ModelProvider) -> some View {
        self.image(for: modelProvider)
            .resizable()
            .renderingMode(.template)
            .frame(width: 19, height: 19)
            .foregroundStyle(self.foregroundColor(for: modelProvider))
            .fixedSize()
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(self.backgroundColor(for: modelProvider))
                    .frame(width: 28, height: 28)
            }
            .frame(width: 28, height: 28)
    }

    func image(for modelProvider: ModelProvider) -> Image {
        switch modelProvider {
        case .openrouter:
            BluerageAsset.Assets.openrouterIcon.swiftUIImage
        case .openai:
            BluerageAsset.Assets.openaiIcon.swiftUIImage
        case .anthropic:
            BluerageAsset.Assets.anthropicIcon.swiftUIImage
        case .xai:
            BluerageAsset.Assets.xaiIcon.swiftUIImage
        }
    }

    func uiImage(for modelProvider: ModelProvider) -> UIImage {
        switch modelProvider {
        case .openrouter:
            BluerageAsset.Assets.openrouterIcon.image
        case .openai:
            BluerageAsset.Assets.openaiIcon.image
        case .anthropic:
            BluerageAsset.Assets.anthropicIcon.image
        case .xai:
            BluerageAsset.Assets.xaiIcon.image
        }
    }

    private func foregroundColor(for modelProvider: ModelProvider) -> Color {
        switch modelProvider {
        case .openrouter:
                .white
        case .openai:
                .black
        case .anthropic:
                .black
        case .xai:
                .white
        }
    }

    private func backgroundColor(for modelProvider: ModelProvider) -> Color {
        switch modelProvider {
        case .openrouter:
                .gray
        case .openai:
                .white
        case .anthropic:
            BluerageAsset.Assets.anthropicColor.swiftUIColor
        case .xai:
                .black
        }
    }

}
