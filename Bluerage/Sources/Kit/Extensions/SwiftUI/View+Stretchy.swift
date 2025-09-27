import SwiftUI

extension View {

    func stretchyFormHeader() -> some View {
        self.visualEffect { effect, geometry in
            let currentHeight = geometry.size.height
            let scrollOffset = geometry.frame(in: .scrollView).minY - currentHeight
            let positionOffset = max(0, scrollOffset * 0.5)

            let newHeight = currentHeight + positionOffset
            let scaleFactor = newHeight / currentHeight

            return effect.scaleEffect(x: scaleFactor, y: scaleFactor, anchor: .bottom)
        }
    }

}
