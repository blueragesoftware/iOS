import SwiftUI

struct SkeletonAgentCellView: View {

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                    .frame(width: 100, height: 13)
            }

            Spacer()

            Capsule()
                .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                .frame(width: 75, height: 32)
        }
    }

}
