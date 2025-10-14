import SwiftUI

struct CustomModelCellView: View {

    private let customModel: CustomModel

    private let onOpen: () -> Void

    init(customModel: CustomModel, onOpen: @escaping () -> Void) {
        self.customModel = customModel
        self.onOpen = onOpen
    }

    var body: some View {
        Button {
            self.onOpen()
        } label: {
            HStack(spacing: 0) {
                Text(self.customModel.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.leading, 12)

                Spacer()

                Image(systemName: "chevron.forward")
                    .renderingMode(.template)
                    .foregroundStyle(.primary)
                    .font(.system(size: 13, weight: .semibold))
                    .fixedSize()
            }
        }
    }

}
