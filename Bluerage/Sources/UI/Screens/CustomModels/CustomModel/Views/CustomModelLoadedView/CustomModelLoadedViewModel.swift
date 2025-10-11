import FactoryKit
import ConvexMobile
import OSLog
import SwiftUI

@MainActor
@Observable
final class CustomModelLoadedViewModel {

    private struct CustomModelUpdateRequest: UpdateRequest, Encodable, ConvexEncodable {
        var name: String?
        var provider: String?
        var modelId: String?
        var encryptedApiKey: String?
        var baseUrl: String??

        static var empty: CustomModelUpdateRequest {
            CustomModelUpdateRequest()
        }

        var hasUpdates: Bool {
            return self.name != nil
            || self.provider != nil
            || self.modelId != nil
            || self.encryptedApiKey != nil
            || self.baseUrl != nil
        }

        mutating func merge(with other: CustomModelUpdateRequest) {
            if let otherName = other.name { self.name = otherName }
            if let otherProvider = other.provider { self.provider = otherProvider }
            if let otherModelId = other.modelId { self.modelId = otherModelId }
            if let otherEncryptedApiKey = other.encryptedApiKey { self.encryptedApiKey = otherEncryptedApiKey }
            if let otherBaseUrl = other.baseUrl { self.baseUrl = otherBaseUrl }
        }
    }

    var alertError: Error?

    let customModel: CustomModel

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private let queuedUpdater: QueuedUpdater<CustomModelUpdateRequest>

    // MARK: - Initialization

    init(customModel: CustomModel) {
        self.customModel = customModel

        weak var weakSelf: CustomModelLoadedViewModel?

        self.queuedUpdater = QueuedUpdater<CustomModelUpdateRequest> { request in
            guard let self = weakSelf else {
                return false
            }

            return await self.performUpdate(request: request)
        }

        weakSelf = self
    }

    // MARK: - Public Methods

    func updateCustomModel(name: String? = nil,
                           provider: String? = nil,
                           modelId: String? = nil,
                           encryptedApiKey: String? = nil,
                           baseUrl: String?? = nil) {
        let request = CustomModelUpdateRequest(
            name: name,
            provider: provider,
            modelId: modelId,
            encryptedApiKey: encryptedApiKey,
            baseUrl: baseUrl
        )

        self.queuedUpdater.enqueue(request)
    }

    func flush() {
        self.queuedUpdater.flush()
    }

    // MARK: - Private Methods

    private func performUpdate(request: CustomModelUpdateRequest) async -> Bool {
        var modelData: [String: any ConvexEncodable] = [:]

        if let name = request.name { modelData["name"] = name }
        if let provider = request.provider { modelData["provider"] = provider }
        if let modelId = request.modelId { modelData["modelId"] = modelId }
        if let encryptedApiKey = request.encryptedApiKey { modelData["encryptedApiKey"] = encryptedApiKey }
        if let baseUrl = request.baseUrl { modelData["baseUrl"] = baseUrl }

        guard !modelData.isEmpty else {
            return true
        }

        var args: [String: any ConvexEncodable] = [
            "id": self.customModel.id
        ]

        for (key, value) in modelData {
            args[key] = value
        }

        do {
            try await self.convex.mutation("customModels:update", with: args)

            Logger.customModels.info("Custom model updated successfully with \(modelData.count, privacy: .public) fields")

            return true
        } catch {
            Logger.customModels.error("Failed to update custom model: \(error.localizedDescription, privacy: .public)")

            self.alertError = error

            return false
        }
    }

}
