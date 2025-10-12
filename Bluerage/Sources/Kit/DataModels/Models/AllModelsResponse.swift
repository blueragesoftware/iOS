import Foundation

struct AllModelsResponse: Decodable, Equatable {

    let models: [Model]

    let customModels: [CustomModel]

}
