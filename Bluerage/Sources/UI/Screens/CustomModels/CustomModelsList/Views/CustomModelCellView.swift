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
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.customModel.name)
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    Text(self.customModel.provider)
                        .font(.system(size: 13, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                OpenButton(onOpen: self.onOpen)
            }
        }
    }

}
