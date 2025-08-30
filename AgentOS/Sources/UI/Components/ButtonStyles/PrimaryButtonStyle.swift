import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {

    private let scaleAmount: CGFloat

    private let animation: Animation

    public init(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) {
        self.scaleAmount = scaleAmount
        self.animation = animation
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(UIColor.label.swiftUI)
            .foregroundStyle(UIColor.systemBackground.swiftUI)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? self.scaleAmount : 1.0)
            .animation(self.animation, value: configuration.isPressed)
    }

}

public extension ButtonStyle where Self == PrimaryButtonStyle {

    static var primaryButtonStyle: PrimaryButtonStyle {
        return PrimaryButtonStyle()
    }

    static func primaryButtonStyle(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) -> PrimaryButtonStyle {
        return PrimaryButtonStyle(scaleAmount: scaleAmount, animation: animation)
    }

}
