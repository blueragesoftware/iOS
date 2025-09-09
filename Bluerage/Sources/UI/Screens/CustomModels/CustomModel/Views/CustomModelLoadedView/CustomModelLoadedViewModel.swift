import FactoryKit
import ConvexMobile
import OSLog
import Combine
import SwiftUI

@MainActor
@Observable
final class CustomModelLoadedViewModel {

    private struct UpdateRequest: Equatable, Encodable, ConvexEncodable {
        var name: String?
        var provider: String?
        var modelId: String?
        var encryptedApiKey: String?

        var hasUpdates: Bool {
            return self.name != nil
            || self.provider != nil
            || self.modelId != nil
            || self.encryptedApiKey != nil
        }

        mutating func merge(with other: UpdateRequest) {
            if let otherName = other.name { self.name = otherName }
            if let otherProvider = other.provider { self.provider = otherProvider }
            if let otherModelId = other.modelId { self.modelId = otherModelId }
            if let otherEncryptedApiKey = other.encryptedApiKey { self.encryptedApiKey = otherEncryptedApiKey }
        }
    }

    private enum UpdateAction {
        case merge(UpdateRequest)
        case reset
    }

    var alertError: Error?

    let customModel: CustomModel

    @ObservationIgnored
    private var updatesQueueCancellables = Set<AnyCancellable>()

    @ObservationIgnored
    @Injected(\.convex) private var convex

    @ObservationIgnored
    private let updateSubject = CurrentValueSubject<UpdateAction, Never>(.reset)

    @ObservationIgnored
    private let currentAccumulatedSubject = CurrentValueSubject<UpdateRequest, Never>(UpdateRequest())

    // MARK: - Initialization

    init(customModel: CustomModel) {
        self.customModel = customModel

        self.setupUpdatesQueue()
    }

    // MARK: - Public Methods

    func updateCustomModel(name: String? = nil,
                           provider: String? = nil,
                           modelId: String? = nil,
                           encryptedApiKey: String? = nil) {
        let request = UpdateRequest(
            name: name,
            provider: provider,
            modelId: modelId,
            encryptedApiKey: encryptedApiKey
        )

        self.updateSubject.send(.merge(request))
    }

    func flush() {
        var currentRequest = self.currentAccumulatedSubject.value
        let queueRequest = self.updateSubject.value

        if case .merge(let queueRequest) = queueRequest {
            currentRequest.merge(with: queueRequest)
        }

        self.updateSubject.send(.reset)

        if currentRequest.hasUpdates {
            self.performUpdate(request: currentRequest)
        }
    }

    // MARK: - Private Methods

    private func setupUpdatesQueue() {
        self.updateSubject
            .scan(UpdateRequest()) { accumulated, action in
                switch action {
                case .merge(let new):
                    var merged = accumulated
                    merged.merge(with: new)
                    return merged
                case .reset:
                    return UpdateRequest()
                }
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accumulatedRequest in
                self?.currentAccumulatedSubject.send(accumulatedRequest)
            }
            .store(in: &self.updatesQueueCancellables)

        self.currentAccumulatedSubject
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] mergedRequest in
                guard let self = self else {
                    return
                }

                if mergedRequest.hasUpdates {
                    self.performUpdate(request: mergedRequest)
                    self.updateSubject.send(.reset)
                }
            }
            .store(in: &self.updatesQueueCancellables)
    }

    private func performUpdate(request: UpdateRequest) {
        var modelData: [String: any ConvexEncodable] = [:]

        if let name = request.name { modelData["name"] = name }
        if let provider = request.provider { modelData["provider"] = provider }
        if let modelId = request.modelId { modelData["modelId"] = modelId }
        if let encryptedApiKey = request.encryptedApiKey { modelData["encryptedApiKey"] = encryptedApiKey }

        guard !modelData.isEmpty else {
            return
        }

        var args: [String: any ConvexEncodable] = [
            "id": self.customModel.id
        ]

        for (key, value) in modelData {
            args[key] = value
        }

        Task {
            do {
                try await self.convex.mutation("customModels:update", with: args)

                Logger.customModels.info("Custom model updated successfully with \(modelData.count, privacy: .public) fields")
            } catch {
                Logger.customModels.error("Failed to update custom model: \(error.localizedDescription, privacy: .public)")

                self.alertError = error
            }
        }
    }

}
