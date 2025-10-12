import SwiftUI
import OSLog
import PostHog
import NavigatorUI
import FactoryKit

struct CustomModelsListScreenView: View {

    private struct CreateNewCustomModelButton: View {

        private let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        var body: some View {
            Button {
                self.action()
            } label: {
                Text(BluerageStrings.customModelsCreateButtonTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(UIColor.systemBackground.swiftUI)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .buttonStyle(.primaryButtonStyle)
        }

    }

    @State private var viewModel = CustomModelsListScreenViewModel()

    @Injected(\.hapticManager) private var hapticManager

    @Environment(\.navigator) private var navigator

    var body: some View {
        self.content
            .navigationDestinationAutoReceive(CustomModelsListDestinations.self)
            .safeAreaInset(edge: .bottom) {
                if self.viewModel.state.main.isLoaded {
                    CreateNewCustomModelButton {
                        self.createNewCustomModel()
                    }
                }
            }
            .scrollDisabled(self.viewModel.state.main.isLoading || self.viewModel.state.main.isError)
            .onFirstAppear {
                self.viewModel.connect()
            }
            .navigationTitle(BluerageStrings.customModelsNavigationTitle)
            .toolbarTitleDisplayMode(.inline)
            .background(UIColor.systemGroupedBackground.swiftUI)
            .errorAlert(error: self.viewModel.state.alertError) {
                self.viewModel.resetAlertError()
            }
            .postHogScreenView("CustomModelsListScreenView")
    }

    @ViewBuilder
    private var content: some View {
        switch self.viewModel.state.main {
        case .loading:
            SkeletonCustomModelsListView()
                .transition(.blurReplace)
        case .loaded(let customModels):
            LoadedCustomModelsListView(customModels: customModels,
                                       onRemove: { ids in
                self.removeCustomModels(with: ids)
            })
            .transition(.blurReplace)
        case .empty:
            EmptyCustomModelsListView {
                self.createNewCustomModel()
            }
            .transition(.blurReplace)
        case .error:
            ErrorCustomModelsListView {
                self.viewModel.connect()
            }
            .transition(.blurReplace)
        }
    }

    private func createNewCustomModel() {
        self.hapticManager.triggerSelectionFeedback()

        Task {
            do {
                let customModel = try await self.viewModel.createNewCustomModel()

                self.navigator.navigate(to: CustomModelsListDestinations.customModel(id: customModel.id))
            } catch {
                Logger.customModels.error("Error creating new custom model: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

    private func removeCustomModels(with ids: [String]) {
        Task {
            do {
                try await self.viewModel.removeCustomModels(with: ids)
            } catch {
                Logger.customModels.error("Error removing custom models: \(error.localizedDescription, privacy: .public)")

                self.viewModel.showErrorAlert(with: error)
            }
        }
    }

}
