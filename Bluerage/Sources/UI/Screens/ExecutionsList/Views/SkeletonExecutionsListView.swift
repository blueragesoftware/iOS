import SwiftUI
import Shimmer

struct SkeletonExecutionsListView: View {

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            VStack(spacing: 28) {
                ForEach(0..<5) { _ in
                    HStack(spacing: 0) {
                        Circle()
                            .fill(UIColor.systemFill.swiftUI)
                            .frame(width: 44, height: 44)
                            .padding(.trailing, 16)

                        VStack(alignment: .leading, spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(UIColor.systemFill.swiftUI)
                                .frame(width: 140, height: 16)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(UIColor.quaternarySystemFill.swiftUI)
                                .frame(width: 200, height: 13)
                        }

                        Spacer()

                        Capsule()
                            .foregroundStyle(UIColor.quaternarySystemFill.swiftUI)
                            .frame(width: 75, height: 32)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .shimmering(active: true,
                        gradient: ShimmerGradientProvider.shimmerGradient)
        }
    }

}
