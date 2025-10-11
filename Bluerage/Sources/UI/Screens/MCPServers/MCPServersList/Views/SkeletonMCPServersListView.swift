import SwiftUI
import Shimmer

struct SkeletonMCPServersListView: View {

    var body: some View {
        VStack(spacing: 28) {
            ForEach(0...4, id: \.self) { _ in
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(UIColor.systemFill.swiftUI)
                            .frame(width: 120, height: 13)

                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                            .frame(width: 80, height: 10)
                    }

                    Spacer()

                    Capsule()
                        .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                        .frame(width: 75, height: 32)
                }
                .padding(.horizontal, 20)
            }
            .shimmering(active: true)

            Spacer()
        }

    }

}
