import SwiftUI

private struct FirstAppear: ViewModifier {

    let action: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !self.hasAppeared else {
                return
            }

            self.hasAppeared = true
            self.action()
        }
    }

}

extension View {

    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        self.modifier(FirstAppear(action: action))
    }

}
