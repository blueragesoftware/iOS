import SwiftUI
import FactoryKit
import NavigatorUI

struct LoadedCustomModelsListView: View {

    private let customModels: [CustomModel]

    private let onRemove: ([String]) -> Void

    @Environment(\.navigator) private var navigator

    @Injected(\.hapticManager) private var hapticManager

    init(customModels: [CustomModel],
         onRemove: @escaping ([String]) -> Void) {
        self.customModels = customModels
        self.onRemove = onRemove
    }

    var body: some View {
        List {
            ForEach(self.customModels) { customModel in
                CustomModelCellView(customModel: customModel) {
                    self.hapticManager.triggerSelectionFeedback()
                    self.navigator.navigate(to: CustomModelsListDestinations.customModel(id: customModel.id))
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(UIColor.systemGroupedBackground.swiftUI)
    }

}
