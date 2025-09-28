import Foundation
import ConvexMobile

struct Agent: Identifiable, Codable, Equatable, Hashable, ConvexEncodable {

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case iconUrl
        case goal
        case tools
        case steps
        case model
        case files
    }

    struct Step: Identifiable, Codable, Equatable, Hashable, ConvexEncodable {

        let id: String

        let value: String

    }

    struct Tool: Identifiable, Codable, Equatable, Hashable, ConvexEncodable {

        var id: String {
            return self.slug
        }

        let slug: String

        let name: String

    }

    struct File: Identifiable, Codable, Equatable, Hashable, ConvexEncodable {

        enum `Type`: String, Codable {
            case image
            case file
        }

        var id: String {
            return self.storageId
        }

        let storageId: String

        let name: String

        let type: `Type`

    }

    let id: String

    let name: String

    let description: String

    let iconUrl: String

    let goal: String

    let tools: [Tool]

    let steps: [Step]

    let model: AgentModel

    let files: [File]

}

enum AgentModel: Codable, Equatable, Hashable, ConvexEncodable {

    case model(id: String)
    case customModel(id: String)

    private enum CodingKeys: String, CodingKey {
        case type, id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let id = try container.decode(String.self, forKey: .id)

        switch type {
        case "model":
            self = .model(id: id)
        case "customModel":
            self = .customModel(id: id)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Invalid model type: \(type)"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .model(let id):
            try container.encode("model", forKey: .type)
            try container.encode(id, forKey: .id)
        case .customModel(let id):
            try container.encode("customModel", forKey: .type)
            try container.encode(id, forKey: .id)
        }
    }

    var id: String {
        switch self {
        case .model(let id), .customModel(let id):
            return id
        }
    }

    var isCustomModel: Bool {
        switch self {
        case .customModel:
            return true
        case .model:
            return false
        }
    }

}
