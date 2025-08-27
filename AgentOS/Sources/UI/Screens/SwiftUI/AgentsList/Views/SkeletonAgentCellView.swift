import SwiftUI

struct SkeletonAgentCellView: View {

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                .frame(width: 60, height: 60)
                .padding(.trailing, 16)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                    .frame(width: 100, height: 13)

                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                    .frame(width: 120, height: 10)
            }

            Spacer()

            Capsule()
                .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                .frame(width: 75, height: 32)
        }
    }

}
