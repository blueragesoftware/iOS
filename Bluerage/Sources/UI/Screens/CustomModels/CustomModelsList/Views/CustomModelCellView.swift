import SwiftUI
import FactoryKit

struct CustomModelCellView: View {

    private let customModel: CustomModel

    private let onOpen: () -> Void

    @Injected(\.modelProviderIconFactory) private var modelProviderIconFactory

    init(customModel: CustomModel, onOpen: @escaping () -> Void) {
        self.customModel = customModel
        self.onOpen = onOpen
    }

    var body: some View {
        Button {
            self.onOpen()
        } label: {
            IconCell(title: self.customModel.name,
                     iconFillColor: .white,
                     icon: {
                self.modelProviderIconFactory.styledIcon(for: self.customModel.provider)
            }, trailingView: {
                Image(systemName: "chevron.forward")
                    .renderingMode(.template)
                    .foregroundStyle(.primary)
                    .font(.system(size: 13, weight: .semibold))
                    .fixedSize()
            }, action: {
                self.onOpen()
            })
        }
    }

}
