import Foundation

struct ExecutionTask: Identifiable, Decodable, Equatable, Hashable {

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case agentId
        case agent
        case model
        case state
    }

    enum State: Decodable, Equatable, Hashable {

        private enum CodingKeys: String, CodingKey {
            case type
            case error
            case result
        }

        case registered
        case running
        case error(String)
        case success(String)

        var title: String {
            switch self {
            case .registered:
                return "Registered"
            case .running:
                return "Running"
            case .error:
                return "Error"
            case .success:
                return "Success"
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "registered":
                self = .registered
            case "running":
                self = .running
            case "error":
                let error = try
                container.decode(String.self, forKey: .error)
                self = .error(error)
            case "success":
                let result = try
                container.decode(String.self, forKey: .result)
                self = .success(result)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type,
                                                       in: container,
                                                       debugDescription: "Unknown state type: \(type)")
            }
        }

    }

    let id: String

    let agentId: String

    let agent: Agent

    let model: Model

    let state: State

}
