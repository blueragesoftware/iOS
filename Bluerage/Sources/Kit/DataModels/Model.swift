import Foundation

struct Model: Identifiable, Codable, Equatable, Hashable {

    let id: String

    let name: String

    let provider: String

    let modelId: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case provider
        case modelId
    }
    
}
