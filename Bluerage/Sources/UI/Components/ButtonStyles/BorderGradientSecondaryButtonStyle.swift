import SwiftUI

public struct BorderGradientProminentButtonStyle: ButtonStyle {

    private let scaleAmount: CGFloat

    private let animation: Animation

    public init(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) {
        self.scaleAmount = scaleAmount
        self.animation = animation
    }

    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label
                .glassEffect(.regular.interactive())
                .contentShape(Capsule())
        } else {
            configuration.label
                .background {
                    Capsule()
                        .fill(UIColor.systemGray5.swiftUI)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.64),
                                    .white.opacity(0.24)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ).opacity(0.24),
                            lineWidth: 1
                        )
                        .scaleEffect(configuration.isPressed ? self.scaleAmount : 1.0)
                        .animation(self.animation, value: configuration.isPressed)
                }
                .contentShape(Capsule())
        }
    }

}

public extension ButtonStyle where Self == BorderGradientProminentButtonStyle {

    static var borderGradientProminentButtonStyle: BorderGradientProminentButtonStyle {
        return BorderGradientProminentButtonStyle()
    }

    static func borderGradientProminentButtonStyle(scaleAmount: CGFloat = 0.95, animation: Animation = .spring(response: CATransaction.animationDuration(), dampingFraction: 1, blendDuration: 0)) -> BorderGradientProminentButtonStyle {
        return BorderGradientProminentButtonStyle(scaleAmount: scaleAmount, animation: animation)
    }

}
