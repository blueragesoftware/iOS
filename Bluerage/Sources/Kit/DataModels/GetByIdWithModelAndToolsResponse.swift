import Foundation

struct GetByIdWithModelAndToolsResponse: Codable, Equatable {

    let agent: Agent

    let model: Model

    let tools: [Tool]

}
