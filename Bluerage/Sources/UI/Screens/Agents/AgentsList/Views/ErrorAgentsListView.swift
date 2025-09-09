import SwiftUI
import FactoryKit

struct ErrorAgentsListView: View {

    private let onRefresh: () -> Void

    init(onRefresh: @escaping () -> Void) {
        self.onRefresh = onRefresh
    }

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView.error {
                self.onRefresh()
            }
        }
    }

}
