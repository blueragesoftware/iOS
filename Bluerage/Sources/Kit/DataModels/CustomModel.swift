import Foundation

struct CustomModel: Identifiable, Codable, Equatable, Hashable {

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case name
        case provider
        case modelId
        case encryptedApiKey
        case baseUrl
    }

    let id: String

    let userId: String

    let name: String

    let provider: String

    let modelId: String

    let encryptedApiKey: String

    let baseUrl: String?

}
