import Foundation

struct GetByIdWithModelResponse: Codable, Equatable {

    let agent: Agent

    let model: ModelUnion

}

enum ModelUnion: Codable, Equatable, Hashable {

    case model(Model)
    case customModel(CustomModel)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "model":
            let model = try Model(from: decoder)
            self = .model(model)
        case "customModel":
            let customModel = try CustomModel(from: decoder)
            self = .customModel(customModel)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Invalid model type: \(type)"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .model(let model):
            try container.encode("model", forKey: .type)
            try model.encode(to: encoder)
        case .customModel(let customModel):
            try container.encode("customModel", forKey: .type)
            try customModel.encode(to: encoder)
        }
    }

    var name: String {
        switch self {
        case .model(let model):
            return model.name
        case .customModel(let customModel):
            return customModel.name
        }
    }

    var id: String {
        switch self {
        case .model(let model):
            return model.id
        case .customModel(let customModel):
            return customModel.id
        }
    }

}
