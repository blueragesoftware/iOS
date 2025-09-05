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
        case modelId
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

    let id: String

    let name: String

    let description: String

    let iconUrl: String

    let goal: String

    let tools: [Tool]

    let steps: [Step]

    let modelId: String
    
}
