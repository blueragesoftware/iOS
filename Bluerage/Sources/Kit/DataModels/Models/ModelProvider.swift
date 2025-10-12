import Foundation

enum ModelProvider: String, Codable {
    case openrouter
    case openai
    case anthropic
    case xai

    var label: String {
        switch self {
        case .openrouter:
            "OpenRouter"
        case .openai:
            "OpenAI"
        case .anthropic:
            "Anthropic"
        case .xai:
            "xAI"
        }
    }
}
