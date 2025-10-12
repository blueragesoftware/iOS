import Foundation

struct Model: Identifiable, Codable, Equatable, Hashable {

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case provider
        case modelId
    }

    let id: String

    let name: String

    let provider: ModelProvider

    let modelId: String

}
