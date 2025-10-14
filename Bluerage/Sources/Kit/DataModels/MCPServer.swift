import Foundation

struct MCPServer: Identifiable, Codable, Equatable, Hashable {

    enum Status: String, Codable {
        case connected
        case connecting
        case disconnected
        case error

        var localized: String {
            switch self {
            case .connected:
                "Connected"
            case .connecting:
                "Connecting"
            case .disconnected:
                "Disconnected"
            case .error:
                "Error"
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case name
        case url
        case status
        case apiKey
    }

    let id: String

    let userId: String

    let name: String

    let url: String

    let status: Status

    let apiKey: String?

}
