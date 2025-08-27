import Foundation
import ConvexMobile

struct Agent: Identifiable, Codable, Equatable {

    let id: String

    let name: String

    let description: String

    let iconUrl: String

    let goal: String

    let tools: [String]

    let steps: String

    let model: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case iconUrl
        case goal
        case tools
        case steps
        case model
    }
    
}
