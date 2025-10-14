import SwiftUI

struct ModelProviderIconFactory {

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

    func foregroundColor(for modelProvider: ModelProvider) -> Color {
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

    func backgroundColor(for modelProvider: ModelProvider) -> Color {
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
