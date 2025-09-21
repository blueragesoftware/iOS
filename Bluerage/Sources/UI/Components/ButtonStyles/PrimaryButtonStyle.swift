import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {

    private let scaleAmount: CGFloat

    private let animation: Animation

    @Environment(\.colorScheme) private var colorScheme

    public init(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) {
        self.scaleAmount = scaleAmount
        self.animation = animation
    }

    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .glassEffect(.regular.tint(self.colorScheme == .dark ? .white : .black).interactive())
                .contentShape(Capsule())
                .foregroundStyle(UIColor.systemBackground.swiftUI)
        } else {
            configuration.label
                .background(UIColor.label.swiftUI)
                .foregroundStyle(UIColor.systemBackground.swiftUI)
                .contentShape(Capsule())
                .scaleEffect(configuration.isPressed ? self.scaleAmount : 1.0)
                .animation(self.animation, value: configuration.isPressed)
        }

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
