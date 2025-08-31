import Foundation

struct Tool: Identifiable, Codable, Equatable, Hashable {

    let id: String

    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }

}
