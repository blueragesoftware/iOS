import Foundation

struct Tool: Identifiable, Codable, Equatable, Hashable {

    enum Status: String, Codable {
        case initializing
        case initiated
        case active
        case failed
        case expired
        case inactive
    }

    var id: String {
        self.slug
    }

    var logoURL: URL? {
        if let logo {
            return URL(string: logo)
        }

        return nil
    }

    let authConfigId: String

    let name: String

    let slug: String

    let description: String?

    let logo: String?

    let status: Status

}
