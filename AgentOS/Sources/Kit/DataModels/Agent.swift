import Foundation
import ConvexMobile

struct Agent: Identifiable, Codable, Equatable {

    let id: String

    let name: String

    let goal: String

    let tools: [String]

    let steps: String

    let model: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case goal
        case tools
        case steps
        case model
    }
    
}
