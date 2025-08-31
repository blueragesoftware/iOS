import SwiftUI
import FactoryKit

struct ErrorAgentsListView: View {

    private let refresh: () -> Void

    init(refresh: @escaping () -> Void) {
        self.refresh = refresh
    }

    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal, .vertical])

            PlaceholderView.error {
                self.refresh()
            }
        }
    }

}
