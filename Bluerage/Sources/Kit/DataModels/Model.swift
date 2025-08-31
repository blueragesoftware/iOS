import Foundation

struct Model: Identifiable, Codable, Equatable, Hashable {

    let id: String

    let provider: String

    let model: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case provider
        case model
    }
}
