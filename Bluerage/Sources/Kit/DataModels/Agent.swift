import Foundation
import ConvexMobile

struct Agent: Identifiable, Codable, Equatable, Hashable, ConvexEncodable {

    struct Step: Identifiable, Codable, Equatable, Hashable, ConvexEncodable {

        let id: String

        let value: String

    }

    let id: String

    let name: String

    let description: String

    let iconUrl: String

    let goal: String

    let tools: [Tool]

    let steps: [Step]

    let modelId: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case iconUrl
        case goal
        case tools
        case steps
        case modelId
    }
    
}
